---
name: windows-codex
description: Use when working on Alessandro's Windows machine through Codex, especially for PowerShell vs cmd.exe behavior, PATH refreshes, quoted Program Files paths, sandbox escalation, local command-line tools, Git/GitHub CLI, or Windows-specific setup quirks.
---

# Windows Codex

Use this skill when a task depends on Windows command-line behavior, local tool discovery, environment variables, Codex sandbox approvals, or Git/GitHub CLI setup.

## Shell Choice

- Prefer PowerShell for Windows automation, path checks, filesystem work, object output, and environment-variable inspection.
- Use `cmd /c` when a `.bat` file must configure the environment for the same command, especially Intel oneAPI `setvars.bat`.
- For oneAPI/Fortran builds, keep `setvars.bat` and `ifx` in the same `cmd.exe` command:

```powershell
& $env:ComSpec /c '"C:\Program Files (x86)\Intel\oneAPI\setvars.bat" >nul 2>&1 && ifx /QV'
```

## Paths And Quoting

- Quote executable paths with spaces when invoking them:

```powershell
& "C:\Program Files\qpdf 12.3.2\bin\qpdf.exe" --version
```

- Do not quote PATH entries themselves. PATH should contain raw directories such as `C:\Program Files\qpdf 12.3.2\bin`.
- In PowerShell, prefer the call operator `&` for quoted executable paths.
- Use `where.exe toolname`, not plain `where`, because `where` can mean `Where-Object` in PowerShell.
- On Windows, prefer forward slashes inside MATLAB `-batch` path strings, for example `cd('C:/path/project')`, to reduce escaping problems.

## PATH Refresh

After installing tools or changing PATH, the current Codex shell may not see the new entries. Reload PATH before declaring a command missing:

```powershell
$sep = [IO.Path]::PathSeparator
$env:Path = [Environment]::GetEnvironmentVariable('Path','Machine') + $sep + [Environment]::GetEnvironmentVariable('Path','User')
```

When building PATH strings programmatically, use `[IO.Path]::PathSeparator` or `[char]59` on Windows rather than relying on visually fragile semicolon quoting.

## PowerShell Patterns

For one-liners that emit loop output into a pipeline, wrap the loop in a script block:

```powershell
& { foreach ($x in $xs) { [pscustomobject]@{Name=$x} } } | Format-Table -AutoSize
```

Avoid PowerShell heredoc or Bash-style redirection patterns such as `python - <<'PY'`; they are not valid PowerShell. Use a temporary script file, `python -c`, or PowerShell here-strings only when appropriate.

## Sandbox And Approvals

- If a Program Files executable exists but fails in the sandbox with access, launch, DNS, socket, or permission-like errors, retry once with escalated permissions before declaring the tool missing.
- Request escalation directly on the failed command with a concise justification.
- Avoid command shims unless the user explicitly wants them. Prefer real installer paths plus PATH refresh.
- Before recursive moves or deletes, resolve absolute paths and confirm they remain inside the intended workspace or target directory.

## GitHub CLI Setup

- Git is installed and available as `git`.
- GitHub CLI is installed and available as `gh`.
- The usual executable path is `C:\Program Files\GitHub CLI\gh.exe`.
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

Verification commands:

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
& "C:\Program Files\GitHub CLI\gh.exe" --version
```

## Git And GitHub Workflow

- Use local `git` for status, branches, commits, pulls, and pushes.
- Use `gh` for current-branch PR discovery, PR creation, GitHub Actions checks/logs, and GitHub API gaps.
- Use the Codex GitHub connector for structured PR, issue, comment, review, and repository metadata when available.
- Keep local repo state and GitHub connector state aligned before mutating branches or PRs.

Network operations may require approval by command prefix. This is normal sandbox behavior, not a GitHub configuration problem. Common commands that may need approval the first time include:

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
