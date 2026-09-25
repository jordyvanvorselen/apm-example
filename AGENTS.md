# acme-shop

An example repo. It shows how a team shares its AI rules, skills, agents and hooks. The project described below, `acme-shop`, is made up.

An online shop. `web/` is the storefront (React, TypeScript). `backend/` is the API.

## Commands

- `make setup` installs git hooks and deploys the team's AI config
- `make check` checks that the AI config is installed and deployed
- `make test-hooks` tests the hooks
- `make lint test` is an example command the skills use. This repo doesn't have it.

## Working agreements

- AI configuration lives in `ai/.apm/`. Never edit `.claude/`, `.cursor/`, `.codex/` or `.agents/`: they are generated.
- Every change in behaviour comes with a test.
- Small pull requests, one reason to change each.

Rules for specific files load when you touch those files. Workflows are skills: `/create-pr`, `/review-pr`, `/release`, `/ai-config`.
