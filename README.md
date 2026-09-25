# apm-example

The template repo from **The SETUP guide**.

Your team's AI workflow in one folder. Reviewed like code. Deployed to the AI tools your team uses.

Clone it and try it. Or copy the parts you need into your own repo.

> [!IMPORTANT]
> **Everything in `ai/.apm/` is an example to get you started. It is not meant for production.**
>
> The rules, skills, agent and hooks show the shape and the plumbing. They are written for a made-up shop called `acme-shop`, with a `web/` and a `backend/` folder that don't really exist. The skills call commands like `make lint test` that this repo doesn't have.
>
> Replace them with your team's own conventions and workflows. Test every hook in every tool your team uses. And treat the hooks as a safety net, not a security boundary: a determined agent or person can always get around them.

## What's in it

- **4 example rules:** web testing, backend code style, git workflow, and how to change the AI config itself.
- **4 example skills:** `/create-pr`, `/review-pr`, `/release` and `/ai-config`.
- **1 example agent:** a read-only `test-reviewer`.
- **2 example hooks:** one blocks edits to generated folders, one blocks destructive commands.
- **The plumbing:** a sync script, git hooks, a cloud-agent bootstrap, a check script and hook tests.

## Try it in 2 minutes

You need `git`, `make`, `jq` and [APM](https://github.com/microsoft/apm) 0.31.0. The installer below installs exactly that version:

```bash
curl -sSL https://aka.ms/apm-unix | sh -s -- @v0.31.0
git clone https://github.com/jordyvanvorselen/apm-example.git
cd apm-example
make setup
make check
make test-hooks
```

On Linux, APM also needs `libsqlite3` (`apt-get install libsqlite3-0`).

Now open Claude Code in this folder and ask:

> Read `web/src/Button.test.tsx`. Which project rules loaded because of that file?

It should name the web testing rule. `web/src/Button.test.tsx` is a sample file, only there to show a scoped rule load.

## What works in which tool

Tested on 2026-09-25 with APM 0.31.0, Claude Code 2.1.281, Codex CLI 0.154.0 and pi 0.87.1. Cursor was not available to test.

| | Claude Code | Codex | Cursor | pi |
|---|---|---|---|---|
| **Skills** | Works | Works | Deployed, not tested | Works |
| **Scoped rules** | Works | Not supported. Codex reads `AGENTS.md` only. | Deployed as `.mdc` rules, not tested | Not supported. pi reads `AGENTS.md` only. |
| **Hooks** | Works | Works, after you trust them (see below) | Doesn't work yet (see below) | Not supported |
| **Agents** | Works | Deployed. Codex drops the `tools` restriction. | Deployed, not tested | Not supported |
| **`AGENTS.md`** | Works | Works | Works | Works |

"Works" means we saw it happen in the tool: a rule loaded, a skill was listed, a hook blocked a real tool call, an agent was dispatched.

### Codex: trust the hooks once

Codex only runs project hooks you have trusted. Until then, it skips them without a warning.

Start `codex` interactively in the repo. It shows **Hooks need review** at startup. Review the hooks, then trust them. You can also do this later with `/hooks`, or in the Codex app under **Settings → Hooks**.

Every change to a hook needs a new review. Check it after every pull that changes `ai/.apm/hooks/`.

### Cursor: hooks don't work yet

APM 0.31.0 writes the hooks into `.cursor/hooks.json` in Claude Code's format. Cursor uses different event names, so it ignores them. See [microsoft/apm#2321](https://github.com/microsoft/apm/issues/2321).

Newer Cursor versions can also load Claude Code hooks from `.claude/settings.json`. We haven't tested that.

## Add it to your own repo

1. Copy `ai/`, `apm.yml`, `.githooks/`, `.cursor/environment.json`, `.github/CODEOWNERS` and `.github/pull_request_template.md`.
2. Copy the `Makefile` targets, or call `ai/sync.sh` from your own setup command.
3. Add `apm 0.31.0` to your `.tool-versions`.
4. Add the lines from `.gitignore` to yours.
5. Rename `acme-shop` in both `apm.yml` files.
6. Replace the example rules, skills, agent and hooks in `ai/.apm/` with your own.
7. Put real owners in `.github/CODEOWNERS`.
8. Run `make setup`, `make check` and `make test-hooks`.

Start with 5 items your team uses every week. Not 50.

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
| `ai/sync.sh` | Deploys everything. Runs after every pull, branch switch and rebase. |
| `ai/check.sh` | The automatic part of the Monday test. |
| `ai/test-hooks.sh` | Tests every hook against commands and edits it must block or allow. |
| `ai/setup-cloud-agent.sh` | Gives cloud agents the same config as the team. |
| `.githooks/` | Calls `ai/sync.sh` after `git pull`, `git checkout` of a branch, and `git rebase`. |
| `web/src/Button.test.tsx` | A sample file that makes the web testing rule load. |

The team edits `ai/.apm/` only. APM generates `.claude/`, `.cursor/`, `.codex/` and `.agents/`. Nobody edits those by hand, and they are never committed.

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
| 1. People edited the generated copies. The next install overwrote their work. | A hook blocks edits to generated folders, from edit tools, Codex patches and shell commands. It points to the source. | `ai/.apm/hooks/block-generated-edits.json` |
| 2. A missing APM install failed silently. Agents ran without team rules. | The sync script prints a loud warning with the install command. `make check` fails. | `ai/sync.sh`, `ai/check.sh` |
| 3. Running APM from a git hook damaged the checkout. | Git passes `GIT_DIR` and friends to hooks. APM's git downloads inherited them and wrote into the repo. The sync script unsets them around `apm install`. | `ai/sync.sh` |
| 4. Deleted skills kept loading on other laptops. | The sync script keeps the lockfile of the previous sync, and removes every deployed path the new lockfile dropped. | `ai/sync.sh` |
| 5. Agents ignored the rules that mattered most. | Turn those rules into hooks, and test them. | `ai/.apm/hooks/`, `ai/test-hooks.sh` |
| 6. Skills never triggered, because of how their descriptions were written. | One short sentence: when to use it, and when not to. | Every `SKILL.md`, and the `/ai-config` skill |
| 7. Old rules contradicted new ones and kept teaching old behaviour. | Every rule has an owner. The pull request template asks if a rule needs to change too. | `.github/CODEOWNERS`, `.github/pull_request_template.md` |
| 8. Cloud agents started without any team configuration. | A bootstrap script installs the pinned APM version and deploys. Cursor runs it through `environment.json`. | `ai/setup-cloud-agent.sh`, `.cursor/environment.json` |

## The Monday test

Your most experienced engineer left on Friday. It's Monday. Does the workflow still work?

`make check` does the automatic part. It checks that APM and `jq` are installed, that the APM version matches, that git hooks deploy on every pull, and that the config is deployed.

Then check the rest by hand, in your own repo, on a fresh laptop:

- [ ] Their agent loads your testing rule when it reads a test file.
- [ ] Your `/create-pr` skill works from start to finish.
- [ ] Asking the agent to edit a file in `.claude/rules/` gets blocked.
- [ ] Their own AI tool sees the same skills as everyone else's.
- [ ] They can find the owner of each rule in `.github/CODEOWNERS`.

Check the table in "What works in which tool" first. Not every box can pass in every tool yet.

## Good to know

- **Why not commit the generated folders?** The APM docs suggest you do. We don't. One source of truth, no merge conflicts in generated files, and nobody edits a copy by accident. The price: a fresh clone has nothing until `make setup` runs. The git hooks take care of every pull after that.
- **Two APM warnings are expected on every sync.** `Policy repo <owner>/.github-private not found` means APM looked for an optional organization policy and found none. `lossy agent compilation warning` means Codex drops the agent's `tools` list. Neither stops the deploy. The sync ends with `[apm] Done`.
- **Hooks need `jq`.** Without it, they can't read the tool call. `make check` tests for it.
- **The hook tests check the logic, not the tools.** `make test-hooks` feeds each hook sample tool calls. Still try each hook once in each tool your team uses.
- **Pin external packages.** `apm.yml` pins `apm-guide` to a tag. Update on purpose, in its own pull request.
- **Pin APM itself.** `make check` fails when your APM version differs from `.tool-versions`. Upgrade on purpose, for the whole team at once.
- **A global `.gitignore` can hide files.** If yours ignores `.tool-versions`, this repo's `.gitignore` un-ignores it.

## Want help with this?

I'm Jordy van Vorselen. I help AI-native software teams deliver faster, with fewer defects at the same time.

Questions, a short project, or long-term collaboration: [jordy@vanvorselen.com](mailto:jordy@vanvorselen.com) · [LinkedIn](https://www.linkedin.com/in/jordy-van-vorselen/) · [www.jordyvanvorselen.com](https://www.jordyvanvorselen.com)

## License

MIT
