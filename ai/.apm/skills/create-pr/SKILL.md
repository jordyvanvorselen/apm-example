---
name: create-pr
description: Open or update a pull request for the current branch. Use as the last step of a finished task.
---

# Create a pull request

1. If the current branch is `main`, stop and ask the user which branch to create.
2. Run the checks: `make lint test`. Fix every failure before you continue.
3. Write the title as a conventional commit: `feat(billing): add invoice export`.
4. Fill the body with the template in `references/pr-body.md`.
5. If a pull request exists for this branch, update its title and body with `gh pr edit`. Otherwise run `gh pr create --draft`.
6. Share the link with the user.
