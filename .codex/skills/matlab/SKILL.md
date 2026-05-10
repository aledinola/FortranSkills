---
name: matlab
description: Use for all MATLAB .m editing, review, debugging, refactoring, and CPU performance work. This is the default MATLAB skill for scripts, functions, numerical workflows, interpolation, search, optimization, and value function iteration unless the user specifically needs GPU constructs such as gpuArray or arrayfun on GPU; in that case also use matlab-gpu.
---

# MATLAB Performance Skill

## Purpose
Write performance-oriented MATLAB code with modern array semantics. This is the default skill for ordinary CPU MATLAB work.

For requests involving `gpuArray`, GPU `arrayfun`, Bellman or value function iteration on GPU, or GPU-specific performance tuning, also use the `matlab-gpu` skill. Do not use `matlab-gpu` as a substitute for this skill when the project is ordinary CPU MATLAB code.

## Core Rules
- Use this skill whenever editing or reasoning about `.m` files, even if the task is small. Check it before choosing a narrower MATLAB-related skill.
- Keep routine MATLAB functions simple and performance-focused. Do not use `arguments` blocks for input validation unless the user explicitly asks for validation-heavy interfaces.
- Do not use `nargin` checks unless optional calling patterns are genuinely needed. Prefer explicit inputs controlled by the caller or top-level script.
- Use implicit expansion for broadcasting. Do not use `repmat` or `bsxfun` unless explicitly requested for legacy compatibility.
- Prefer vectorization, but not as a hard rule: avoid it when it creates large temporary arrays, increases memory pressure, or significantly reduces readability/maintainability.
- Avoid unnecessary temporary arrays and repeated allocations inside hot paths.
- Hoist loop-invariant calculations out of loops on both CPU and GPU. Do not recompute objects that do not depend on the current iteration.
- Preallocate outputs when size is known.
- MATLAB is column-major. On CPU, make loop ordering consistent with column-major storage so the first dimension varies fastest in inner loops when explicit loops are used.
- Minimize data transfer between CPU and GPU.
- Before implementing common numerical helpers from scratch, inspect [useful_m_codes](useful_m_codes) for relevant templates.

## Reusable Templates

The [useful_m_codes](useful_m_codes) folder contains user-provided MATLAB examples for common numerical routines, currently including helpers such as `interp1_scal`, `locate`, `golden`, `goldenx`, `loadArray`, and `loadBinary`.

- Check `useful_m_codes` early when a project needs similar interpolation, search, optimization, or utility routines.
- Treat these files primarily as templates, examples, and sources of implementation details.
- Usually copy and adapt the relevant routine into the current project instead of adding a dependency on the original file.
- Avoid importing or path-linking the whole folder unless that is clearly the best fit, because the examples may carry assumptions the user does not want in every project.
- When adapting code, preserve the active project's naming, data layout, vectorization style, and error-handling conventions.

## GPU Rules
- Use `gpuArray` for compute-heavy array operations.
- On GPU, prioritize vectorization more strongly than on CPU; non-vectorized GPU code often underutilizes the hardware.
- Column-major access patterns still matter, but on GPU the first priority is usually vectorization and reducing kernel/temporary overhead rather than hand-tuning loop nesting.
- When arrays already live on the GPU, treat loops over state, shock, or control dimensions as a fallback rather than a default. First try higher-dimensional arrays with implicit expansion and reductions such as `max`, `sum`, or `mean` along the target dimension.
- Hoist GPU calculations that do not depend on the iteration out of hot loops. Rebuilding the same GPU tensors every iteration is avoidable overhead.
- Precompute loop-invariant objects such as utility terms, feasible-choice masks, and static transition components outside VFI loops when they do not depend on the current iterate.
- Keep the whole Bellman or simulation pipeline on the GPU when feasible; prefer one large vectorized expression over many small GPU operations.
- Keep loops on the GPU only when the fully vectorized formulation would create excessive temporary arrays or exceed device memory, and state that tradeoff explicitly.
- Use `arrayfun` on GPU only for element-wise custom logic that cannot be expressed efficiently with built-ins; for detailed `arrayfun` constraints, follow the `matlab-gpu` skill.
- Pay attention to array ordering and memory efficiency on the GPU; favor layouts and reshape patterns that avoid unnecessary temporaries and preserve contiguous access where possible.
- Keep full pipelines on GPU where possible; `gather` only at output boundaries.
- Prefer built-in GPU-enabled MATLAB functions before custom kernels.

## Execution Note For This Machine
- MATLAB R2026a is installed on this machine and `matlab.exe` is on PATH, so invoke MATLAB as `matlab -batch "main"` to run `main.m` from the current working directory.
- Use `matlab -batch "<command>"` for validation and scripts unless the user requests another launch mode.
- If `matlab -batch` fails inside the Codex sandbox with startup errors such as `System Error: File system inconsistency` or MathWorks service communication errors, do not infer that MATLAB is missing or the license is invalid.
- In that case, rerun the same MATLAB command outside the sandbox before concluding there is a MATLAB or licensing problem.
- Treat sandbox-only startup failures as execution-context issues first, not MATLAB-code issues.

## Output Style
- Return runnable MATLAB code.
- Briefly state why the approach is fast (vectorization, memory, GPU usage).
- Call out assumptions that affect performance (array sizes, precision, hardware).
- When writing MATLAB functions, always end each function as `end %end function` with exactly one space before the comment.

## Low-priority style note
- Do not hard-code input arguments in function calls when those inputs are model settings or workflow parameters that should be controlled by the caller. Prefer named fields in a parameter struct or explicit variables defined near the top-level script for clarity.

