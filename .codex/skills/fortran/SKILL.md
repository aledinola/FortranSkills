---
name: fortran
description: Create, edit, review, build, and debug modern Fortran code and projects. Use when Codex needs to work with `.f90`, `.f95`, `.f03`, `.f08`, `.F90`, Makefiles or build scripts for Fortran, especially when the preferred compiler is Intel `ifx` from oneAPI on Windows, and when code should follow modern Fortran best practices from Fortran-lang.
---

# Fortran

Use this skill for Fortran work with Intel oneAPI `ifx` on Windows. Treat the Fortran-lang best-practices guide as the default style baseline unless the repository is clearly legacy or the user asks for compatibility with older conventions.

Use <https://fortran-lang.org/> as the main documentation reference for general Fortran language guidance, modern practices, tutorials, and community conventions.
Use <https://github.com/fortran-lang> as the main upstream source for Fortran-lang projects, examples, libraries, and related documentation repositories.

## Quick Start

Follow this workflow:

1. Identify the active source files, compiler entry point, and whether the code is modern or legacy Fortran.
2. Preserve existing project structure when it is intentional, but steer new code toward modules, explicit interfaces, allocatables, and clear procedure boundaries.
3. Before implementing common numerical or MATLAB-like utilities from scratch, inspect [useful_codes](useful_codes) for relevant templates.
4. Read [references/best-practices.md](references/best-practices.md) before creating substantial new code, refactoring APIs, reviewing callback patterns, or making style/design choices.
5. Read [references/intel-ifx.md](references/intel-ifx.md) when you need exact compiler invocation patterns, local install paths, or official Intel documentation links.
6. Read [references/makefile-win.md](references/makefile-win.md) before writing or refactoring a Windows makefile for this user.
7. Compile or test with the verified `setvars.bat` + `ifx` pattern from [references/intel-ifx.md](references/intel-ifx.md) whenever execution is requested or needed for validation.

## Important Conventions

Treat these as technical defaults unless the existing codebase clearly requires something else:

- Keep one module per source file, and make the module name match the filepath for easier navigation in larger projects.
- Prefer library-prefixed module names when building reusable packages to reduce name clashes across dependencies.
- Put reusable procedures in modules, not loose external procedures.
- Keep the main program body thin and push implementation into reusable modules.
- Start every program unit with `implicit none`.
- Use `private` by default in modules and export only the intended public API.
- Add `intent(in)`, `intent(out)`, or `intent(inout)` to dummy arguments.
- Remember that Fortran arrays are column-major, so access patterns and loop ordering should respect that when performance matters.
- Prefer `allocatable` over `pointer` unless pointer semantics are truly required.
- Prefer assumed-shape dummy arrays and pass explicit interfaces through modules.
- Use named kinds from `iso_fortran_env` instead of hard-coded kind numbers.
- Use `error stop` for fatal failures in modern code paths.
- Use `newunit=` plus `iostat=` and `iomsg=` for file I/O that can fail.
- Keep module variables to constants where possible; if module state must be exposed, prefer `protected` over unrestricted public mutable state.

For callbacks and callback context:

- Prefer nested internal functions first, especially when you want callback state to stay local to the calling routine without introducing module-level mutable state.
- Prefer private module variables second when they make the design materially simpler, but call out clearly whether the state is shared, reentrant, or made thread-local explicitly.
- Shared private module variables are risky under OpenMP or any concurrent execution unless thread-local storage is handled deliberately, for example with `threadprivate` where appropriate.
- When thread-safety, reentrancy, or parallel execution matter, prefer designs that keep state local or explicit in the call path.
- Treat `type(c_ptr)` callback context as the preferred interoperable approach when designing C-style extensible callback APIs.
- Avoid `transfer()`-based callback context except when maintaining older code that already depends on it.

## Style Preferences

Treat these as house-style defaults rather than semantic rules:

- Remember that Fortran is case-insensitive, so treat identifier capitalization as style rather than semantics.
- Indent modern Fortran code with four spaces per nesting level, including nested loops, conditionals, and contained procedures.
- Prefer `enddo` and `endif` instead of `end do` and `end if`.
- Add a short leading comment block describing each module's purpose, and brief procedure comments when intent is not obvious from the signature alone.

When adding new code, prefer a skeleton like:

```fortran
module solver_mod
  use iso_fortran_env, only : dp => real64
  implicit none
  private

  public :: advance_state

contains

  subroutine advance_state(x, dt)
    real(dp), intent(inout) :: x(:)
    real(dp), intent(in) :: dt

    x = x + dt
  end subroutine advance_state

end module solver_mod
```

## Work With Existing Code

Match the codebase instead of forcing a full rewrite, but improve quality where safe:

- Do not infer meaning from capitalization alone because Fortran identifiers are case-insensitive.
- Keep fixed-form or legacy constructs only when the file or build already depends on them.
- Avoid mixing new global state or COMMON-style patterns into otherwise modern code.
- If a codebase uses `ifort`-era flags, adapt them carefully for `ifx` rather than assuming full equivalence.
- When modernizing, prefer small behavior-preserving steps: add `implicit none`, add `intent`, move procedures into modules, separate modules into one-file-per-module layouts where practical, and replace pointers with allocatables where semantics allow.
- Whenever `mod_utilities` and/or `mod_numerical` are present in the project, inspect and prefer the routines already defined there before creating new helper routines.

## Reusable Templates

The [useful_codes](useful_codes) folder contains user-provided Fortran examples for common routines, including plotting helpers, MATLAB-style utilities, interpolation, sorting, display helpers, and Tauchen discretization.

- Check `useful_codes` early when a project needs functionality such as `linspace`, `interp1`, `disp`, `sort`, `tauchen`, `plot`, or `execplot`/`exec_plot` helpers.
- Treat these files primarily as templates, examples, and sources of implementation details.
- Usually copy and adapt the relevant routine into the current project instead of adding a dependency on the original module.
- Avoid importing a whole `useful_codes` module unless that is clearly the best fit, because those files may carry dependencies the user does not want in every project.
- When adapting code, preserve the active project's naming, kind parameters, module layout, and error-handling style.

## Write Windows Makefiles

When the user asks for a makefile on Windows, treat `makefile_win` plus `nmake` as the default convention.

- Name the file `makefile_win` unless the user explicitly asks for something else.
- Assume the invocation pattern is `nmake /f makefile_win`.
- Follow the user's uploaded example structure rather than emitting a Unix-style generic makefile.
- Prefer top-level variables like `COMPILER`, `SWITCH`, `SWITCH_HEAP`, `OBJS`, and `EXEC` when they fit the project.
- Keep explicit object-by-object compile rules when module order or per-file flags matter.
- Preserve Windows path separators such as `src\file.f90` and outputs like `exe\run_win.exe`.
- Use `ifx` compiler flags in the same style as the example, including `-c`, `-fpp`, and `/exe:...` where appropriate for this codebase.
- Include practical targets such as the executable target, `run`, and `clean` when the project structure supports them.

Before inventing a new pattern, read [references/makefile-win.md](references/makefile-win.md).

## Compile And Validate

On this machine, invoking `ifx.exe` directly is not sufficient for compilation in a plain shell. Use the verified Windows pattern from [references/intel-ifx.md](references/intel-ifx.md), which initializes the oneAPI environment first.

For a debug-oriented build, prefer flags in this spirit unless the project already defines its own set:

```powershell
cmd /c '"C:\Program Files (x86)\Intel\oneAPI\setvars.bat" >nul 2>&1 && "C:\Program Files (x86)\Intel\oneAPI\compiler\latest\bin\ifx.exe" /warn:all /stand:f18 /check:all /traceback /debug:full /Od "source.f90" /exe:"program.exe"'
```

For release-oriented builds, start from the project defaults. If none exist, a conservative starting point is:

```powershell
cmd /c '"C:\Program Files (x86)\Intel\oneAPI\setvars.bat" >nul 2>&1 && "C:\Program Files (x86)\Intel\oneAPI\compiler\latest\bin\ifx.exe" /warn:all /stand:f18 /O2 "source.f90" /exe:"program.exe"'
```

After edits:

1. Rebuild the affected target.
2. Read compiler diagnostics fully before patching.
3. Run the produced executable or project test command when feasible.
4. Report any unverified assumptions, especially around numerical behavior, OpenMP, coarrays, or legacy extensions.

## Use References Efficiently

Read only what you need:

- Use [references/best-practices.md](references/best-practices.md) for style, architecture, array handling, and safer I/O.
- Use [references/intel-ifx.md](references/intel-ifx.md) for machine-specific compiler execution and Intel documentation entry points.
- Use [references/makefile-win.md](references/makefile-win.md) for the user's preferred `nmake /f makefile_win` structure on Windows.

If the user asks for exact compiler behavior or option semantics, prefer the official Intel documentation linked in [references/intel-ifx.md](references/intel-ifx.md) over memory.

