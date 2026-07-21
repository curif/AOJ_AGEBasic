# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository purpose

This is a development workspace for **AGEBasic** scripts — a custom scripting language used inside the
"Age of Joy" VR Arcade ecosystem to configure cabinets, rooms, and in-VR behavior. It is not a general
software project; it currently holds `.bas` scripts and the language reference used to write them.

## Essential reading before writing any code

**Always read `agebasic_prompt.md` in full before writing or editing any `.bas` file.** It is the
authoritative language reference (syntax, commands, functions, VR/cabinet APIs, audio, video). AGEBasic is
**not** Microsoft BASIC/QBasic/VB — do not assume any standard BASIC feature exists unless it is explicitly
documented there. Do not invent commands.

Two companion references are mentioned in `agebasic_prompt.md` but may not be present in this checkout:
`docs/agebasic_audio.md` and `docs/agebasic_video.md`. Check for them before relying on audio/video details
beyond the summary in the main prompt file.

## Hard syntax rules (frequent LLM mistakes to avoid)

- **Every line must start with a line number**, in strictly ascending order.
- **Blank lines and comment-only lines (`REM ...`) are stripped by the parser and are not valid jump
  targets.** Never `GOTO`/`GOSUB`/`IF...THEN GOTO` to a line that has no executable statement — this throws
  "Line number not found" at runtime.
- `GOTO`/`GOSUB` only target line numbers, never string labels.
- Variables are typeless and created on first `LET`; arrays must be `DIM`'d before use.
- No `$` suffix for string variables.
- String concatenation uses `+`.
- Logical operators are `&&`, `||`, `NOT(expr)` — not `AND`/`OR` keywords (though `AND(...)`/`OR(...)`
  function forms also exist for multi-arg use).
- Event handlers (`ONEVENT`) run as isolated execution contexts and **must** end with `END` (not fall off
  the end of the script) to return the interpreter to idle. `SHUTDOWN` kills the whole program including all
  registered events, not just the current context.
- Registry mutations (`CABDBADD`/`CABDBASSIGN`/`CABDBDELETE`) only change in-memory state — a script must
  call `CABDBSAVE()` or the changes are lost on next room reload.

## Code architecture / conventions seen in this repo

`configcabdb.bas` is representative of the typical script shape:
- A short **setup block** at low line numbers that initializes state and does one-time drawing (`SETCOLORSPACE`,
  `CLS`, `FGCOLOR`/`RESETCOLOR`, initial `GOSUB` to a render routine).
- A **polling loop** (e.g. lines 200–220) that checks `ControlActive(...)` for D-pad/button input each pass,
  branches via nested `IF/THEN ELSE IF`, and loops back with `GOTO`.
- **Subroutines** placed after the main loop as `GOSUB` targets (e.g. line 500 for a status-line redraw, line
  510 for a full content redraw), each ending in `RETURN`.
- A final `END` at a high line number as the terminal state reached via `GOTO`.

When writing new cabinet-config-style scripts, follow this same layout: setup → input polling loop → GOSUB
subroutines for drawing → END. Keep drawing logic in subroutines rather than inlining it in the loop, matching
the existing pattern of `GOSUB 500`/`GOSUB 510`.

## No build/test tooling in this repo

There is no build system, linter, or test runner here — this repo is just source scripts and the language
spec. Validation of AGEBasic scripts happens by running them inside the Age of Joy VR Arcade runtime, which is
external to this repository.
