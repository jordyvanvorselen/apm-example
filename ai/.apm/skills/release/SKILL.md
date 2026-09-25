---
name: release
description: Cut a release from main, with changelog and tag. Not for deploying a branch.
---

# Release

1. Check you are on an up-to-date `main`: `git switch main && git pull --rebase`.
2. Check the build is green: `gh run list --branch main --limit 1`. Stop if it is not.
3. Find the last tag: `git describe --tags --abbrev=0`.
4. Pick the next version from the commits since that tag. Any `feat` means a minor bump. Only `fix` means a patch bump. A breaking change means a major bump.
5. Write the changelog from the commits since the last tag. Group by feature and fix. Write each line for a user, not for a developer.
6. Show the version and the changelog to the user. Wait for a yes.
7. Tag and publish: `git tag v<version> && git push origin v<version>`, then `gh release create v<version> --notes-file <changelog>`.
