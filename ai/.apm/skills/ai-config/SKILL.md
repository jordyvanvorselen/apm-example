---
name: ai-config
description: Decide where a new rule, skill, agent or hook goes in ai/.apm/, and add it.
---

# Add to the team's AI config

## Where does it go?

Ask these questions in order. Stop at the first yes.

| # | Question | Put it in |
|---|---|---|
| 0 | Is it one person's preference? | Their home folder, not the repo |
| 1 | Does it connect to an outside tool, like a database or issue tracker? | An MCP server in `apm.yml` |
| 2 | Must it happen every time, without exception? | A hook in `ai/.apm/hooks/` |
| 3 | Does it need its own context, or limited tools? | An agent in `ai/.apm/agents/` |
| 4 | Is it a repeatable workflow, or knowledge needed only sometimes? | A skill in `ai/.apm/skills/` |
| 5 | Does it apply only to certain files or folders? | A rule in `ai/.apm/instructions/` |
| 6 | Is it true for the whole project, on every task? | `AGENTS.md` |

## How to write it

- **Rule:** `<topic>.instructions.md` with `description` and the narrowest `applyTo` glob that works. One idea per line. Add one good and one bad example.
- **Skill:** `<name>/SKILL.md` under 500 lines. Long reference material goes in `<name>/references/`. The description is one sentence: when to use it, and when not to.
- **Agent:** `<name>.agent.md` with the smallest `tools` list that does the job.
- **Hook:** `<name>.json`. Exit code 2 blocks the tool call and shows the message to the agent. Add cases to `ai/test-hooks.sh` and run it.

## Then

1. Run `ai/sync.sh` and check the new piece shows up in `.claude/` and `.agents/skills/`.
2. Add an owner for it in `.github/CODEOWNERS`.
3. Open a pull request with the `create-pr` skill.
