---
name: github-local
description: Use when working with Git or GitHub on Alessandro's Windows machine, especially commands involving gh, git pull, git push, branches, forks, pull requests, GitHub Actions, CI logs, or authentication setup. Provides machine-specific details for the installed GitHub CLI and Codex sandbox approval behavior.
---

# GitHub Local

## Machine Setup

- Git is installed and available as `git`.
- GitHub CLI is installed and available as `gh`.
- The executable path is `C:\Program Files\GitHub CLI\gh.exe`.
- `gh` is authenticated to GitHub as `aledinola`.
- `gh auth status` should report HTTPS git protocol and token scopes including `repo`, `workflow`, and `read:org`.
- Git is configured to use GitHub CLI as the GitHub credential helper:

```powershell
git config --global --get credential.https://github.com.helper
```

Expected value:

```text
!'C:\Program Files\GitHub CLI\gh.exe' auth git-credential
```

## Verification Commands

Use these when checking the setup:

```powershell
gh --version
Get-Command gh
gh auth status
gh api user --jq .login
git config --global --get user.name
git config --global --get user.email
git config --global --get credential.https://github.com.helper
```

If plain `gh` unexpectedly fails, use the full path:

```powershell
& 'C:\Program Files\GitHub CLI\gh.exe' --version
```

## Codex Sandbox Notes

Codex can execute `gh` and `git`, but network operations may require approval by command prefix. This is normal sandbox behavior, not a GitHub configuration problem.

Common commands that may need approval the first time:

```powershell
git fetch
git pull
git push
gh api ...
gh pr ...
gh repo ...
gh run ...
```

When a network command fails with socket, DNS, permission, or sandbox-like errors, rerun it with escalated permissions and a concise justification. Prefer a scoped prefix rule such as `["gh", "pr"]`, `["gh", "run"]`, `["git", "push"]`, or `["git", "pull"]`.

## Preferred Workflow

- Use local `git` for status, branches, commits, pulls, and pushes.
- Use `gh` for current-branch PR discovery, PR creation, GitHub Actions checks/logs, and GitHub API gaps.
- Use the Codex GitHub connector for structured PR, issue, comment, review, and repository metadata when available.
- Keep local repo state and GitHub connector state aligned before mutating branches or PRs.
