#!/usr/bin/env python3
"""Static line-number checker for AGEBasic (.bas) scripts.

Catches the two mistakes described in CLAUDE.md's "Hard syntax rules":
  1. Line numbers must be strictly ascending within a file.
  2. GOTO/GOSUB (including inside ONEVENT/ONCUSTOM registrations) must never
     target a blank line or a comment-only (REM ...) line -- those are
     stripped by the parser and are not valid jump targets.

This is a static check only: it does not execute AGEBasic, know about
AGEBasic's builtin functions/commands, or understand control flow. It cannot
catch missing END statements, unbalanced IF/THEN, or anything semantic.

Usage:
    python3 tools/validate_bas.py [file.bas ...]

With no arguments, validates every *.bas file in the repo.
Exits non-zero if any file has a problem.
"""

import re
import sys
from pathlib import Path

LINE_RE = re.compile(r"^(\d+)\s+(.*)$")
JUMP_RE = re.compile(r"\b(?:GOTO|GOSUB)\s+(\d+)")

REPO_ROOT = Path(__file__).resolve().parent.parent


def find_bas_files():
    return sorted(REPO_ROOT.rglob("*.bas"))


def check_file(path: Path):
    """Return a list of human-readable problem strings for one file."""
    problems = []
    executable_lines = set()
    prev_number = -1

    text = path.read_text()

    for lineno, raw in enumerate(text.splitlines(), start=1):
        match = LINE_RE.match(raw)
        if not match:
            continue  # continuation line (no leading number) or truly blank
        number = int(match.group(1))
        rest = match.group(2).strip()

        if number <= prev_number:
            problems.append(
                f"line {lineno}: number {number} is not greater than "
                f"the previous line number {prev_number}"
            )
        prev_number = number

        if rest and not rest.startswith("REM"):
            executable_lines.add(number)

    for lineno, raw in enumerate(text.splitlines(), start=1):
        for jump_match in JUMP_RE.finditer(raw):
            target = int(jump_match.group(1))
            if target not in executable_lines:
                problems.append(
                    f"line {lineno}: jumps to line {target}, which is "
                    "blank, comment-only, or does not exist"
                )

    return problems


def main(argv):
    paths = [Path(arg) for arg in argv] if argv else find_bas_files()

    had_problems = False
    for path in paths:
        problems = check_file(path)
        if problems:
            had_problems = True
            print(f"{path}:")
            for problem in problems:
                print(f"  {problem}")
        else:
            print(f"{path}: OK")

    return 1 if had_problems else 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
