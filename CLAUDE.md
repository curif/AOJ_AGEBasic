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

## Good AGEBasic practices

Lessons learned while writing scripts in this repo — apply these even when `agebasic_prompt.md` doesn't
call them out as a rule:

- **Prefer `ARRAY(val1, val2, ...)` over `DIM` + indexed `LETS` for fixed literal lists.** `DIM
  X[n]` followed by several `LETS X[0], X[1], ... = ...` lines is verbose and error-prone (easy to
  miscount indices across lines). When the list is a known-at-write-time set of literals, build it in one
  line: `LET X = ARRAY("a", "b", "c")`. Reserve `DIM` for arrays that are sized/filled dynamically (e.g.
  from a loop or a runtime count) or mutated by index later.
- **Derive counts with `LEN(array)` instead of hand-maintained `*COUNT` variables** when the array was
  built with `ARRAY(...)` — a separate count variable can drift out of sync if the literal list is edited
  later.
- **Escape a `FOR` loop early with `GOTO` once you've found what you're looking for — don't scan the rest
  of the array for nothing.** AGEBasic has no `BREAK`/`EXIT FOR`. A linear search should look like:
  ```
  310 FOR idx = 0 TO COUNT - 1
  320   IF LIST[idx] = TARGET THEN LET FOUNDIDX = idx : GOTO 340
  330 NEXT idx
  340 REM ... code continues here, loop is done either way
  ```
  `GOTO`ing to the line right after the matching `NEXT` is the idiomatic break — it's valid because `GOTO`
  can target any line number, and the abandoned `FOR`'s loop state is simply discarded. Do this for every
  "does this value exist in this array / what's its index" search — it's the common case in this repo
  (resolving a stored config string to its index in an options list).
- **Don't write `ELSE GOTO <next line>` when the next line is already the fall-through.** `IF cond THEN
  GOTO X ELSE GOTO Y` where `Y` is the line immediately following is a no-op `ELSE` — execution falls
  through to `Y` on its own if `cond` is false. Just write `IF cond THEN GOTO X` and let it fall through.
- **Chain mutually-exclusive `IF FIELD = n THEN ...` rows into one `ELSE IF` statement instead of a run of
  separate lines that each re-test from scratch.** A sequence like:
  ```
  3210 IF FIELD = 0 THEN ...
  3220 IF FIELD = 1 THEN ...
  3230 IF FIELD = 2 THEN ...
  ```
  evaluates every condition even after the match, and reads as N independent branches when only one can
  ever fire. Merge them into a single logical statement, continuing across physical lines (no line number
  on the continuation) — the pattern already used in `configcabs.bas`:
  ```
  3210 IF FIELD = 0 THEN ...
       ELSE IF FIELD = 1 THEN ...
       ELSE IF FIELD = 2 THEN ...
  ```
  Only the continuation lines are indented and unnumbered; the next real line number resumes after the
  chain. This is the standard shape for a field-cursor `LEFT`/`RIGHT`/`UP`/`DOWN` handler in this repo.

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

### Screen zone ownership in the `workshop/` family (`main.bas` + its `RUN`-launched children)

`main.bas` is the hub: it draws the title row (0), the six-item menu row (1), and the separator (2), then
hands off control by calling `RUN "<child>.bas"` (e.g. `game.bas`, `crt.bas`) with those rows already on
screen. A callee launched this way:

- **Must not `CLS`.** The screen isn't cleared between `RUN` calls — whatever `main.bas` (or a previous
  callee) last drew is still there when the new script starts.
- **Must not redraw the title/menu/separator rows.** Those belong to `main.bas`; copying its title text or
  its six-item menu list into a child script duplicates code that only `main.bas` should own and drifts out
  of sync with it over time. A child only draws its own content zone (rows 3 onward) and its own footer row
  (`height - 1`).
- **Doesn't need to clean up its zone on exit either** — the `main_resume` handler back in `main.bas`
  (`ONCUSTOM("main_resume")`, see `main.bas`'s own resume block) does a full `CLS` + redraw of everything
  when it regains control, so a callee's leftover content is wiped there, not by the callee itself.

This mirrors how `keyboard.bas` already behaves (see its own header comment): it paints an overlay *on top
of* the caller's existing screen without `CLS`, and only the caller is responsible for blanking the area
underneath once the overlay is done.

## No build/test tooling in this repo

There is no build system, linter, or test runner here — this repo is just source scripts and the language
spec. Validation of AGEBasic scripts happens by running them inside the Age of Joy VR Arcade runtime, which is
external to this repository.

### Static line-number check: `tools/validate_bas.py`

One lightweight exception: `tools/validate_bas.py` is a static checker (plain Python, no dependencies) for the
two "Hard syntax rules" mistakes above that are mechanical enough to catch without executing AGEBasic:

1. Line numbers must be strictly ascending within a file.
2. `GOTO`/`GOSUB` (including inside `ONEVENT`/`ONCUSTOM` registrations) must never target a blank or
   comment-only (`REM ...`) line.

Run it after editing any `.bas` file, before considering the edit done:

```
python3 tools/validate_bas.py                  # checks every *.bas file in the repo
python3 tools/validate_bas.py workshop/foo.bas  # checks specific files
```

It exits non-zero if it finds a problem. It does **not** understand AGEBasic semantics — it can't catch a
missing `END` in an event handler, unbalanced `IF/THEN`, or an undocumented command — so it's a supplement to
careful reading, not a replacement for it. Note that it currently flags a number of pre-existing `GOTO`/`GOSUB`
targets across `configcabs.bas`, `workshop/keyboard.bas`, `workshop/game.bas`, and `workshop/crt.bas` that point
at comment-only label lines (the actual code starts a few lines later, at the next numbered line) — this may
be a real latent bug in those files, or the runtime may tolerate it by falling through to the next executable
line; it hasn't been confirmed against the actual VR Arcade runtime either way. Treat new findings in files you
are actively editing as worth fixing; don't go fix pre-existing occurrences in untouched files unless asked.
