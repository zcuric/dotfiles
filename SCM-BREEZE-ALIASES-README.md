# SCM Breeze Git Aliases - Quick Reference

## Installation

Add to your existing `~/.gitconfig`:

```bash
# Option 1: Include the file
git config --global include.path "~/.gitconfig-scm-breeze-aliases"

# Option 2: Copy the [alias] section into your existing ~/.gitconfig
```

Or use the shell command to add all aliases at once:

```bash
# Copy this file to your home directory first, then:
cat ~/.gitconfig-scm-breeze-aliases >> ~/.gitconfig
```

---

## Quick Reference Card

### Status & Add
| Alias | Command | Description |
|-------|---------|-------------|
| `git st` | `git status` | Show status |
| `git ss` | `git status -s` | Short status |
| `git aa` | `git add -A` | Add all files |
| `git ap` | `git add -p` | Interactive add |
| `git au` | `git add -u` | Add tracked files |

### Commit
| Alias | Command | Description |
|-------|---------|-------------|
| `git c` | `git commit` | Commit |
| `git cv` | `git commit --verbose` | Commit with diff |
| `git cm` | `git commit --amend` | Amend last commit |
| `git cmh` | `git commit --amend -C HEAD` | Amend, keep message |
| `git ac` | `git add -A && commit` | Add all & commit |
| `git acm "msg"` | Add all & commit with message |

### Branch
| Alias | Command | Description |
|-------|---------|-------------|
| `git b` | `git branch` | List branches |
| `git ba` | `git branch -a` | All branches |
| `git bd name` | `git branch -d` | Delete branch |
| `git bD name` | `git branch -D` | Force delete |
| `git bm old new` | `git branch -m` | Rename branch |
| `git co name` | `git checkout` | Switch branch |
| `git cob name` | `git checkout -b` | Create & switch |

### Diff & Log
| Alias | Command | Description |
|-------|---------|-------------|
| `git d` | `git diff` | Show changes |
| `git dc` | `git diff --cached` | Staged changes |
| `git dw` | `git diff --word-diff` | Word diff |
| `git l` | Pretty log graph | Colored log |
| `git la` | Log all branches | All branches |
| `git tree` | Log graph oneline | Simple tree |

### Remote Operations
| Alias | Command | Description |
|-------|---------|-------------|
| `git f` | `git fetch` | Fetch |
| `git fa` | `git fetch --all` | Fetch all |
| `git pl` | `git pull` | Pull |
| `git ps` | `git push` | Push |
| `git psf` | `git push -f` | Force push |
| `git psu` | `git push -u origin HEAD` | Push & set upstream |
| `git r` | `git remote -v` | List remotes |

### Rebase & Merge
| Alias | Command | Description |
|-------|---------|-------------|
| `git rb` | `git rebase` | Rebase |
| `git rbi` | `git rebase -i` | Interactive rebase |
| `git rbc` | `git rebase --continue` | Continue rebase |
| `git rba` | `git rebase --abort` | Abort rebase |
| `git m` | `git merge` | Merge |
| `git mnff` | `git merge --no-ff` | Merge no fast-forward |
| `git cp` | `git cherry-pick` | Cherry-pick |

### Stash
| Alias | Command | Description |
|-------|---------|-------------|
| `git ash` | `git stash` | Stash changes |
| `git ashp` | `git stash pop` | Pop stash |
| `git asha` | `git stash apply` | Apply stash |
| `git ashl` | `git stash list` | List stashes |
| `git ashs` | `git stash show -p` | Show stash diff |

### Reset & Undo
| Alias | Command | Description |
|-------|---------|-------------|
| `git rs` | `git reset` | Reset |
| `git rsh` | `git reset --hard` | Hard reset |
| `git rsl` | `git reset HEAD~` | Undo last commit |
| `git undo` | `git reset --soft HEAD~1` | Undo, keep staged |
| `git unstage` | `git reset HEAD --` | Unstage all |
| `git discard` | `git checkout -- .` | Discard changes |

### Power Commands
| Alias | Command | Description |
|-------|---------|-------------|
| `git fr` | `git fetch && rebase` | Fetch & rebase |
| `git pls` | `git pull && push` | Pull then push |
| `git gforce` | Add, amend, force push | ⚠️ Dangerous! |
| `git rib N` | `rebase -i HEAD~N` | Rebase last N commits |
| `git squash N` | Squash last N commits |

### Workflow Helpers
| Alias | Command | Description |
|-------|---------|-------------|
| `git feature name` | Create feature/name branch |
| `git bugfix name` | Create bugfix/name branch |
| `git hotfix name` | Create hotfix/name branch |
| `git recent` | List branches by date |
| `git last` | Files in last commit |
| `git aliases` | List all aliases |

---

## What's NOT Included (SCM Breeze-specific features)

These SCM Breeze features require shell integration and can't be replicated as git aliases:

1. **Numbered file shortcuts** (`$e1`, `$e2`, etc.) - Requires shell environment variables
2. **`gs` with numbered output** - Uses a custom shell function
3. **`ga 1 2 3`** - Number-based file adding
4. **Repository index** (`c` command for quick switching)
5. **Keyboard bindings** (Ctrl+x c, etc.)

For these features, you'll need to install SCM Breeze itself or use alternatives like:
- [scmpuff](https://github.com/mroth/scmpuff) - A Go binary alternative
- [breeze](https://github.com/shinriyo/breeze) - Fish shell version

---

## Shell Aliases (Optional)

If you want even shorter commands, add these to your `~/.bashrc` or `~/.zshrc`:

```bash
# Single letter shortcuts
alias g='git'
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gd='git diff'
alias gl='git log --oneline -10'
alias gp='git push'
alias gpl='git pull'
alias gco='git checkout'
alias gb='git branch'
alias gm='git merge'
alias grb='git rebase'
alias gst='git stash'
```

---

Enjoy your streamlined Git workflow! 🚀
