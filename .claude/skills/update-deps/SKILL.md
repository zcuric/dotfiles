---
name: update-deps
description: Update dependencies in the repository
---
Update dependecies in the repository
- check what language and what package manager is being used 
- if multple languages are used, let's say different programming language for frontend and backend, prompt user which dependecies they want to update
- update to latest major dependencies if available, if not, update to minor or patch versions
- if there are multiple major depedencies updates, split each one in separete PRs
- for each dependency check the changelog, upgrade guide, documentation, use Context7 if available, if not use web search tool
- use codemons if available
- use upgrade guide to update the codebase
- run tests, linters, type checks
- automerging policy is automerge minor, add ^ to depedency file
- ask user for clarifications
