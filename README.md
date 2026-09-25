# apm-example

The template repo from **The SETUP guide**.

Your team's AI workflow in one folder. Reviewed like code. Deployed to every AI tool your team uses.

Clone it and try it. Or copy the parts you need into your own repo.

## What's in it

- **4 rules:** web testing, backend code style, git workflow, and how to change the AI config itself.
- **4 skills:** `/create-pr`, `/review-pr`, `/release` and `/ai-config`.
- **1 agent:** a read-only `test-reviewer`.
- **2 hooks:** one blocks edits to generated folders, one blocks destructive commands.
- **The plumbing:** a sync script, git hooks, a cloud-agent bootstrap and a check script.

One `git pull` deploys all of it to Claude Code, Cursor, Codex and pi.

## Try it in 2 minutes

You need `git`, `make`, `jq` and [APM](https://github.com/microsoft/apm) 0.31.0:

```bash
brew install microsoft/apm/apm jq
git clone https://github.com/jordyvanvorselen/apm-example.git
cd apm-example
make setup
make check
```

Now open your AI tool in this folder and ask: *"Which rules apply when you edit `web/src/Button.test.tsx`?"*

Does it name the web testing rule? It works.

## Add it to your own repo

1. Copy `ai/`, `apm.yml`, `.githooks/`, `.cursor/environment.json`, `.github/CODEOWNERS` and `.github/pull_request_template.md`.
2. Copy the `Makefile` targets, or call `ai/sync.sh` from your own setup command.
3. Add `apm 0.31.0` to your `.tool-versions`.
4. Add the lines from `.gitignore` to yours.
5. Rename `acme-shop` in both `apm.yml` files.
6. Change the `applyTo` globs in `ai/.apm/instructions/` to match your folders.
7. Put real owners in `.github/CODEOWNERS`.
8. Run `make setup`, then `make check`.

Then delete what you don't need. Start with 5 items your team uses every week. Not 50.

## The layout

| Path | What it does |
|---|---|
| `apm.yml` | Which packages go to which AI tools |
| `apm.lock.yaml` | Exact package versions. Commit it. |
| `AGENTS.md` | Short project context. Every agent reads it on every task. |
| `ai/.apm/instructions/` | **Rules.** Conventions for certain files, scoped with `applyTo`. |
| `ai/.apm/skills/` | **Skills.** Workflows the agent runs on request. |
| `ai/.apm/agents/` | **Agents.** Specialists with their own context and limited tools. |
| `ai/.apm/hooks/` | **Hooks.** Scripts that run on every tool call and can block it. |
| `ai/sync.sh` | Deploys everything. Runs after every pull, checkout and rebase. |
| `ai/check.sh` | The automatic part of the Monday test. |
| `ai/test-hooks.sh` | Tests every hook against inputs it must block or allow. |
| `ai/setup-cloud-agent.sh` | Gives cloud agents the same config as the team. |
| `.githooks/` | Calls `ai/sync.sh` after `git pull`, `git checkout` and `git rebase`. |

The team edits `ai/.apm/` only. APM generates `.claude/`, `.cursor/`, `.codex/` and `.agents/`. Those are never edited by hand and never committed.

## Where does a new piece go?

Ask the `/ai-config` skill. Or ask these questions yourself, in order. Stop at the first yes.

0. Is it one person's preference? **Their home folder.** Not the repo.
1. Does it connect to an outside tool? **An MCP server** in `apm.yml`.
2. Must it happen every time, without exception? **A hook.**
3. Does it need its own context, or limited tools? **An agent.**
4. Is it a repeatable workflow, or knowledge needed only sometimes? **A skill.**
5. Does it apply only to certain files? **A rule.**
6. Is it true for the whole project, on every task? **`AGENTS.md`.**

Remember one thing? Make it this one: **rules advise, hooks enforce.** An agent can ignore a rule. It can't ignore a hook.

## The 8 mistakes, and where the fix lives

| Mistake | Fix | Where |
|---|---|---|
| 1. People edited the generated copies. The next install overwrote their work. | A hook blocks edits to generated folders and points to the source. | `ai/.apm/hooks/block-generated-edits.json` |
| 2. A missing APM install failed silently. Agents ran without team rules. | The sync script prints a loud warning. `make check` fails. | `ai/sync.sh`, `ai/check.sh` |
| 3. Running APM from a git hook damaged the checkout. | Git passes `GIT_DIR` and friends to hooks. APM's git downloads inherited them and wrote into the repo. The sync script unsets them around `apm install`. | `ai/sync.sh` |
| 4. Deleted skills kept loading on other laptops. | The sync script keeps the lockfile of the previous sync, and removes every deployed path the new lockfile dropped. | `ai/sync.sh` |
| 5. Agents ignored the rules that mattered most. | Turn those rules into hooks, and test them. | `ai/.apm/hooks/`, `ai/test-hooks.sh` |
| 6. Skills never triggered, because of how their descriptions were written. | One short sentence: when to use it, and when not to. | Every `SKILL.md`, and the `/ai-config` skill |
| 7. Old rules contradicted new ones and kept teaching old behaviour. | Every rule has an owner. The pull request template asks if a rule needs to change too. | `.github/CODEOWNERS`, `.github/pull_request_template.md` |
| 8. Cloud agents started without any team configuration. | A bootstrap script installs the pinned APM version and deploys. Cursor runs it through `environment.json`. | `ai/setup-cloud-agent.sh`, `.cursor/environment.json` |

## The Monday test

Your most experienced engineer left on Friday. It's Monday. Does the workflow still work?

`make check` does the automatic part. It checks that APM and `jq` are installed, that the APM version matches, that git hooks deploy on every pull, and that the config is deployed.

Then check the rest by hand, on a fresh laptop:

- [ ] Their agent loads the web testing rule when it edits a test file.
- [ ] `/create-pr` works from start to finish.
- [ ] Asking the agent to edit `.claude/rules/web-testing.md` gets blocked.
- [ ] Their own AI tool sees the same skills as everyone else's.
- [ ] They can find the owner of each rule in `.github/CODEOWNERS`.

## Good to know

- **Why not commit the generated folders?** The APM docs suggest you do. We don't. One source of truth, no merge conflicts in generated files, and nobody edits a copy by accident. The price: a fresh clone has nothing until `make setup` runs. The git hooks take care of every pull after that.
- **Test your hooks in every tool.** Hook support differs per tool. `make test-hooks` checks the logic. Try each hook once in each tool your team uses.
- **Codex has no scoped rules.** It reads `AGENTS.md`. APM offers `apm compile` to fold the rules into `AGENTS.md`. This repo keeps `AGENTS.md` hand-written and short instead.
- **Codex ignores the `tools` list on agents.** APM warns about this on install. The `test-reviewer` agent can use every tool in Codex.
- **pi** reads the shared skills in `.agents/skills/` and `AGENTS.md`.
- **Pin external packages.** `apm.yml` pins `apm-guide` to a tag. Update on purpose, in its own pull request.
- **A global `.gitignore` can hide files.** If yours ignores `.tool-versions`, this repo's `.gitignore` un-ignores it.

## Want help with this?

I'm Jordy van Vorselen. I help AI-native software teams deliver faster, with fewer defects at the same time.

Questions, a short project, or long-term collaboration: [jordy@vanvorselen.com](mailto:jordy@vanvorselen.com) · [LinkedIn](https://www.linkedin.com/in/jordy-van-vorselen/) · [jordyvanvorselen.com](https://jordyvanvorselen.com)

## License

MIT
