## Fortran-lang style baseline

Use these practices as the default baseline for new modern Fortran code unless the repository is clearly legacy or the user requests compatibility constraints.

Use <https://fortran-lang.org/> as the primary documentation source for general language guidance and modern Fortran best practices.
Use <https://github.com/fortran-lang> as the primary upstream source for Fortran-lang codebases, examples, libraries, and related documentation repositories.

### Program structure

- Prefer modules over loose external procedures.
- Keep one source file per module, and match the module name to the filepath.
- Prefix module names with the library or project name when building reusable packages.
- Keep each module focused on a clear responsibility.
- Use `private` by default and export only the intended public API.
- Group related procedures with shared derived types and constants.
- Prefer internal procedures only when tight lexical scoping is genuinely helpful.
- Start modules with a short comment block describing their purpose and contents.
- Keep main programs thin and delegate implementation to modules.

### Typing and interfaces

- Start every program unit with `implicit none`.
- Import kinds from `iso_fortran_env`, for example `real64` or `int32`.
- Prefer explicit interfaces via module procedures instead of implicit external interfaces.
- Add `intent(in)`, `intent(out)`, or `intent(inout)` to every dummy argument.
- Prefer assumed-shape arrays in procedures that live in modules.
- Use `optional` and `present()` only when the call-site flexibility is worth the added branching.

### Memory and data

- Remember that Fortran arrays are column-major. Keep memory layout and loop ordering consistent with that when performance matters.
- Prefer `allocatable` over `pointer` unless aliasing or deferred association is required.
- Prefer whole-array operations and intrinsic procedures when they preserve clarity.
- Use derived types to group related state instead of passing many parallel arrays.
- Keep numerical kinds centralized rather than scattering literal kind suffixes.
- Avoid hidden global state where possible.
- Limit module variables to constants, parameters, or carefully controlled protected state whenever possible.

### Callback state and type-casting patterns

Use these guidelines when designing callbacks that need extra state beyond the callback's formal arguments.

Preferred order for this project:

1. Nested internal functions
2. Private module variables
3. Explicit context objects or work arrays when the interface already supports them
4. `type(c_ptr)` for interoperable C-style callback APIs

Nested internal functions:

- Prefer these by default for this project.
- Keep state close to the call site.
- Avoid semi-global module variables.
- Usually give a clearer ownership story than private module state.

Private module variables:

- Use them when they materially simplify the design and the lifetime and concurrency model are well understood.
- Shared module state is not thread-safe by default.
- Reentrancy requires separate state per active callback path.
- Concurrent evaluations, including OpenMP regions, need deliberate handling of thread-local state.
- If thread-local module state is truly the intended design, mechanisms such as `threadprivate` can be appropriate where supported, but this should be an explicit choice rather than an assumption.

Explicit context objects or work arrays:

- Prefer these when the callback interface already accepts explicit state.
- Prefer a typed context structure over an unlabelled work array when you control the interface.
- These patterns are often a better fit when thread-safety and reentrancy matter.

`type(c_ptr)` callback context:

- Use this as the preferred interoperable equivalent of C's `void *` for extensible callback APIs.
- Prefer it over `transfer()` for new interoperable designs.

Avoid `transfer()` for new code unless you are maintaining an older design that already depends on it.

Thread-safety rule of thumb:

- If callbacks may be evaluated concurrently, do not assume module variables are safe by default.
- Prefer nested internal procedures, explicit typed context arguments, or `type(c_ptr)`-based context passing unless thread-local module state is an explicit and well-supported part of the design.

### Control flow and errors

- Prefer simple loops and clear procedure boundaries over deeply nested control flow.
- Use `select case` when dispatching over discrete states.
- Use `error stop` for fatal failures in modern code paths.
- Propagate recoverable failures through status returns or explicit error handling paths.

### I/O

- Use `newunit=` when opening files.
- Capture both `iostat=` and `iomsg=` for operations that can fail.
- Prefer explicit formats when output stability matters.
- Keep parsing logic separate from numerical kernels.

### Numerical code

- Make side effects obvious.
- Avoid silent shape or unit assumptions.
- Name tolerances and constants rather than embedding magic numbers.
- Validate array sizes and preconditions near the API boundary.

### Modernization guidance

When improving existing code, prefer small behavior-preserving steps:

1. Add `implicit none`.
2. Add `intent` declarations.
3. Move procedures into modules to provide explicit interfaces.
4. Split multi-module source files into one-file-per-module layouts when safe and useful.
5. Replace `common` or scattered globals with module-owned state only when safe.
6. Replace pointer-based storage with allocatables when aliasing is not required.

### Style notes

- Treat capitalization as style, not semantics. Fortran identifiers are case-insensitive.
- Indent by four spaces per nesting level.
- Prefer `enddo` and `endif` when matching an established modern-house style that already uses them.
- Keep line length practical for the toolchain and reviewers, breaking long statements cleanly with continuation.
