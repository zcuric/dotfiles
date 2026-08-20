---
name: cherry-pick-to-stage
description: Cherry-pick the current branch's commits onto stage and push.
---
Cherry-pick the commits from the current working branch onto `stage` and push.

Steps:
1. Determine the commits to cherry-pick. Default to commits unique to the current branch versus `main` (`git log main..HEAD --oneline`). If the user named specific commit hashes in their request, use those instead.
2. Remember the current branch name so you can return to it after.
3. `git fetch origin stage`.
4. `git checkout stage`.
5. `git pull origin stage` (fast-forward; abort and ask the user if it can't fast-forward).
6. `git cherry-pick <hashes>` in original order. If a conflict occurs, stop and ask the user — do not run `git cherry-pick --abort` or any destructive recovery without permission.
7. `git push origin stage`.
8. Switch back to the original branch with `git checkout -`.
9. Report the new commit hashes on `stage` and the PR/branch they came from.

Rules:
- Never force-push `stage`.
- Never skip hooks or signing.
- If `stage` is the current branch when invoked, ask the user which branch's commits to cherry-pick — do not assume.
- If the cherry-pick is empty (commits already on stage), report that and stop; don't push an empty change.
