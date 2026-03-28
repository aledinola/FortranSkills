# Environment

## Installed Stata

- Executable: `C:\Program Files\Stata18\StataSE-64.exe`
- Edition: Stata 18 SE on Windows

## Verified PowerShell Run Pattern

This pattern was verified locally:

```powershell
$p = Start-Process -FilePath 'C:\Program Files\Stata18\StataSE-64.exe' `
  -ArgumentList '/e do "C:\full\path\to\script.do"' `
  -PassThru -Wait
$p.ExitCode
```

Notes:

- `/e` exits Stata automatically when the do-file finishes.
- The `.log` file is written next to the `.do` file in the verified batch run.
- `0` indicates the Stata process exited cleanly, but you should still read the log.

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
