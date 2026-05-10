## Windows makefile pattern

Use this reference when writing or refactoring a Windows makefile for Fortran in this environment.

### Default convention

- Name the file `makefile_win`.
- Assume the command is `nmake /f makefile_win`.
- Preserve the structure of the user's existing or provided example where possible.

### Preferred structure

When the project does not already impose a different format, prefer top-level variables like:

- `COMPILER`
- `SWITCH`
- `SWITCH_HEAP`
- `OBJS`
- `EXEC`

Keep explicit compile rules when module dependency order matters.

### Path and target style

- Use Windows path separators such as `src\solver.f90`.
- Use explicit output paths such as `exe\run_win.exe` when the project uses them.
- Include practical targets such as the main executable, `run`, and `clean` when the project layout supports them.

### Compiler usage

- Prefer `ifx` for new Windows makefiles in this repository.
- Follow the project's existing flag style for preprocessing, debug, optimization, and output naming.
- Use flags in the same idiom as the surrounding project, including patterns such as `-c`, `-fpp`, and `/exe:...` when appropriate.

### Cautions

- Do not replace a Windows-focused layout with a generic Unix make pattern unless the user explicitly asks for that change.
- Be careful with module build order; avoid collapsing explicit rules when the order is significant.
- Match the repository's conventions for intermediate object directories and executable directories.
