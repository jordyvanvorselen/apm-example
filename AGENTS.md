# acme-shop

An online shop. `web/` is the storefront (React, TypeScript). `backend/` is the API.

## Commands

- `make setup` installs git hooks and deploys the team's AI config
- `make lint test` runs every check a pull request needs

## Working agreements

- AI configuration lives in `ai/.apm/`. Never edit `.claude/`, `.cursor/`, `.codex/` or `.agents/`: they are generated.
- Every change in behaviour comes with a test.
- Small pull requests, one reason to change each.

Rules for specific files load when you touch those files. Workflows are skills: `/create-pr`, `/review-pr`, `/release`, `/ai-config`.
