---
description: Where AI configuration lives and how to change it
applyTo: "{ai/**,AGENTS.md,apm.yml}"
---

# AI configuration

- `ai/.apm/` is the only source of truth. Rules go in `instructions/`, skills in `skills/`, agents in `agents/`, hooks in `hooks/`.
- Never edit `.claude/`, `.cursor/`, `.codex/` or `.agents/`. APM generates them and overwrites them on the next pull.
- After a change, run `ai/sync.sh` to deploy it, and `ai/test-hooks.sh` if you changed a hook.
- Unsure where a new piece belongs? Use the `ai-config` skill.
- Changing a team convention? Change its rule in the same pull request.
