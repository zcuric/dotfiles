#!/usr/bin/env bash
# Claude Code status line (2-row, responsive, quiet).
#
# Source of truth: ~/dotfiles/.claude/statusline-command.sh
# Symlinked to    ~/.claude/statusline-command.sh  (stow-managed, like CLAUDE.md)
#
#   row 1   molitvenik.app  ·  ⎇ main*⇡2  ·  #1234          $3.63  ·  v2.1.205
#   (pad)                          ^ clickable                ^ right-aligned
#   row 2   Opus 4.8 · high  ·  ctx ▰▱▱▱▱▱▱▱ 11% 108k/1M  ·  5h 3%·4h12m  7d 14%
#
# Colour is reserved for signal: the gauges (context, 5h, 7d) walk
# green -> lime -> yellow -> orange -> bold red as they fill, and the branch
# turns yellow when the tree is dirty. Everything else stays plain or dim.
#
# Responsive: Claude Code exports COLUMNS (v2.1.153+).
#   - row 2 sheds the reset countdown, then token counts, then the bar
#   - row 1's right block sheds the cost, then drops to its own row if it
#     still cannot fit beside the left block
#
# Env toggles:
#   CLAUDE_STATUSLINE_EMOJI=1       emoji icons (📁 🤖 🧠 ⏳ 💲) instead of plain glyphs
#   CLAUDE_STATUSLINE_NERD=1        Nerd Font glyphs instead of plain glyphs
#   CLAUDE_STATUSLINE_PAD=0         no blank line between rows
#   CLAUDE_STATUSLINE_NO_LINKS=1    plain text instead of OSC 8 hyperlinks
#   CLAUDE_STATUSLINE_NO_UPDATE=1   never check for a newer Claude Code release
#   CLAUDE_STATUSLINE_NO_COST=1     hide the session cost
#   CLAUDE_STATUSLINE_UNTRACKED=1   flag untracked files with '?' (costs a worktree scan)
#
# Performance: one jq fork, <=4 cheap git forks, zero network I/O on the render
# path (update check reads a cache, refreshed in a detached process every 6h).
# Width is measured in-process, so right-alignment costs no extra fork.
# Bash 3.2 compatible (macOS system bash): no EPOCHSECONDS, no associative arrays.

set -uo pipefail

# ${#var} counts characters only under a UTF-8 ctype; under LC_ALL=C it counts
# bytes and every multibyte glyph would inflate the measured width 3x.
case "${LC_ALL:-${LC_CTYPE:-${LANG:-}}}" in
  *UTF-8*|*utf-8*|*UTF8*|*utf8*) ;;
  *) export LC_ALL=en_US.UTF-8 ;;
esac

input=$(cat)

# ---------------------------------------------------------------------------
# One jq pass. Fields join on 0x1F (unit separator), not tab: tab is IFS
# whitespace, so bash collapses runs of it and one absent field would silently
# shift every later value left. Absent numbers come back as -1, not 0.
# ---------------------------------------------------------------------------
US=$(printf '\037')

line=$(printf '%s' "$input" | jq -r --arg s "$US" '
  [ (.workspace.current_dir // .cwd // "")
  , (.model.display_name // "")
  , (.effort.level // "")
  , (.fast_mode // false)
  , (.version // "")
  , ((.context_window.used_percentage // -1) | round)
  , (.context_window.total_input_tokens // -1)
  , (.context_window.context_window_size // -1)
  , ((.rate_limits.five_hour.used_percentage // -1) | round)
  , (.rate_limits.five_hour.resets_at // -1)
  , ((.rate_limits.seven_day.used_percentage // -1) | round)
  , (.cost.total_cost_usd // -1)
  , (.pr.number // -1)
  , (.pr.url // "")
  , (.pr.review_state // "")
  , (.workspace.git_worktree // "")
  , (.agent.name // "")
  , (.vim.mode // "")
  , (.output_style.name // "")
  ] | map(tostring) | join($s)' 2>/dev/null) || exit 0

IFS="$US" read -r cwd model effort fast version \
  ctx_pct ctx_tok ctx_size five_pct five_reset seven_pct \
  cost pr_num pr_url pr_state worktree agent_name vim_mode out_style <<< "$line"

[ -n "${cwd:-}" ] || exit 0

# ---------------------------------------------------------------------------
# Responsive breakpoints (row 2)
# ---------------------------------------------------------------------------
W=${COLUMNS:-100}
case "$W" in ''|*[!0-9]*) W=100 ;; esac

if   [ "$W" -ge 110 ]; then bar_cells=8; show_tokens=1; show_eta=1
elif [ "$W" -ge  92 ]; then bar_cells=8; show_tokens=1; show_eta=0
elif [ "$W" -ge  72 ]; then bar_cells=5; show_tokens=0; show_eta=0
else                        bar_cells=0; show_tokens=0; show_eta=0
fi

# ---------------------------------------------------------------------------
# Palette. Real ESC bytes, so the final printf never interprets backslashes
# that happen to live inside a branch name or model string.
# ---------------------------------------------------------------------------
E=$(printf '\033'); BEL=$(printf '\007')
R="${E}[0m"; DIM="${E}[2m"; B="${E}[1m"
GREY="${E}[38;5;245m"; BLUE="${E}[38;5;75m"
GREEN="${E}[38;5;71m"; YELLOW="${E}[38;5;179m"; RED="${E}[1;38;5;167m"

hue() {  # green -> lime -> yellow -> orange -> bold red (muted 256-colour ramp)
  if   [ "$1" -lt 50 ]; then printf '%s' "${E}[38;5;71m"
  elif [ "$1" -lt 70 ]; then printf '%s' "${E}[38;5;107m"
  elif [ "$1" -lt 85 ]; then printf '%s' "${E}[38;5;179m"
  elif [ "$1" -lt 95 ]; then printf '%s' "${E}[38;5;173m"
  else                       printf '%s' "$RED"
  fi
}

# OSC 8 hyperlink: ESC ]8;; URL BEL  text  ESC ]8;; BEL
# The URL is only emitted after the https:// + no-control-char check below, so
# it can never smuggle an escape sequence into the terminal.
osc8() {
  if [ -n "$1" ] && [ "${CLAUDE_STATUSLINE_NO_LINKS:-0}" != "1" ]; then
    printf '%s]8;;%s%s%s%s]8;;%s' "$E" "$1" "$BEL" "$2" "$E" "$BEL"
  else
    printf '%s' "$2"
  fi
}

# Icon sets. Default is deliberately quiet: monochrome glyphs and short text
# labels, so nothing competes with the colour that actually signals state.
# WIDE lists the double-width glyphs of the active set, for width measurement.
if [ "${CLAUDE_STATUSLINE_EMOJI:-0}" = "1" ]; then
  I_DIR="📁 "; I_GIT="⎇ "; I_MODEL="🤖 "; I_CTX="🧠 "; I_5H="⏳ 5h "; I_7D="📅 7d "
  I_COST="💲"; I_UP="⬆"; I_WARN=" ⚠"; I_TREE="🌳 "; I_PR="🔀 #"
  BAR_ON="█"; BAR_OFF="░"
  PR_OK="✅ #"; PR_BAD="❌ #"; PR_DRAFT="📝 #"; PR_BAD_SFX=""
  WIDE="📁 🤖 🧠 ⏳ 📅 💲 🌳 🔀 ✅ ❌ 📝"
elif [ "${CLAUDE_STATUSLINE_NERD:-0}" = "1" ]; then
  I_DIR=" "; I_GIT=" "; I_MODEL=" "; I_CTX=" "; I_5H=" 5h "; I_7D=" 7d "
  I_COST=""; I_UP=""; I_WARN=" "; I_TREE=" "; I_PR=" #"
  BAR_ON="▰"; BAR_OFF="▱"
  PR_OK=" #"; PR_BAD=" #"; PR_DRAFT=" #"; PR_BAD_SFX=""
  WIDE=""
else
  I_DIR=""; I_GIT="⎇ "; I_MODEL=""; I_CTX="ctx "; I_5H="5h "; I_7D="7d "
  I_COST="\$"; I_UP="↑"; I_WARN=" !"; I_TREE="⑂ "; I_PR="#"
  BAR_ON="▰"; BAR_OFF="▱"
  # colour alone distinguishes the PR states here, so mark the one that needs
  # action with a '!' -- it must stay legible without colour
  PR_OK="#"; PR_BAD="#"; PR_DRAFT="#"; PR_BAD_SFX="!"
  WIDE=""
fi

# Display width of plain (escape-free) text: characters, plus one extra cell
# for every double-width glyph in the active icon set.
disp_width() {
  s="$1"; w=${#s}
  for g in $WIDE; do
    t="${s//$g/}"
    w=$(( w + ${#s} - ${#t} ))
  done
  printf '%s' "$w"
}

DOT="·"
SEP="${DIM}  ${DOT}  ${R}"      # coloured separator
SEP_P="  ${DOT}  "              # its plain-text mirror, for width maths

# Greedy-wrap the segments in SEG_C[] / SEG_P[] into WRAPPED[], never exceeding
# COLUMNS-1. A single segment too wide to fit still gets its own line rather
# than being dropped -- losing the number is worse than letting it wrap.
wrap_segs() {
  WRAPPED=()
  local i=0 n=${#SEG_C[@]} cur_c="" cur_p="" cand_p
  while [ $i -lt $n ]; do
    if [ -z "$cur_p" ]; then
      cur_c="${SEG_C[$i]}"; cur_p="${SEG_P[$i]}"
    else
      cand_p="${cur_p}${SEP_P}${SEG_P[$i]}"
      if [ "$(disp_width "$cand_p")" -le $(( W - 1 )) ]; then
        cur_c="${cur_c}${SEP}${SEG_C[$i]}"; cur_p="$cand_p"
      else
        WRAPPED[${#WRAPPED[@]}]="$cur_c"
        cur_c="${SEG_C[$i]}"; cur_p="${SEG_P[$i]}"
      fi
    fi
    i=$(( i + 1 ))
  done
  [ -n "$cur_c" ] && WRAPPED[${#WRAPPED[@]}]="$cur_c"
}

# ===========================================================================
# ROW 1 (left) -- folder, branch, PR, worktree
# Built as coloured text plus a plain mirror, so the row can be right-aligned
# without having to strip ANSI/OSC sequences back out.
# ===========================================================================
l_col=""; l_plain=""; lsc=(); lsp=()
add_l() {  # $1 coloured, $2 plain
  [ -n "$2" ] || return 0
  lsc[${#lsc[@]}]="$1"; lsp[${#lsp[@]}]="$2"
  if [ -z "$l_plain" ]; then l_col="$1"; l_plain="$2"
  else l_col="${l_col}${SEP}$1"; l_plain="${l_plain}${SEP_P}$2"; fi
}

folder="${cwd##*/}"
add_l "${B}${I_DIR}${folder}${R}" "${I_DIR}${folder}"

branch=""
if b=$(git -C "$cwd" --no-optional-locks symbolic-ref --short -q HEAD 2>/dev/null); then
  branch="$b"
elif b=$(git -C "$cwd" --no-optional-locks rev-parse --short HEAD 2>/dev/null); then
  branch="@${b}"   # detached HEAD
fi

if [ -n "$branch" ]; then
  flags=""
  git -C "$cwd" --no-optional-locks diff --no-ext-diff --quiet -- 2>/dev/null || flags="${flags}*"
  git -C "$cwd" --no-optional-locks diff --no-ext-diff --cached --quiet -- 2>/dev/null || flags="${flags}+"
  if [ "${CLAUDE_STATUSLINE_UNTRACKED:-0}" = "1" ]; then
    [ -n "$(git -C "$cwd" --no-optional-locks ls-files --others --exclude-standard 2>/dev/null | head -1)" ] && flags="${flags}?"
  fi

  track=""
  if ab=$(git -C "$cwd" --no-optional-locks rev-list --left-right --count '@{u}...HEAD' 2>/dev/null); then
    behind=$(printf '%s' "$ab" | cut -f1); ahead=$(printf '%s' "$ab" | cut -f2)
    [ "${ahead:-0}" -gt 0 ] 2>/dev/null && track="${track}⇡${ahead}"
    [ "${behind:-0}" -gt 0 ] 2>/dev/null && track="${track}⇣${behind}"
  fi

  if [ -n "$flags" ]; then gc="$YELLOW"; else gc="$GREEN"; fi
  add_l "${gc}${I_GIT}${branch}${flags}${track}${R}" "${I_GIT}${branch}${flags}${track}"
fi

# PR badge, clickable. Claude Code hands us .pr.url directly, so this works for
# GitHub, GitLab, or whatever else it resolves -- no remote parsing needed.
if [ "$pr_num" -ge 0 ] 2>/dev/null; then
  sfx=""
  case "$pr_state" in
    approved)          pc="$GREEN";  pfx="$PR_OK" ;;
    changes_requested) pc="$RED";    pfx="$PR_BAD"; sfx="$PR_BAD_SFX" ;;
    draft)             pc="$GREY";   pfx="$PR_DRAFT" ;;
    *)                 pc="$YELLOW"; pfx="$I_PR" ;;
  esac

  # Only ever link a plain https URL that carries no control characters.
  safe_url=""
  case "$pr_url" in
    https://*)
      case "$pr_url" in
        *"$E"*|*"$BEL"*|*' '*) ;;      # reject escapes / whitespace
        *) safe_url="$pr_url" ;;
      esac
      ;;
  esac
  add_l "${pc}$(osc8 "$safe_url" "${pfx}${pr_num}${sfx}")${R}" "${pfx}${pr_num}${sfx}"
fi

[ -n "$worktree" ] && add_l "${BLUE}${I_TREE}${worktree}${R}" "${I_TREE}${worktree}"

# ===========================================================================
# ROW 1 (right) -- cost, version. Right-aligned.
# ===========================================================================
now=$(date +%s)

cost_col=""; cost_plain=""
if [ "${CLAUDE_STATUSLINE_NO_COST:-0}" != "1" ]; then
  case "$cost" in
    -1|'') ;;
    *) cost_plain="${I_COST}$(printf '%.2f' "$cost")"
       cost_col="${GREY}${cost_plain}${R}" ;;
  esac
fi

# Claude Code reports the running version but nothing about newer releases, so
# look it up ourselves -- out of band, never on the render path.
ver_plain="v${version}"; ver_col="${GREY}${ver_plain}${R}"
if [ -n "$version" ] \
   && [ "${CLAUDE_STATUSLINE_NO_UPDATE:-0}" != "1" ] \
   && [ -z "${CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC:-}" ]; then

  cache_dir="${XDG_CACHE_HOME:-$HOME/.cache}/claude-code"
  cache="$cache_dir/statusline-latest"
  latest=""; checked=0
  [ -f "$cache" ] && IFS=$'\t' read -r latest checked < "$cache" 2>/dev/null

  if [ $(( now - ${checked:-0} )) -gt 21600 ]; then   # 6h TTL
    (
      mkdir -p "$cache_dir" 2>/dev/null || exit 0
      ch=$(jq -r '.autoUpdatesChannel // "latest"' "$HOME/.claude/settings.json" 2>/dev/null)
      case "$ch" in latest|stable) ;; *) ch=latest ;; esac   # never interpolate an unvalidated channel
      v=$(curl -fsS --max-time 8 "https://downloads.claude.ai/claude-code-releases/$ch" 2>/dev/null \
            | tr -dc '0-9.+A-Za-z-' | head -c 32)
      [ -n "$v" ] && printf '%s\t%s\n' "$v" "$now" > "$cache.tmp" && mv "$cache.tmp" "$cache"
    ) >/dev/null 2>&1 &
    disown 2>/dev/null || true
  fi

  # Badge only when latest is strictly newer -- never for a pre-release build
  # that is ahead of the channel. Build metadata after '+' is ignored.
  if [ -n "$latest" ] && [ "${latest%%+*}" != "${version%%+*}" ]; then
    newest=$(printf '%s\n%s\n' "${version%%+*}" "${latest%%+*}" | sort -V 2>/dev/null | tail -1)
    if [ "$newest" = "${latest%%+*}" ]; then
      ver_plain="v${version} ${I_UP}${latest}"
      ver_col="${YELLOW}${ver_plain}${R}"
    fi
  fi
fi

# Two candidates: full (cost + version), then version alone.
if [ -n "$cost_plain" ]; then
  r_col_full="${cost_col}${SEP}${ver_col}"; r_plain_full="${cost_plain}${SEP_P}${ver_plain}"
else
  r_col_full="$ver_col"; r_plain_full="$ver_plain"
fi

# Wrap the left block first; right-alignment is only attempted when it still
# fits on a single line.
SEG_C=("${lsc[@]}"); SEG_P=("${lsp[@]}")
wrap_segs
head_rows=("${WRAPPED[@]}")

orphan_col=""
if [ ${#head_rows[@]} -eq 1 ]; then
  lw=$(disp_width "$l_plain")
  placed=0
  for cand in full ver; do
    if [ "$cand" = full ]; then rc="$r_col_full"; rp="$r_plain_full"
    else rc="$ver_col"; rp="$ver_plain"; fi
    rw=$(disp_width "$rp")
    gap=$(( W - lw - rw - 1 ))        # keep one column of right margin
    if [ "$gap" -ge 2 ]; then
      head_rows[0]="${l_col}$(printf "%${gap}s" '')${rc}"
      placed=1
      break
    fi
  done
  [ "$placed" -eq 0 ] && orphan_col="$r_col_full"
else
  orphan_col="$r_col_full"            # left block already wrapped; don't crowd it
fi

# ===========================================================================
# ROW 2 -- model + effort | context usage | rate limits
# ===========================================================================
# Drop the parenthetical suffix: "Opus 4.8 (1M context)" -> "Opus 4.8".
# The window size still shows in the context denominator (108k/1M).
model_short="${model%% (*}"

r2_model=""; r2_model_p=""
if [ -n "$model_short" ]; then
  r2_model="${I_MODEL}${model_short}"; r2_model_p="${I_MODEL}${model_short}"
  if [ -n "$effort" ]; then
    r2_model="${r2_model}${DIM} ${DOT} ${effort}${R}"; r2_model_p="${r2_model_p} ${DOT} ${effort}"
  fi
  if [ "$fast" = "true" ]; then
    r2_model="${r2_model}${DIM} ${DOT} fast${R}"; r2_model_p="${r2_model_p} ${DOT} fast"
  fi
fi

fmt_tok() {  # 107957 -> 108k ; 1000000 -> 1M
  n=$1
  if [ "$n" -ge 1000000 ]; then
    m=$(( n / 1000000 )); f=$(( (n % 1000000) / 100000 ))
    if [ "$f" -eq 0 ]; then printf '%dM' "$m"; else printf '%d.%dM' "$m" "$f"; fi
  elif [ "$n" -ge 1000 ]; then printf '%dk' $(( n / 1000 ))
  else printf '%d' "$n"; fi
}

r2_ctx=""; r2_ctx_p=""
if [ "$ctx_pct" -ge 0 ] 2>/dev/null; then
  c=$(hue "$ctx_pct")
  bar=""
  if [ "$bar_cells" -gt 0 ]; then
    filled=$(( ctx_pct * bar_cells / 100 ))          # floor: only a full context fills the bar
    [ "$filled" -eq 0 ] && [ "$ctx_pct" -gt 0 ] && filled=1
    [ "$filled" -gt "$bar_cells" ] && filled=$bar_cells
    i=0; while [ $i -lt "$bar_cells" ]; do
      if [ $i -lt $filled ]; then bar="${bar}${BAR_ON}"; else bar="${bar}${BAR_OFF}"; fi
      i=$(( i + 1 ))
    done
    bar="${bar} "
  fi
  r2_ctx="${DIM}${I_CTX}${R}${c}${bar}${ctx_pct}%${R}"; r2_ctx_p="${I_CTX}${bar}${ctx_pct}%"
  if [ "$show_tokens" -eq 1 ] && [ "$ctx_tok" -ge 0 ] 2>/dev/null && [ "$ctx_size" -gt 0 ] 2>/dev/null; then
    toks="$(fmt_tok "$ctx_tok")/$(fmt_tok "$ctx_size")"
    r2_ctx="${r2_ctx} ${DIM}${toks}${R}"; r2_ctx_p="${r2_ctx_p} ${toks}"
  fi
  if [ "$ctx_pct" -ge 90 ]; then
    r2_ctx="${r2_ctx}${c}${I_WARN}${R}"; r2_ctx_p="${r2_ctx_p}${I_WARN}"
  fi
fi

fmt_eta() { s=$1
  [ "$s" -le 0 ] && { printf 'now'; return; }
  h=$(( s / 3600 )); m=$(( (s % 3600) / 60 ))
  if [ "$h" -gt 0 ]; then printf '%dh%02dm' "$h" "$m"
  elif [ "$m" -gt 0 ]; then printf '%dm' "$m"
  else printf '<1m'; fi
}

r2_rl=""; r2_rl_p=""
if [ "$five_pct" -ge 0 ] 2>/dev/null; then
  c=$(hue "$five_pct"); eta=""; eta_p=""
  if [ "$show_eta" -eq 1 ] && [ "$five_reset" -gt 0 ] 2>/dev/null; then
    eta_p="${DOT}$(fmt_eta $(( five_reset - now )))"; eta="${DIM}${eta_p}${R}"
  fi
  r2_rl="${DIM}${I_5H}${R}${c}${five_pct}%${R}${eta}"; r2_rl_p="${I_5H}${five_pct}%${eta_p}"
fi
if [ "$seven_pct" -ge 0 ] 2>/dev/null; then
  c=$(hue "$seven_pct")
  [ -n "$r2_rl" ] && { r2_rl="${r2_rl}  "; r2_rl_p="${r2_rl_p}  "; }
  r2_rl="${r2_rl}${DIM}${I_7D}${R}${c}${seven_pct}%${R}"; r2_rl_p="${r2_rl_p}${I_7D}${seven_pct}%"
fi

SEG_C=(); SEG_P=()
push_seg() { [ -n "$2" ] || return 0; SEG_C[${#SEG_C[@]}]="$1"; SEG_P[${#SEG_P[@]}]="$2"; }
push_seg "$r2_model" "$r2_model_p"
push_seg "$r2_ctx"   "$r2_ctx_p"
push_seg "$r2_rl"    "$r2_rl_p"

body_rows=()
if [ ${#SEG_C[@]} -gt 0 ]; then
  wrap_segs
  body_rows=("${WRAPPED[@]}")
fi

# ===========================================================================
# ROW 3 -- contextual extras, plus the right block if it could not fit above
# ===========================================================================
row3=""
[ -n "$agent_name" ] && row3="${BLUE}▸ ${agent_name}${R}"
[ -n "$vim_mode" ] && row3="${row3:+$row3 }${BLUE}${vim_mode}${R}"
[ -n "$out_style" ] && [ "$out_style" != "default" ] && row3="${row3:+$row3 }${BLUE}${out_style}${R}"
if [ -n "$orphan_col" ]; then
  if [ -z "$row3" ]; then row3="$orphan_col"; else row3="${row3}${SEP}${orphan_col}"; fi
fi

# ===========================================================================
# render -- one line per row, blank-ish line between rows for breathing space.
# The pad line carries a single space: a truly empty line risks being trimmed.
# ===========================================================================
PAD="${CLAUDE_STATUSLINE_PAD:-1}"
# bash 3.2: expanding an empty array under `set -u` is an error, so guard each
out_rows=()
[ ${#head_rows[@]} -gt 0 ] && out_rows=("${head_rows[@]}")
[ ${#body_rows[@]} -gt 0 ] && out_rows=("${out_rows[@]}" "${body_rows[@]}")
[ -n "$row3" ] && out_rows=("${out_rows[@]}" "$row3")
[ ${#out_rows[@]} -gt 0 ] || exit 0

first=1
for r in "${out_rows[@]}"; do
  [ -n "$r" ] || continue
  if [ "$first" -eq 1 ]; then
    first=0
  else
    printf '\n'
    [ "$PAD" = "1" ] && printf ' \n'
  fi
  printf '%s' "$r"
done
