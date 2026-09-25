---
description: Branches, commits and pull requests
applyTo: "**"
---

# Git workflow

- Branch from `main`. Name it `feature/<short-description>` or `fix/<short-description>`.
- Write commits as conventional commits: `feat(billing): add invoice export`, `fix(auth): refresh expired tokens`.
- Rebase on `main` to update a branch. Never merge `main` into it.
- Keep pull requests small. One reason to change per pull request.
- Never commit to `main` directly, and never force-push it.
