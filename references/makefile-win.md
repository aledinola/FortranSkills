# Windows Makefile Convention

Use this reference when the user asks for a Windows makefile for a Fortran project.

## Default Invocation

Assume the user runs the build with:

```powershell
nmake /f makefile_win
```

So, unless the user says otherwise:

- name the file `makefile_win`
- write it for `nmake`, not GNU Make
- keep Windows-style paths and commands

## Preferred Structure

Follow this pattern from the user's example:

1. Define `COMPILER = ifx`
2. Define flag groups such as `SWITCH` and, when needed, `SWITCH_HEAP`
3. Define `OBJS` as an explicit ordered object list
4. Define `EXEC` as the Windows executable path
5. Add a linking rule `$(EXEC): $(OBJS)`
6. Add explicit per-file compile rules, especially when module order matters
7. Add `run` and `clean` targets when appropriate

Prefer this style over a generic pattern-rule-heavy makefile when working for this user.

## Details To Preserve

- Use Windows backslashes in source and output paths, for example `src\main.f90` and `exe\run_win.exe`.
- Use `ifx` command lines in the style already used by the user, such as:
  - `$(COMPILER) $(OBJS) $(SWITCH) /exe:$(EXEC)`
  - `$(COMPILER) $(SWITCH) -c -fpp src\main.f90`
- Keep explicit object dependencies in source order when module compilation order is important.
- Allow special-case flags for selected files through separate variables like `SWITCH_HEAP`.
- Use Windows cleanup commands like `del *.obj`.

## Example Shape

This is the style to imitate structurally:

```make
COMPILER = ifx
SWITCH = ...
SWITCH_HEAP = $(SWITCH) ...
OBJS = first.obj second.obj main.obj
EXEC = exe\run_win.exe

$(EXEC): $(OBJS)
	$(COMPILER) $(OBJS) $(SWITCH) /exe:$(EXEC)

first.obj: src\first.f90
	$(COMPILER) $(SWITCH) -c -fpp src\first.f90

run:
	$(EXEC)

clean:
	del *.mod
	del *.obj
	del $(EXEC)
```

## Practical Guidance

- If module dependencies are nontrivial, prefer explicit compile rules over clever automation.
- If the project already has a makefile in this style, preserve its naming and variable conventions.
- If the user asks for a new makefile from scratch, use this convention by default instead of a cross-platform abstraction.
