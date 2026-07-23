
5 REM keyboard.bas -- reusable on-screen keyboard overlay.
6 REM Call with: RUN "keyboard.bas" (or COMBINEPATH(AGEBASICPATH(), "keyboard.bas")).
7 REM Config in (set by the caller before RUN; all have defaults):
8 REM   KEYBOARDINPUT        seed text to start editing (default "")
9 REM   KEYBOARDTITLE        prompt text shown above the input line (default "ENTER TEXT")
10 REM   KEYBOARDMAXLEN       max characters allowed (default 20)
11 REM   KEYBOARDRESUMEEVENT  name of the ONCUSTOM event the caller registered
12 REM                        during ITS OWN setup (not inside a nested
13 REM                        handler right before RUN-ing this script) --
14 REM                        fired via EVENTTRIGGER when the user presses Y
15 REM                        or OK (default "keyboard_done")
16 REM Result: KEYBOARDINPUT holds the final typed text when KEYBOARDRESUMEEVENT fires.
17 REM Layout: QWERTY rows with numbers on row 1 and a symbol row (* / , .) below ZXCVBNM, grid centered on screen, SPACE key widened.
18 REM Integration: this script does NOT CLS -- it paints a gray panel (DBOX) on top of
19 REM whatever the caller already has on screen and draws its title/textbox/keys inside
20 REM that panel. When KEYBOARDRESUMEEVENT fires, the panel is still sitting on screen;
21 REM the caller must blank the area it owns underneath (e.g. blank PRINT lines) before
22 REM redrawing its own content. See game.bas's resume handler (~line 3450) for the
23 REM reference pattern.

25 DECLARE KEYBOARDINPUT = ""
30 DECLARE KEYBOARDTITLE = "ENTER TEXT"
40 DECLARE KEYBOARDMAXLEN = 20
45 DECLARE KEYBOARDRESUMEEVENT = "keyboard_done"

60 LET KB_ROW0 = "1234567890"
62 LET KB_ROW1 = "QWERTYUIOP"
64 LET KB_ROW2 = "ASDFGHJKL"
66 LET KB_ROW3 = "ZXCVBNM"
68 LET KB_ROW4 = "*/,."
90 DIM KB_SPECIAL[3]
100 LETS KB_SPECIAL[0], KB_SPECIAL[1], KB_SPECIAL[2] = "DEL", "SPACE", "OK"
102 DIM KB_SPECIAL_LABEL[3]
104 LETS KB_SPECIAL_LABEL[0], KB_SPECIAL_LABEL[1], KB_SPECIAL_LABEL[2] = "[DEL]", "[    SPACE    ]", "[OK]"

110 LET KB_ROW = 0
120 LET KB_COL = 0
130 LETS width, height = SCREENWIDTH(), SCREENHEIGHT()
135 LETS dwidth, dheight = DSCREENWIDTH(), DSCREENHEIGHT()
136 LET charw = dwidth / width
137 LET charh = dheight / height
140 LET lineEmpty = (width - 1) * " "

150 REM compute grid width from the widest row (the special row, with its enlarged SPACE key)
152 LET KB_ROW0W = LEN(KB_ROW0) * 2
154 LET KB_ROW1W = LEN(KB_ROW1) * 2
156 LET KB_ROW2W = LEN(KB_ROW2) * 2
158 LET KB_ROW3W = LEN(KB_ROW3) * 2
159 LET KB_ROW4W = LEN(KB_ROW4) * 2
160 LET KB_SPECIALW = LEN(KB_SPECIAL_LABEL[0]) + LEN(KB_SPECIAL_LABEL[1]) + LEN(KB_SPECIAL_LABEL[2]) + 4
170 LET KB_GRIDW = MAX(MAX(MAX(KB_ROW0W, KB_ROW1W), MAX(KB_ROW2W, KB_ROW3W)), MAX(KB_ROW4W, KB_SPECIALW))
172 LET KB_GRIDW = MIN(KB_GRIDW, width - 1)

180 REM per-row horizontal offsets center each row within the grid, and the grid within the screen
182 LET KB_OFFSETX = MAX(INT((width - KB_GRIDW) / 2), 0)
184 LET KB_OFF0 = INT((KB_GRIDW - KB_ROW0W) / 2)
186 LET KB_OFF1 = INT((KB_GRIDW - KB_ROW1W) / 2)
188 LET KB_OFF2 = INT((KB_GRIDW - KB_ROW2W) / 2)
190 LET KB_OFF3 = INT((KB_GRIDW - KB_ROW3W) / 2)
191 LET KB_OFF4 = INT((KB_GRIDW - KB_ROW4W) / 2)
192 LET KB_OFFSPECIAL = INT((KB_GRIDW - KB_SPECIALW) / 2)

196 REM vertical offset centers the title/input/grid/special block above the footer bar
198 LET KB_OFFSETY = MAX(INT((height - 1 - 11) / 2), 0)

199 REM panel geometry: gray DBOX behind title/textbox/grid (rows 0-8 relative to
201 REM KB_OFFSETY), clamped against the screen's real char/pixel bounds (SCREENWIDTH/
202 REM SCREENHEIGHT via width/height, DSCREENWIDTH/DSCREENHEIGHT via charw/charh) so it
203 REM never goes negative or spills past the edge of a small cabinet display
204 LET KB_PADX = 2
205 LET KB_PADY = 1
206 LET KB_BOXW = KB_GRIDW + KB_PADX * 2
207 LET KB_BOXH = 10 + KB_PADY * 2
208 LET KB_BOXX = MAX(KB_OFFSETX - KB_PADX, 0)
209 LET KB_BOXY = MAX(KB_OFFSETY - KB_PADY, 0)
210 LET KB_BOXW2 = MIN(KB_BOXW, width - KB_BOXX)
211 LET KB_BOXH2 = MIN(KB_BOXH, height - KB_BOXY)
212 REM textbox spans nearly the full panel width, 1-char margin each side
213 LET KB_TEXTX = KB_BOXX + 1
214 LET KB_TEXTW = KB_BOXW2 - 2
215 LET KB_BOXLINE = KB_TEXTW * " "
216 DIM KB_GRAY[3]
217 LETS KB_GRAY[0], KB_GRAY[1], KB_GRAY[2] = 128, 128, 128

220 REM initial draw and event registration; no CLS -- overlay on the caller's screen.
221 REM Gray panel is painted first so title/textbox/grid draw on top of it.
230 DBOX ARRAY(KB_BOXX * charw, KB_BOXY * charh), ARRAY(KB_BOXW2 * charw, KB_BOXH2 * charh), KB_GRAY, 1, KB_GRAY
240 GOSUB 8010
250 GOSUB 8110
260 GOSUB 8210
270 GOSUB 8910
280 END

3000 REM JOYPAD_DOWN: move to the next row, clamping the column to fit
3010 LET KB_ROW = MIN(KB_ROW + 1, 5)
3020 GOSUB 8810 : LET KB_COL = MIN(KB_COL, KB_ROWLEN - 1)
3030 GOSUB 8210
3040 END

3100 REM JOYPAD_UP: move to the previous row, clamping the column to fit
3110 LET KB_ROW = MAX(KB_ROW - 1, 0)
3120 GOSUB 8810 : LET KB_COL = MIN(KB_COL, KB_ROWLEN - 1)
3130 GOSUB 8210
3140 END

3200 REM JOYPAD_LEFT: move the cursor left within the current row
3210 LET KB_COL = MAX(KB_COL - 1, 0)
3220 GOSUB 8210
3230 END

3300 REM JOYPAD_RIGHT: move the cursor right within the current row
3310 GOSUB 8810
3320 LET KB_COL = MIN(KB_COL + 1, KB_ROWLEN - 1)
3330 GOSUB 8210
3340 END

3400 REM JOYPAD_B: press the currently selected key (letter/digit/symbol rows)
3410 IF KB_ROW = 5 THEN GOTO 3450
3420 IF LEN(KEYBOARDINPUT) < KEYBOARDMAXLEN THEN LET KEYBOARDINPUT = KEYBOARDINPUT + IIF(KB_ROW = 0, SUBSTR(KB_ROW0, KB_COL, 1), IIF(KB_ROW = 1, SUBSTR(KB_ROW1, KB_COL, 1), IIF(KB_ROW = 2, SUBSTR(KB_ROW2, KB_COL, 1), IIF(KB_ROW = 3, SUBSTR(KB_ROW3, KB_COL, 1), SUBSTR(KB_ROW4, KB_COL, 1)))))
3430 GOSUB 8110
3440 END

3450 REM JOYPAD_B on the special row: DEL, SPACE, or OK
3460 IF KB_SPECIAL[KB_COL] = "OK" THEN GOTO 3900
3470 IF KB_SPECIAL[KB_COL] = "SPACE" && LEN(KEYBOARDINPUT) < KEYBOARDMAXLEN THEN LET KEYBOARDINPUT = KEYBOARDINPUT + " "
3480 IF KB_SPECIAL[KB_COL] = "DEL" THEN LET KEYBOARDINPUT = SUBSTR(KEYBOARDINPUT, 0, MAX(LEN(KEYBOARDINPUT) - 1, 0))
3490 GOSUB 8110
3495 END

3800 REM JOYPAD_Y: finish and hand the typed text back to the caller
3810 GOTO 3900

3900 REM hand control back to the caller; END must stay off this line --
3902 REM chaining it with CALL EVENTTRIGGER corrupts the expression stack
3904 REM when unwinding back into the caller's resume handler (see game.bas).
3910 OFFEVENT "keyboard"
3920 CALL EVENTTRIGGER(KEYBOARDRESUMEEVENT)
3930 END

8000 REM draw title row, centered, background matches the gray panel
8010 FGCOLOR "WHITE" : BGCOLOR 128, 128, 128 : PRINTCENTERED KB_OFFSETY + 0, SUBSTR(KEYBOARDTITLE, 0, width - 1), 0
8020 SHOW
8030 RETURN

8100 REM draw the current input line: white background, black foreground, left-aligned
8101 REM (typewriter-style) spanning nearly the full panel width, not centered
8110 FGCOLOR "BLACK" : BGCOLOR "WHITE" : PRINT KB_TEXTX, KB_OFFSETY + 2, KB_BOXLINE, 0, 0
8112 PRINT KB_TEXTX, KB_OFFSETY + 2, SUBSTR("> " + KEYBOARDINPUT, 0, KB_TEXTW), 0
8114 SHOW
8116 RETURN

8200 REM draw the keyboard grid (numbers, QWERTY letters, special keys) and footer;
8201 REM keys are white-on-black, drawn after the gray panel/title/textbox
8210 FGCOLOR "WHITE" : BGCOLOR "BLACK" : FOR idx = 0 TO LEN(KB_ROW0) - 1
8212   PRINT KB_OFFSETX + KB_OFF0 + idx * 2, KB_OFFSETY + 4, SUBSTR(KB_ROW0, idx, 1) + " ", (KB_ROW = 0 && KB_COL = idx), 0
8214 NEXT idx
8220 FOR idx = 0 TO LEN(KB_ROW1) - 1
8222   PRINT KB_OFFSETX + KB_OFF1 + idx * 2, KB_OFFSETY + 5, SUBSTR(KB_ROW1, idx, 1) + " ", (KB_ROW = 1 && KB_COL = idx), 0
8224 NEXT idx
8230 FOR idx = 0 TO LEN(KB_ROW2) - 1
8232   PRINT KB_OFFSETX + KB_OFF2 + idx * 2, KB_OFFSETY + 6, SUBSTR(KB_ROW2, idx, 1) + " ", (KB_ROW = 2 && KB_COL = idx), 0
8234 NEXT idx
8240 FOR idx = 0 TO LEN(KB_ROW3) - 1
8242   PRINT KB_OFFSETX + KB_OFF3 + idx * 2, KB_OFFSETY + 7, SUBSTR(KB_ROW3, idx, 1) + " ", (KB_ROW = 3 && KB_COL = idx), 0
8244 NEXT idx
8245 FOR idx = 0 TO LEN(KB_ROW4) - 1
8246   PRINT KB_OFFSETX + KB_OFF4 + idx * 2, KB_OFFSETY + 8, SUBSTR(KB_ROW4, idx, 1) + " ", (KB_ROW = 4 && KB_COL = idx), 0
8248 NEXT idx
8250 LET kbx = KB_OFFSETX + KB_OFFSPECIAL
8252 FOR idx = 0 TO 2
8254   PRINT kbx, KB_OFFSETY + 9, KB_SPECIAL_LABEL[idx], (KB_ROW = 5 && KB_COL = idx), 0
8256   LET kbx = kbx + LEN(KB_SPECIAL_LABEL[idx]) + 2
8258 NEXT idx
8260 FGCOLOR "WHITE" : BGCOLOR "BLUE"
8270 PRINT 0, height - 1, lineEmpty, 0, 0
8280 PRINT 0, height - 1, SUBSTR("<-> ^v MOVE   B:PRESS   Y:DONE", 0, width - 1), 0, 0
8290 RESETCOLOR
8295 SHOW
8300 RETURN


8800 REM compute KB_ROWLEN = number of keys in the current row
8810 IF KB_ROW = 0 THEN LET KB_ROWLEN = LEN(KB_ROW0)
8820 IF KB_ROW = 1 THEN LET KB_ROWLEN = LEN(KB_ROW1)
8830 IF KB_ROW = 2 THEN LET KB_ROWLEN = LEN(KB_ROW2)
8840 IF KB_ROW = 3 THEN LET KB_ROWLEN = LEN(KB_ROW3)
8842 IF KB_ROW = 4 THEN LET KB_ROWLEN = LEN(KB_ROW4)
8845 IF KB_ROW = 5 THEN LET KB_ROWLEN = 3
8850 RETURN

8900 REM register control event handlers as group "keyboard"; OFFEVENT'd as
8902 REM a unit at the single real exit point (3900) before handing control
8904 REM back to the caller via EVENTTRIGGER(KEYBOARDRESUMEEVENT).
8910 ONEVENT ONCONTROL("JOYPAD_DOWN", "pressed") GOTO 3010 NAME "keyboard"
8920 ONEVENT ONCONTROL("JOYPAD_UP", "pressed") GOTO 3110 NAME "keyboard"
8930 ONEVENT ONCONTROL("JOYPAD_LEFT", "pressed") GOTO 3210 NAME "keyboard"
8940 ONEVENT ONCONTROL("JOYPAD_RIGHT", "pressed") GOTO 3310 NAME "keyboard"
8950 ONEVENT ONCONTROL("JOYPAD_B", "pressed") GOTO 3410 NAME "keyboard"
8960 ONEVENT ONCONTROL("JOYPAD_Y", "pressed") GOTO 3810 NAME "keyboard"
8970 RETURN
