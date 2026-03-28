# Intel ifx Reference

Use this reference when you need machine-specific `ifx` commands, local oneAPI paths, or official Intel documentation entry points.

## Local Installation Observed On This Machine

- oneAPI root: `C:\Program Files (x86)\Intel\oneAPI`
- environment setup script: `C:\Program Files (x86)\Intel\oneAPI\setvars.bat`
- compiler binary: `C:\Program Files (x86)\Intel\oneAPI\compiler\2024.0\bin\ifx.exe`
- compiler config file: `C:\Program Files (x86)\Intel\oneAPI\compiler\2024.0\bin\ifx.cfg`
- useful include path example: `C:\Program Files (x86)\Intel\oneAPI\compiler\2024.0\opt\compiler\include`

Directly invoking `ifx.exe` in a plain PowerShell session produced a fatal `xfortcom` startup error on this machine. Initializing oneAPI first with `setvars.bat` resolved compilation successfully, so treat environment setup as required unless you confirm the shell is already prepared.

## Verified Command Pattern

Use this exact Windows pattern when compiling from PowerShell:

```powershell
cmd /c '"C:\Program Files (x86)\Intel\oneAPI\setvars.bat" >nul 2>&1 && "C:\Program Files (x86)\Intel\oneAPI\compiler\2024.0\bin\ifx.exe" "source.f90" /exe:"program.exe"'
```

This pattern was verified locally by compiling and running a small program.

## Recommended Starting Flags

Prefer the project's existing build flags when they are established. If you need a clean starting point, use one of these and then adjust based on diagnostics and project requirements.

Debug-oriented build:

```powershell
cmd /c '"C:\Program Files (x86)\Intel\oneAPI\setvars.bat" >nul 2>&1 && "C:\Program Files (x86)\Intel\oneAPI\compiler\2024.0\bin\ifx.exe" /warn:all /stand:f18 /check:all /traceback /debug:full /Od "source.f90" /exe:"program.exe"'
```

Release-oriented build:

```powershell
cmd /c '"C:\Program Files (x86)\Intel\oneAPI\setvars.bat" >nul 2>&1 && "C:\Program Files (x86)\Intel\oneAPI\compiler\2024.0\bin\ifx.exe" /warn:all /stand:f18 /O2 "source.f90" /exe:"program.exe"'
```

Interpret these flags conservatively:

- `/warn:all`: enable broad warning coverage
- `/stand:f18`: request Fortran 2018 standards diagnostics
- `/check:all`: enable common runtime checks for debugging
- `/traceback`: include traceback information for runtime failures
- `/debug:full`: generate richer debug information
- `/Od`: disable optimization for easier debugging
- `/O2`: enable a standard optimized build level

## Official Intel Documentation

Prefer official Intel documentation for exact option semantics and compiler behavior:

- Intel Fortran Compiler Developer Guide and Reference (latest index seen: version 2025.2, dated June 30, 2025):
  [https://www.intel.com/content/www/us/en/docs/fortran-compiler/developer-guide-reference/2025-2/overview.html](https://www.intel.com/content/www/us/en/docs/fortran-compiler/developer-guide-reference/2025-2/overview.html)
- Intel Fortran Compiler Get Started Guide:
  [https://www.intel.com/content/www/us/en/docs/fortran-compiler/get-started-guide/2025-0/overview.html](https://www.intel.com/content/www/us/en/docs/fortran-compiler/get-started-guide/2025-0/overview.html)
- Porting Guide for `ifort` Users to `ifx`:
  [https://www.intel.com/content/www/us/en/developer/articles/guide/porting-guide-for-ifort-to-ifx.html](https://www.intel.com/content/www/us/en/developer/articles/guide/porting-guide-for-ifort-to-ifx.html)

## Practical Guidance

- `ifx` is the modern Intel Fortran compiler; use it by default unless the user explicitly needs `ifort`.
- Be careful when inheriting old `ifort` flags; verify them in the Intel docs instead of assuming identical support.
- `ifx` on Windows targets Intel 64 only; do not assume 32-bit output support.
- When a build fails, read the full compiler and linker diagnostics before changing source.
- If exact option behavior matters, consult the official option reference rather than memory.
