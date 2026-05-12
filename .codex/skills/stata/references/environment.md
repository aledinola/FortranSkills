# Environment

## Installed Stata

- Executable: `C:\Program Files\StataNow19\StataSE-64.exe`
- Edition: StataNow 19 SE on Windows
- User `PATH`: includes `C:\Program Files\StataNow19`, but new terminals may need to be opened before `StataSE-64.exe` is discoverable by name

## Verified PowerShell Run Pattern

Prefer this discovery-first pattern:

```powershell
$stata = (Get-Command StataSE-64.exe -ErrorAction SilentlyContinue).Path
if (-not $stata) { $stata = 'C:\Program Files\StataNow19\StataSE-64.exe' }

$p = Start-Process -FilePath $stata `
  -ArgumentList '/e do "C:\full\path\to\script.do"' `
  -PassThru -Wait
$p.ExitCode
```

Verified fallback pattern:

```powershell
$p = Start-Process -FilePath 'C:\Program Files\StataNow19\StataSE-64.exe' `
  -ArgumentList '/e do "C:\full\path\to\script.do"' `
  -PassThru -Wait
$p.ExitCode
```

Notes:

- `/e` exits Stata automatically when the do-file finishes.
- The `.log` file is written next to the `.do` file in the verified batch run.
- `0` indicates the Stata process exited cleanly, but you should still read the log.
- If `Get-Command StataSE-64.exe` does not work yet, open a fresh Command Prompt or PowerShell window and try again.

## Interactive Execution

Inside Stata, run:

```stata
do "C:\full\path\to\script.do"
```

Or use:

```stata
run "C:\full\path\to\script.do"
```

`do` echoes commands as they execute. `run` is quieter.

## Authoring Guidance

- Save `.do` files as plain text.
- Quote any file path that contains spaces.
- Prefer explicit `log using ..., text replace` blocks for reproducible runs.
- Use `set more off` in non-interactive scripts to avoid pagination pauses.
