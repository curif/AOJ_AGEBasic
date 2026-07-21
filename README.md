# AOJ AGEBasic

Scripts and language reference for **AGEBasic**, the scripting language used by the [Age of Joy](https://ageofjoy.com) VR Arcade to configure cabinets, rooms, and in-VR behavior.

This is a script development workspace, not a general software project — there is no build system, package manager, or test runner. Scripts are validated by running them inside the Age of Joy VR Arcade runtime, which is external to this repo.

## Contents

| File | Purpose |
|---|---|
| `agebasic_prompt.md` | Authoritative AGEBasic language reference: syntax, commands, functions, VR/cabinet APIs, audio, video. |
| `configcabs.bas` | Configuration cabinet script — lets a user configure their own cabinets from within the arcade. |
| `configcabspec.md` | Spec for the configuration cabinet suite. |

### Workshop tools.
| File | Purpose |
|---|---|
| `workshop/main.bas` | Main menu script for the configuration cabinet. |
| `workshop/game.bas` | Game selection / launch script. |
| `workshop/keyboard.bas` | Reusable on-screen keyboard overlay, invoked via `RUN` from other scripts. |

## AGEBasic in a nutshell

AGEBasic is **not** Microsoft BASIC/QBasic/VB — don't assume standard BASIC features exist unless documented in `agebasic_prompt.md`. Key differences:

- Every line starts with a line number in strictly ascending order.
- Blank lines and comment-only (`REM`) lines are stripped by the parser and are **not** valid jump targets.
- `GOTO`/`GOSUB` target line numbers only, never labels.
- Variables are typeless, created on first `LET`; arrays must be `DIM`'d before use.
- No `$` suffix on string variables; string concatenation uses `+`.
- Logical operators are `&&`, `||`, `NOT(expr)` (plus `AND(...)`/`OR(...)` function forms).
- `ONEVENT` handlers run as isolated execution contexts and must end with `END`.
- Registry mutations (`CABDBADD`/`CABDBASSIGN`/`CABDBDELETE`) are in-memory only until `CABDBSAVE()` is called.

See `CLAUDE.md` for the full set of conventions this repo follows, including the typical script layout (setup → input polling loop → `GOSUB` subroutines for drawing → `END`).

## Contributing

Direct pushes to `main` are restricted — changes go through pull requests.
