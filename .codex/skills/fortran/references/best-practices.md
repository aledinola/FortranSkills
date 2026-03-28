# Fortran Best Practices

Use this reference when writing new Fortran or reviewing whether code is modern, maintainable, and aligned with the Fortran-lang best-practices guide at [fortran-lang.org/learn/best_practices](https://fortran-lang.org/learn/best_practices/).

Treat these rules as defaults unless the repository is intentionally legacy.

## Core Style

- Remember that Fortran is case-insensitive; capitalization affects readability, not identifier identity.
- Indent code with four spaces per nesting level rather than two.
- Prefer `enddo` and `endif` over `end do` and `end if` for this user's house style.
- Start every module, program, subroutine, and function with `implicit none`.
- Prefer lowercase keywords and identifiers for new code unless the project clearly uses a different house style.
- Keep interfaces explicit by placing procedures in modules.
- Use short, descriptive names and make units or meanings obvious in argument names when possible.
- Export a narrow public API from modules with `private` by default and explicit `public` declarations.

## Program Structure

- Prefer modules plus small procedures over monolithic programs.
- Prefer one conceptual responsibility per module.
- Keep computation separate from command-line parsing, file I/O, and reporting when practical.
- Use `contains` to keep helper procedures attached to the owning module or program when that improves clarity.
- When a project already provides shared helper modules such as `mod_utilities` or `mod_numerical`, prefer reusing and extending those routines instead of creating near-duplicate helpers elsewhere.

## Types And Numeric Kinds

- Import kinds from `iso_fortran_env`, for example `real64`, `int32`, or `error_unit`.
- Create a local alias such as `dp => real64` when it improves readability.
- Avoid hard-coded kind literals like `real(8)` unless the codebase is already committed to that convention.

Example:

```fortran
use iso_fortran_env, only : dp => real64
real(dp) :: x
```

## Procedures And Arguments

- Add `intent(in)`, `intent(out)`, or `intent(inout)` to dummy arguments.
- Prefer pure/elemental procedures when semantics allow, especially for array-friendly logic.
- Prefer `result(name)` in functions when it improves readability or avoids ambiguity.
- Avoid hidden side effects in procedures that appear computational.

## Arrays

- Prefer whole-array syntax, intrinsic functions, and array operations when they are clear.
- Prefer assumed-shape dummy arrays such as `a(:)` or `a(:, :)` in module procedures.
- Preserve contiguous memory access patterns when performance matters; Fortran is column-major.
- Be careful when translating row-major algorithms from C, Python, or MATLAB-style mental models.

## Allocation And Ownership

- Prefer `allocatable` to `pointer` for owned storage.
- Allocate as late as practical and let scope-driven deallocation work for you.
- Use `allocated(x)` before deallocating or reallocating when control flow is not obvious.
- Reserve pointers for aliasing, optional association graphs, or interop cases that truly need pointer semantics.

## File I/O

- Use `open(newunit=unit, ...)` instead of hard-coded unit numbers.
- Capture failures with `iostat=` and `iomsg=`.
- Close units explicitly when the lifetime is not trivially scoped.
- Keep parsing logic isolated from numerical kernels.

Example:

```fortran
integer :: unit, stat
character(len=:), allocatable :: msg

open(newunit=unit, file=path, status="old", action="read", iostat=stat, iomsg=msg)
if (stat /= 0) error stop msg
```

## Error Handling

- Use `error stop` for fatal unrecoverable errors in modern code.
- Return status codes only when the surrounding design genuinely needs recoverable flow.
- Include enough context in error messages for debugging input and dimension mismatches.

## Callbacks

- Model callbacks with an `abstract interface` that declares the expected signature.
- Accept callback arguments with `procedure(callback_interface)` dummy arguments so the compiler can check them.
- Export the abstract interface when downstream code needs procedure pointers or wrapper procedures with the same signature.
- Prefer module procedures or internal procedures as callback implementations when they naturally capture context.
- Avoid untyped or loosely specified callback patterns that give up compile-time checking.

Example:

```fortran
module integrals_mod
  use iso_fortran_env, only : dp => real64
  implicit none
  private

  public :: integrable_function, simpson

  abstract interface
    function integrable_function(x) result(y)
      import :: dp
      real(dp), intent(in) :: x
      real(dp) :: y
    end function integrable_function
  end interface

contains

  function simpson(f, a, b) result(s)
    procedure(integrable_function) :: f
    real(dp), intent(in) :: a, b
    real(dp) :: s

    s = (b - a) / 6._dp * (f(a) + 4._dp * f((a + b) / 2._dp) + f(b))
  end function simpson

end module integrals_mod
```

## Interoperability And Legacy Code

- Use `iso_c_binding` for C interoperability instead of compiler-specific extensions.
- Contain legacy assumptions at boundaries instead of spreading them into new modules.
- When modernizing older code, improve interfaces and safety incrementally before larger algorithmic rewrites.

## Review Checklist

Use this quick checklist before finishing a Fortran change:

1. Does every program unit have `implicit none`?
2. Did the change avoid relying on capitalization differences, since Fortran is case-insensitive?
3. Are procedures placed in modules where possible?
4. Do dummy arguments have `intent`?
5. Are kinds imported from `iso_fortran_env`?
6. Are allocatables used instead of pointers for owned arrays?
7. Does file I/O use `newunit=`, `iostat=`, and `iomsg=` where failure is possible?
8. Are callbacks expressed with abstract interfaces and `procedure(...)` arguments when callbacks are needed?
9. If `mod_utilities` or `mod_numerical` exist, did the change reuse those routines before adding new helpers?
10. Did the change preserve column-major array semantics and numerical intent?
