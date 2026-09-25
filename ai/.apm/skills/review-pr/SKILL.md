---
name: review-pr
description: Review a pull request against the team's rules. Not for writing code. Use create-pr to open one.
---

# Review a pull request

1. Get the diff: `gh pr diff <number>`, or `git diff main...HEAD` for the current branch.
2. List the rules in `ai/.apm/instructions/` whose `applyTo` matches a changed file. Check the diff against each one.
3. Send the diff to the `test-reviewer` agent. Add its findings.
4. Report findings in three groups: **must fix**, **should fix**, **question**. Each finding names the file, the line and the rule it breaks.
5. Found the same problem twice? Suggest a new rule for `ai/.apm/instructions/`.
6. Do not post comments on GitHub unless the user asks.
