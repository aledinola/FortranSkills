---
name: matlab-gpu
description: Use only for MATLAB code involving GPU-specific constructs or GPU execution, such as gpuArray, arrayfun on GPU, GPU vectorization, GPU memory use, or value function iteration intended to run on the GPU. For ordinary CPU MATLAB .m editing, use the matlab skill instead.
---

# MATLAB GPU Skill

## When to use
Use this skill when the user asks for MATLAB code or advice involving:
- `gpuArray`
- `arrayfun` on GPU
- value function iteration on GPU
- Bellman equation / dynamic programming on GPU
- vectorization vs loops in MATLAB GPU code
- memory-efficient GPU implementation
- performance tuning for MATLAB numerical code

Do not use this skill merely because the files are MATLAB files. If the code is CPU-only and does not involve GPU execution, use the general `matlab` skill.

## Core principles

- MATLAB is column-major. On CPU, if explicit loops are necessary, the first dimension should usually vary fastest in the innermost loop.
- On GPU, this matters less than on CPU, but avoid advice that assumes C-style row-major traversal.
- Prefer ordinary function signatures, `nargin` defaults, or simple option structs over MATLAB `arguments` blocks unless the user explicitly requests an `arguments` block or the existing file already follows that style.

### 1. Treat `gpuArray.arrayfun` as elementwise
`gpuArray.arrayfun` computes one scalar output element from corresponding scalar input elements.

Implications:
- Do not describe it as a general kernel language.
- Do not put reductions like `max`, `sum`, or policy search inside the `arrayfun` kernel.
- Use it for scalar return functions, utility evaluation, or pointwise transforms.
- Write the called function in scalar style: scalar inputs, scalar branching, scalar output.
- Do not call an array-oriented helper from inside GPU `arrayfun` if that helper relies on logical masks, slicing, or indexed assignment.

### 2. Do not rely on unsupported indexing inside GPU `arrayfun`
Inside a function called by `gpuArray.arrayfun`:
- avoid arbitrary indexing into arrays
- avoid patterns like "pass indices, then look up arrays inside the kernel"
- instead pass the scalar values needed for each output element directly as inputs to `arrayfun`

Preferred pattern:
- reshape inputs so each call receives scalar values like `(ap, a, z)`
- compute the scalar return `u(ap,a,z)` inside the kernel
- do maximization or reduction outside the kernel
- avoid materializing replicated grids with `ndgrid`, `repmat`, or similar only to feed `arrayfun`
- prefer singleton-expanded reshaped inputs when `arrayfun` accepts them, since explicit replicated tensors add avoidable GPU memory traffic
- when inputs already have compatible sizes, pass them directly to `arrayfun` and rely on implicit expansion instead of creating zero-padded or explicitly broadcasted copies

### 3. Do not use captured anonymous functions with GPU `arrayfun`
Avoid:
```matlab
arrayfun(@(ap,a,z) util(ap,a,z,w,r,gamma), ap_in, a_in, z_in)
```

Prefer:
```matlab
V = arrayfun(@util_gpu, ap_in, a_in, z_in, w, r, gamma);
```

Where `util_gpu` is a separate function that receives all needed scalar inputs explicitly.

### 4. Choose between built-ins and `arrayfun` based on the operation
Before using `arrayfun`, check whether the logic is clearer or more efficient with GPU-enabled built-ins and implicit expansion.

Guidance:
1. use built-in elementwise operations and reductions when they express the computation cleanly without awkward masking or indexing
2. use `gpuArray.arrayfun` for scalar custom logic, branching, or pointwise utility evaluation when that is the cleaner GPU formulation
3. treat explicit loops on GPU as a last resort; prefer either built-in GPU vectorization or `gpuArray.arrayfun` whenever possible
4. use explicit loops only when full tensor formulations create unacceptable memory pressure or when no reasonable built-in/`arrayfun` formulation exists

### 5. Separate pointwise utility from optimization
For Bellman or VFI code on GPU:
- compute pointwise return matrices or tensors on the GPU
- perform maximization across the choice dimension with `max(..., [], dim)` outside `arrayfun`
- keep policy extraction and value updates in GPU-native array operations

Do not present `arrayfun` as the place to perform the full Bellman maximization.

### 6. Watch the formulation-memory tradeoff
On GPU, both vectorized built-ins and `arrayfun` can work well, but full tensor expansion can exceed device memory.

Guidance:
- choose the formulation that keeps memory use and kernel structure reasonable for the problem at hand
- if the state-choice tensor is too large, reduce expansion across some dimensions and loop over the remaining outer dimensions
- state this tradeoff explicitly when recommending code structure
- pay attention to array ordering and reshape strategy so expanded views stay memory-efficient and avoid unnecessary temporary permutations or copies

### 7. Minimize CPU-GPU transfers
- keep `V`, policy objects, grids, and transition objects on the GPU once moved there
- avoid repeated `gpuArray(...)` and `gather(...)` calls inside iteration loops
- gather only final outputs or diagnostics that must be used on the CPU
- avoid extra GPU temporaries whose only purpose is to reshape or replicate data for `arrayfun`

### 8. Hoist loop-invariant GPU work out of VFI loops
- precompute utility components, static feasibility objects, and transition terms outside the value-function iteration loop when they do not depend on the current value iterate
- inside the VFI loop, update only quantities that genuinely change with the iterate

## Output style
- Return runnable MATLAB code.
- Explain whether the recommendation is using built-in GPU vectorization, `arrayfun`, or a hybrid approach.
- If recommending `arrayfun`, state clearly that it is elementwise and not a reduction kernel.
- Flag assumptions that matter for performance or correctness: array sizes, precision, transition structure, and GPU memory limits.
