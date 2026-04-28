
### Added by Zinit's installer
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

# Load a few important annexes, without Turbo
# (this is currently required for annexes)
zinit light-mode for \
    zdharma-continuum/zinit-annex-as-monitor \
    zdharma-continuum/zinit-annex-bin-gem-node \
    zdharma-continuum/zinit-annex-patch-dl \
    zdharma-continuum/zinit-annex-rust

zinit ice as"command" from"gh-r" \
          atclone"./starship init zsh > init.zsh; ./starship completions zsh > _starship" \
          atpull"%atclone" src"init.zsh"
zinit light starship/starship

# Add in snippets
zinit snippet OMZP::git
zinit snippet OMZP::sudo
zinit snippet OMZP::aws
zinit snippet OMZP::kubectl
zinit snippet OMZP::kubectx
zinit snippet OMZP::command-not-found

# Load zsh plugins
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit light Aloxaf/fzf-tab

# Load completions
autoload -U compinit && compinit

# Arrow keys search history based on what's typed
bindkey '^[[A' history-beginning-search-backward
bindkey '^[[B' history-beginning-search-forward

# History
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

# Completion styling
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'

# Aliases
alias ls='ls --color'
alias vim='nvim'
alias c='clear'
alias gcom='
  if git rev-parse --verify master >/dev/null 2>&1; then
    git checkout master
  elif git rev-parse --verify main >/dev/null 2>&1; then
    git checkout main
  else
    echo "No 'master' or 'main' branch found in the repository."
  fi
'
alias gti="git"
alias gfm="git commit --amend -m"
alias gundo="git reset --soft HEAD~1"
alias dc="docker-compose"
alias dcup="docker-compose up"
alias dcud="docker-compose up -d"
alias dcd="docker-compose down"
alias zconfig="code ~/.zshrc "
alias zsource="source ~/.zshrc "
alias npmclean="rm -rf node_modules && rm package-lock.json && npm install"
alias yarnclean="rm -rf node_modules && rm package-lock.json && yarn install"
# Laravel Sail
alias sail='[ -f sail ] && sh sail || sh vendor/bin/sail'
alias cc='claude --dangerously-skip-permissions'
# Shell integrations
eval "$(fzf --zsh)"
if [ -z "$DISABLE_ZOXIDE" ]; then
    eval "$(zoxide init --cmd cd zsh)"
fi
eval "$(fnm env --use-on-cd)"

[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

export BUN_INSTALL="$HOME/.bun"
export LOCAL="$HOME/.local"
export PATH="$BUN_INSTALL/bin:$LOCAL/bin:$PATH::$HOME/.composer/vendor/bin"
# Add RVM to PATH for scripting. Make sure this is the last PATH variable change.
export PATH="$PATH:$HOME/.rvm/bin"
export RUN_PRE_COMMIT_HOOK=true
export CLOUDSDK_PYTHON="/usr/bin/python3"

. "$HOME/.cargo/env"

# Added by LM Studio CLI (lms)
export PATH="$PATH:$HOME/.lmstudio/bin"

# bun completions
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

ytd() {
  clean_url="${1%%\?*}"
  output_dir="$HOME/Documents/Videos/downloaded"

  mkdir -p "$output_dir"

  uvx yt-dlp \
    -f "bv*[ext=mp4]+ba[ext=m4a]/bv*+ba/best" \
    --merge-output-format mp4 \
    -o "$output_dir/%(title)s.%(ext)s" \
    "$clean_url"
}


source ~/git-aliases.sh
# Add to ~/.zshrc
if [ -f .env.local ]; then
    source .env.local
fi

# Added by LM Studio CLI (lms)
export PATH="$PATH:/Users/zdravko/.lmstudio/bin"
# End of LM Studio CLI section

export JAVA_HOME=$(/usr/libexec/java_home -v 21)
export PATH="$JAVA_HOME/bin:$PATH"
export ANDROID_HOME="$HOME/Library/Android/sdk"
export PATH="$ANDROID_HOME/platform-tools:$ANDROID_HOME/emulator:$PATH"
