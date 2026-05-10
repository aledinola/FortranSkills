# Fortran-To-MATLAB Output Workflow

Use this reference when Fortran should write model outputs, policy functions, simulated data, grids, value functions, moments, or other multidimensional numeric arrays that MATLAB will later read.

This follows Gabriel Mihalache's Fortran+MATLAB workflow: <https://www.gmihalache.com/computation/fortranMatlab.html>.

## Default pattern

Prefer a two-file pattern:

1. A small text metadata file containing dimensions and scalar parameters.
2. One binary stream file per large numeric array.

This keeps metadata inspectable while preserving full precision for large arrays.

## Fortran: write metadata

Write dimensions and scalar parameters as plain text with explicit formats:

```fortran
integer :: iunit

open(newunit=iunit, file=out_dir // "parameters.txt", status="replace", action="write")
write(iunit, "(I20)") z_sz
write(iunit, "(I20)") k_sz
write(iunit, "(E24.16)") beta
write(iunit, "(E24.16)") sigma
close(iunit)
```

Use the metadata file for:

- array dimensions in Fortran order
- key scalar parameters needed by MATLAB scripts
- file names or short labels when several outputs are written
- type information when anything differs from the default `real64`/`float64`

## Fortran: write binary arrays

For large arrays, use unformatted stream access:

```fortran
open(newunit=iunit, file=out_dir // "policy.bin", form="unformatted", &
     access="stream", status="replace", action="write")
write(iunit) policy
close(iunit)
```

Notes:

- Use `access="stream"` to avoid compiler record markers.
- Use `status="replace"` when each run should overwrite old output; use `status="unknown"` only when preserving existing behavior matters.
- Add `iostat=` and `iomsg=` in production code when failed writes should produce a useful diagnostic.
- Keep array writes simple: `write(iunit) array_name`.
- Preserve Fortran's column-major dimension order. MATLAB is also column-major, so `reshape` with the same dimension vector is the intended match.

## Fortran: read binary arrays back

For restarting from a previous solution or loading an initial guess:

```fortran
open(newunit=iunit, file=out_dir // "policy.bin", form="unformatted", &
     access="stream", status="old", action="read")
read(iunit) policy
close(iunit)
```

The allocated or declared array shape must match the file contents.

## MATLAB: read metadata and arrays

In MATLAB, read the metadata first, then use those dimensions for binary loads:

```matlab
params = dlmread('parameters.txt');
ix = 1;
z_sz = params(ix); ix = ix + 1;
k_sz = params(ix); ix = ix + 1;
beta = params(ix); ix = ix + 1;
sigma = params(ix); ix = ix + 1;

policy = loadBinary('policy.bin', 'float64', [z_sz, k_sz]);
```

The local MATLAB skill includes `../matlab/useful_m_codes/loadBinary.m`, whose pattern is to `fread` a vector of `prod(sz)` values, then `reshape(out, sz)`.

## Type mapping

Prefer kinds from `iso_fortran_env` and match the MATLAB `fread` type explicitly:

- Fortran `real64` -> MATLAB `float64`
- Fortran `real32` -> MATLAB `single`
- Fortran common/default 32-bit `integer` -> MATLAB `int32`

If a project uses non-default integer widths or logical flags, write a metadata note and choose the MATLAB `fread` type deliberately. For GPU-oriented workflows, `real32`/`single` may be appropriate, but do not silently downcast precision-sensitive results.

## Text files for arrays

Use text files for small diagnostics, metadata, or human-readable tables. Prefer binary stream files for large multidimensional arrays because formatted text is slower, larger, and easier to round unintentionally.

If the user explicitly wants text arrays, use explicit formats and document the ordering MATLAB should expect.
