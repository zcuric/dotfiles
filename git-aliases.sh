# SCM Breeze Style Git Aliases
# Add to your ~/.bashrc or ~/.zshrc:
#   source ~/git-aliases.sh

# ============================================
# BASIC
# ============================================
alias g='git'
alias gs='git status'
alias gss='git status -s'
alias gst='git status'

# ============================================
# ADD
# ============================================
alias ga='git add'
alias gaa='git add -A'
alias gap='git add -p'
alias gau='git add -u'

# ============================================
# COMMIT
# ============================================
alias gc='git commit'
alias gcv='git commit --verbose'
alias gcm='git commit --amend'
alias gcmh='git commit --amend -C HEAD'
alias gch='git commit -C HEAD'
alias gcam='git commit -a -m'
alias gcmsg='git commit -m'

# ============================================
# CHECKOUT
# ============================================
alias gco='git checkout'
alias gcob='git checkout -b'
alias gcb='git checkout -b'
alias gcom='git checkout main'
alias gcoM='git checkout master'

# ============================================
# BRANCH
# ============================================
alias gb='git branch'
alias gba='git branch -a'
alias gbd='git branch -d'
alias gbD='git branch -D'
alias gbm='git branch -m'
alias gbr='git branch -r'

# ============================================
# DIFF
# ============================================
alias gd='git diff'
alias gdc='git diff --cached'
alias gdw='git diff --word-diff'
alias gdt='git difftool'
alias gdn='git diff --name-only'
alias gds='git diff --stat'

# ============================================
# LOG
# ============================================
alias gl="git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"
alias gla="git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --all"
alias glg='git log --graph --max-count=5'
alias gls='git log --stat --max-count=5'
alias glo='git log --oneline'
alias glp='git log -p'

# ============================================
# FETCH
# ============================================
alias gf='git fetch'
alias gfa='git fetch --all'
alias gfo='git fetch origin'

# ============================================
# PULL
# ============================================
alias gpl='git pull'
alias gplr='git pull --rebase'
alias gplo='git pull origin'
alias gplom='git pull origin main'
alias gploM='git pull origin master'

# ============================================
# PUSH
# ============================================
alias gps='git push'
alias gpsf='git push -f'
alias gpsu='git push -u origin HEAD'
alias gpso='git push origin'
alias gpsom='git push origin main'
alias gpsoM='git push origin master'

# ============================================
# REMOTE
# ============================================
alias gr='git remote -v'
alias gra='git remote add'
alias grr='git remote remove'
alias grs='git remote set-url'

# ============================================
# CLONE
# ============================================
alias gcl='git clone'
alias gcld='git clone --depth 1'

# ============================================
# MERGE
# ============================================
alias gm='git merge'
alias gmff='git merge --ff'
alias gmnff='git merge --no-ff'
alias gma='git merge --abort'

# ============================================
# REBASE
# ============================================
alias grb='git rebase'
alias grbi='git rebase -i'
alias grbc='git rebase --continue'
alias grba='git rebase --abort'
alias grbs='git rebase --skip'
alias grbm='git rebase main'
alias grbM='git rebase master'

# ============================================
# CHERRY-PICK
# ============================================
alias gcp='git cherry-pick'
alias gcpa='git cherry-pick --abort'
alias gcpc='git cherry-pick --continue'

# ============================================
# STASH
# ============================================
alias gash='git stash'
alias gasha='git stash apply'
alias gashl='git stash list'
alias gashp='git stash pop'
alias gashd='git stash drop'
alias gashs='git stash show -p'
alias gashb='git stash branch'

# ============================================
# RESET
# ============================================
alias grs='git reset'
alias grsh='git reset --hard'
alias grss='git reset --soft'
alias grsl='git reset HEAD~'
alias grsH='git reset --hard HEAD~'

# ============================================
# CLEAN
# ============================================
alias gce='git clean'
alias gcef='git clean -fd'
alias gcefd='git clean -fdx'
alias gcen='git clean -n'

# ============================================
# SHOW
# ============================================
alias gsh='git show'
alias gsm='git show --summary'
alias gsf='git show --stat'

# ============================================
# BLAME & TAG
# ============================================
alias gbl='git blame'
alias gt='git tag'
alias gta='git tag -a'
alias gtd='git tag -d'

# ============================================
# REMOVE
# ============================================
alias grm='git rm'
alias grmc='git rm --cached'

# ============================================
# COMBINED / POWER COMMANDS
# ============================================
alias gfr='git fetch && git rebase'
alias gpls='git pull && git push'
alias gac='git add -A && git commit'
alias gacm='git add -A && git commit -m'
alias gamend='git commit --amend --no-edit'
alias gundo='git reset --soft HEAD~1'
alias gunstage='git reset HEAD --'
alias gdiscard='git checkout -- .'
alias gforce='git add -A && git commit --amend -C HEAD && git push -f'

# ============================================
# INFO
# ============================================
alias gcurrent='git rev-parse --abbrev-ref HEAD'
alias grecent='git for-each-ref --sort=-committerdate refs/heads/ --format="%(committerdate:short) %(refname:short)"'
alias glast='git diff-tree --no-commit-id --name-only -r HEAD'
alias gcount='git shortlog -sn'
alias gtree='git log --graph --oneline --all --decorate'
alias galiases='git config --get-regexp alias'

# ============================================
# WORKFLOW HELPERS
# ============================================
alias gfeature='git checkout -b feature/'
alias gbugfix='git checkout -b bugfix/'
alias ghotfix='git checkout -b hotfix/'

# ============================================
# SUBMODULES
# ============================================
alias gsub='git submodule update --init --recursive'
alias gplsub='git pull && git submodule update --init --recursive'

# ============================================
# WORKTREE
# ============================================
alias gwt='git worktree'
alias gwta='git worktree add'
alias gwtl='git worktree list'
alias gwtr='git worktree remove'
