## Intel ifx on Windows

Use this reference when the task needs exact compiler invocation, build validation, or links to official Intel documentation.

### Working assumption for this machine

`ifx.exe` is available after the Intel oneAPI environment has been initialized with `setvars.bat`. In a plain PowerShell session, call the compiler through `cmd /c` so the environment setup and compilation happen in the same shell.

### Verified invocation pattern

```powershell
cmd /c '"C:\Program Files (x86)\Intel\oneAPI\setvars.bat" >nul 2>&1 && "C:\Program Files (x86)\Intel\oneAPI\compiler\2024.0\bin\ifx.exe" /warn:all /stand:f18 /check:all /traceback /debug:full /Od "source.f90" /exe:"program.exe"'
```

Swap in the project's real source files and executable name. For multi-file builds, use the same `setvars.bat` prefix and then invoke `ifx` with the project's object and source ordering.

### Release-oriented starting point

```powershell
cmd /c '"C:\Program Files (x86)\Intel\oneAPI\setvars.bat" >nul 2>&1 && "C:\Program Files (x86)\Intel\oneAPI\compiler\2024.0\bin\ifx.exe" /warn:all /stand:f18 /O2 "source.f90" /exe:"program.exe"'
```

### Practical guidance

- Preserve project-specific flags if they already exist.
- Adapt `ifort`-era flags carefully instead of assuming direct equivalence.
- Use `/warn:all`, `/stand:f18`, and runtime checks during debugging unless the project needs a different profile.
- Read diagnostics fully before making another code change.
- Re-run the executable or test command after a successful rebuild when feasible.

### Official references

Prefer Intel's official documentation for exact flag semantics and compiler behavior:

- Intel Fortran Compiler Developer Guide and Reference
- Intel oneAPI Fortran compiler option reference
- Intel Windows command-line environment setup documentation

If a user asks for exact behavior of a compiler flag, search or cite the official Intel docs rather than relying on memory.
