# ─────────────────────────────────────────────────────────────────
# Zinit — plugin manager
# ─────────────────────────────────────────────────────────────────
if [[ ! -f $HOME/.local/share/zinit/zinit.git/zinit.zsh ]]; then
    print -P "%F{33} %F{220}Installing %F{33}ZDHARMA-CONTINUUM%F{220} Initiative Plugin Manager (%F{33}zdharma-continuum/zinit%F{220})…%f"
    command mkdir -p "$HOME/.local/share/zinit" && command chmod g-rwX "$HOME/.local/share/zinit"
    command git clone https://github.com/zdharma-continuum/zinit "$HOME/.local/share/zinit/zinit.git" && \
        print -P "%F{33} %F{34}Installation successful.%f%b" || \
        print -P "%F{160} The clone has failed.%f%b"
fi

source "$HOME/.local/share/zinit/zinit.git/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

# Annexes (required to be loaded without Turbo)
zinit light-mode for \
    zdharma-continuum/zinit-annex-as-monitor \
    zdharma-continuum/zinit-annex-bin-gem-node \
    zdharma-continuum/zinit-annex-patch-dl \
    zdharma-continuum/zinit-annex-rust

# ─────────────────────────────────────────────────────────────────
# Prompt — Starship
# ─────────────────────────────────────────────────────────────────
zinit ice as"command" from"gh-r" \
          atclone"./starship init zsh > init.zsh; ./starship completions zsh > _starship" \
          atpull"%atclone" src"init.zsh"
zinit light starship/starship

# ─────────────────────────────────────────────────────────────────
# Snippets & plugins
#   Completion-registering snippets (git/aws/kubectl/…), the
#   completions plugin and fzf-tab all load before compinit so their
#   completions are picked up. They're cheap relative to compinit.
# ─────────────────────────────────────────────────────────────────
zinit snippet OMZP::git
zinit snippet OMZP::sudo
zinit snippet OMZP::aws
zinit snippet OMZP::kubectl
zinit snippet OMZP::kubectx
zinit snippet OMZP::command-not-found

zinit light zsh-users/zsh-completions
zinit light Aloxaf/fzf-tab

# ─────────────────────────────────────────────────────────────────
# Completion system
#   Reuse the cached dump and skip the (slow) security audit unless
#   the dump is stale (>24h). This is the single biggest startup win.
# ─────────────────────────────────────────────────────────────────
autoload -Uz compinit
if [[ -n ${ZDOTDIR:-$HOME}/.zcompdump(#qN.mh+24) ]]; then
  compinit            # dump older than 24h → rebuild + audit
else
  compinit -C         # fresh dump → skip audit, just source it
fi

# Interactive plugins — purely ZLE-based (no completions), so Turbo-load
# them right after the first prompt to keep them off the critical path.
# syntax-highlighting must come last so it wraps the final widget set.
zinit wait lucid for \
    atload"!_zsh_autosuggest_start" \
        zsh-users/zsh-autosuggestions \
    zsh-users/zsh-syntax-highlighting

# ─────────────────────────────────────────────────────────────────
# History
# ─────────────────────────────────────────────────────────────────
HISTSIZE=5000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
HISTDUP=erase
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups

# Arrow keys search history based on what's already typed
bindkey '^[[A' history-beginning-search-backward
bindkey '^[[B' history-beginning-search-forward

# ─────────────────────────────────────────────────────────────────
# Completion styling
# ─────────────────────────────────────────────────────────────────
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'

# ─────────────────────────────────────────────────────────────────
# Aliases
# ─────────────────────────────────────────────────────────────────
alias ls='ls --color'
alias vim='nvim'
alias c='clear'
alias gti="git"
alias gfm="git commit --amend -m"
alias gundo="git reset --soft HEAD~1"
# Checkout the repo's default branch (master, then main)
alias gcom='
  if git rev-parse --verify master >/dev/null 2>&1; then
    git checkout master
  elif git rev-parse --verify main >/dev/null 2>&1; then
    git checkout main
  else
    echo "No '\''master'\'' or '\''main'\'' branch found in the repository."
  fi
'
# Docker Compose
alias dc="docker-compose"
alias dcup="docker-compose up"
alias dcud="docker-compose up -d"
alias dcd="docker-compose down"
# zsh config
alias zconfig="code ~/.zshrc"
alias zsource="source ~/.zshrc"
# JS package hygiene
alias npmclean="rm -rf node_modules && rm package-lock.json && npm install"
alias yarnclean="rm -rf node_modules && rm package-lock.json && yarn install"
# Laravel Sail
alias sail='[ -f sail ] && sh sail || sh vendor/bin/sail'
# Claude Code
alias cc='claude --dangerously-skip-permissions'
# Claude Code: company account (separate creds/history in ~/.claude-work)
alias ccw='CLAUDE_CONFIG_DIR="$HOME/.claude-work" claude'

# ─────────────────────────────────────────────────────────────────
# Functions
# ─────────────────────────────────────────────────────────────────
# Download a video (best mp4) into ~/Documents/Videos/downloaded
ytd() {
  local clean_url="${1%%&list=*}"
  local output_dir="$HOME/Documents/Videos/downloaded"
  mkdir -p "$output_dir"
  uvx --from "git+https://github.com/yt-dlp/yt-dlp@master" yt-dlp \
    -f "bv*+ba/b" \
    -S "vcodec:h264,res,acodec:aac" \
    --merge-output-format mp4 \
    -o "$output_dir/%(title)s.%(ext)s" \
    "$clean_url"
}

# ─────────────────────────────────────────────────────────────────
# Tool integrations
# ─────────────────────────────────────────────────────────────────
# fzf — keybindings & completion
eval "$(fzf --zsh)"

# zoxide — smarter `cd`. Inside Claude Code keep the real `cd` builtin
# (its Bash tool relies on predictable navigation, and the override
# leaks in via the shell snapshot); everywhere else `cd` = zoxide.
# `z`/`zi` are available in both. Set DISABLE_ZOXIDE=1 to opt out.
if command -v zoxide >/dev/null 2>&1 && [[ -z "$DISABLE_ZOXIDE" ]]; then
  if [[ -n "$CLAUDECODE" ]]; then
    eval "$(zoxide init zsh)"
  else
    eval "$(zoxide init --cmd cd zsh)"
  fi
fi

# fnm — Node version manager (auto-switch on cd)
eval "$(fnm env --use-on-cd)"

# bun completions
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

# cargo / rust
[ -s "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"

# Vite+ (https://viteplus.dev)
[ -s "$HOME/.vite-plus/env" ] && . "$HOME/.vite-plus/env"

# git aliases
source ~/git-aliases.sh

# ─────────────────────────────────────────────────────────────────
# Environment & PATH
# ─────────────────────────────────────────────────────────────────
export BUN_INSTALL="$HOME/.bun"
export LOCAL="$HOME/.local"
export ANDROID_HOME="$HOME/Library/Android/sdk"
# Stable Homebrew symlink — avoids forking `/usr/libexec/java_home` each shell
export JAVA_HOME="/opt/homebrew/opt/openjdk@21/libexec/openjdk.jdk/Contents/Home"
export RUN_PRE_COMMIT_HOOK=true
export CLOUDSDK_PYTHON="/usr/bin/python3"

# Keep PATH free of duplicates (zsh syncs the `path` array with PATH)
typeset -U path PATH

export PATH="$JAVA_HOME/bin:$BUN_INSTALL/bin:$LOCAL/bin:$HOME/.composer/vendor/bin:$PATH"
export PATH="$ANDROID_HOME/platform-tools:$ANDROID_HOME/emulator:$PATH"
export PATH="$PATH:$HOME/.lmstudio/bin"
export PATH="$PATH:$HOME/.rvm/bin"   # keep RVM last per its requirement
path=( "${path[@]:#}" )              # drop empty elements (never put CWD in PATH)

# Per-directory environment overrides
if [ -f .env.local ]; then
    source .env.local
fi

# >>> grok installer >>>
export PATH="$HOME/.grok/bin:$PATH"
fpath=(~/.grok/completions/zsh $fpath)
autoload -Uz compinit && compinit -C
# <<< grok installer <<<
