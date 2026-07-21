
20 LET CABNAME = "test"
30 LET ROMLIST = GETFILESARRAY(COMBINEPATH(ROOTPATH(), "downloads"), 0)
40 LET ROMCOUNT = LEN(ROMLIST)
50 LET DISKCORES = GETFILESARRAY(COMBINEPATH(ROOTPATH(), "cores"), 0)
60 LET DISKCORECOUNT = LEN(DISKCORES)
70 DIM CORELIST[3 + DISKCORECOUNT]
80 LETS CORELIST[0], CORELIST[1], CORELIST[2] = "mame2003+", "mame2010", "fbneo"
90 LET CORECOUNT = 3
95 IF DISKCORECOUNT = 0 THEN GOTO 140
100 FOR idx = 0 TO DISKCORECOUNT - 1
110   LET fname = DISKCORES[idx]
120   IF SUBSTR(fname, 0, 3) = "lib" && SUBSTR(fname, LEN(fname) - 3, 3) = ".so" THEN LET CORELIST[CORECOUNT] = SUBSTR(fname, 3, LEN(fname) - 6) : LET CORECOUNT = CORECOUNT + 1
130 NEXT idx
140 DIM SPACELIST[8]
150 LETS SPACELIST[0], SPACELIST[1], SPACELIST[2], SPACELIST[3], SPACELIST[4], SPACELIST[5], SPACELIST[6], SPACELIST[7] = "1x1x1", "1x2x1", "2x1x1", "2x2x1", "1x1x2", "2x1x2", "1x2x2", "2x2x2"
160 LET SPACECOUNT = 8
170 LET ROMVAL = CABDBGETINFO(CABNAME, "rom")
180 LET YEARVAL = VAL(CABDBGETINFO(CABNAME, "year"))
190 LET COREVAL = CABDBGETINFO(CABNAME, "core")
195 LET AUTHORVAL = CABDBGETINFO(CABNAME, "author")
200 LET TTLVAL = VAL(CABDBGETINFO(CABNAME, "timetoload"))
210 LET SPACEVAL = CABDBGETINFO(CABNAME, "space")
220 LET ROMIDX = -1
225 IF ROMCOUNT = 0 THEN GOTO 260
230 FOR idx = 0 TO ROMCOUNT - 1
240   IF ROMLIST[idx] = ROMVAL THEN LET ROMIDX = idx
250 NEXT idx
260 LET COREIDX = -1
270 FOR idx = 0 TO CORECOUNT - 1
280   IF CORELIST[idx] = COREVAL THEN LET COREIDX = idx
290 NEXT idx
300 LET SPACEIDX = -1
310 FOR idx = 0 TO SPACECOUNT - 1
320   IF SPACELIST[idx] = SPACEVAL THEN LET SPACEIDX = idx
330 NEXT idx
340 LET FIELD = 0
350 LET EXITMODE = 0
370 LETS width, height = SCREENWIDTH(), SCREENHEIGHT()
380 LET lineEmpty = (width - 1) * " "

400 REM initial draw and event registration
410 CLS
420 GOSUB 8010
430 GOSUB 8110
440 GOSUB 8210
450 GOSUB 8310
460 GOSUB 8510
470 GOSUB 8910
471 REM registered once here (game.bas's own setup), not inside a nested
472 REM control-handler context right before RUN "keyboard.bas" -- mirrors
473 REM how main.bas registers "main_resume" during its own setup (see
474 REM main.bas:22) so the handler is reliably in place before it is ever
475 REM needed, regardless of RUN nesting depth.
476 ONEVENT ONCUSTOM("game_author_resume") GOTO 3450 NAME "game_kb"
480 END

3000 REM JOYPAD_DOWN: move field cursor down
3010 LET FIELD = FIELD + IIF(FIELD < 6, 1, 0)
3030 GOSUB 8310 : GOSUB 8510
3040 END

3100 REM JOYPAD_UP: move field cursor up, or exit without saving if already at top
3110 IF FIELD = 0 THEN GOTO 3160 ELSE GOTO 3120
3120 LET FIELD = FIELD - 1
3140 GOSUB 8310 : GOSUB 8510
3150 END

3160 REM exit without saving: END must not be colon-chained onto the same
3161 REM line as CALL EVENTTRIGGER -- that corrupts the expression stack
3162 REM when unwinding back from the nested main_resume handler.
3163 OFFEVENT "game" : OFFEVENT "game_kb"
3164 CALL EVENTTRIGGER("main_resume")
3165 END

3200 REM JOYPAD_LEFT: decrease the value of the current field
3210 IF FIELD = 0 && ROMCOUNT > 0 THEN LET ROMIDX = MAX(ROMIDX - 1, 0) : LET ROMVAL = ROMLIST[ROMIDX]
3220 IF FIELD = 1 THEN LET YEARVAL = MAX(YEARVAL - 1, 1970)
3230 IF FIELD = 2 && CORECOUNT > 0 THEN LET COREIDX = MAX(COREIDX - 1, 0) : LET COREVAL = CORELIST[COREIDX]
3240 IF FIELD = 3 THEN LET TTLVAL = MAX(TTLVAL - 1, 0)
3250 IF FIELD = 4 THEN LET SPACEIDX = MAX(SPACEIDX - 1, 0) : LET SPACEVAL = SPACELIST[SPACEIDX]
3260 IF FIELD = 6 THEN LET EXITMODE = 1 - EXITMODE
3270 GOSUB 8310
3280 END

3300 REM JOYPAD_RIGHT: increase the value of the current field
3310 IF FIELD = 0 && ROMCOUNT > 0 THEN LET ROMIDX = MIN(ROMIDX + 1, ROMCOUNT - 1) : LET ROMVAL = ROMLIST[ROMIDX]
3320 IF FIELD = 1 THEN LET YEARVAL = YEARVAL + 1
3330 IF FIELD = 2 && CORECOUNT > 0 THEN LET COREIDX = MIN(COREIDX + 1, CORECOUNT - 1) : LET COREVAL = CORELIST[COREIDX]
3340 IF FIELD = 3 THEN LET TTLVAL = TTLVAL + 1
3350 IF FIELD = 4 THEN LET SPACEIDX = MIN(SPACEIDX + 1, SPACECOUNT - 1) : LET SPACEVAL = SPACELIST[SPACEIDX]
3360 IF FIELD = 6 THEN LET EXITMODE = 1 - EXITMODE
3370 GOSUB 8310
3380 END

3400 REM JOYPAD_B: FIELD 5 (AUTHOR) launches the shared keyboard.bas overlay;
3402 REM FIELD 6 (EXIT) commits SAVE/EXIT-without-save. END below must stay
3404 REM off the EVENTTRIGGER line -- chaining it corrupts the expression
3406 REM stack when unwinding back from main_resume (see 3160).
3410 IF FIELD = 5 THEN GOTO 3430
3415 IF FIELD = 6 THEN GOSUB 3510 : OFFEVENT "game" : CALL EVENTTRIGGER("main_resume")
3420 END

3421 REM launch keyboard.bas to edit AUTHORVAL; hand off input ownership to
3422 REM it. "game_author_resume" is already registered (see line 476, in
3423 REM game.bas's own setup) -- just point it at this run's config and go.
3424 REM END below matters: without it, execution would fall through into
3425 REM the resume block before the keyboard overlay has actually been used
3426 REM (RUN returns as soon as the callee finishes registering its own
3427 REM handlers).
3430 LET KEYBOARDINPUT = AUTHORVAL
3432 LET KEYBOARDTITLE = "AUTHOR NAME"
3434 LET KEYBOARDMAXLEN = 24
3436 LET KEYBOARDRESUMEEVENT = "game_author_resume"
3440 OFFEVENT "game"
3442 RUN "keyboard.bas"
3444 END

3450 REM resume here once the keyboard overlay finishes (Y pressed); re-read
3452 REM the result and re-register game's own control handlers, since
3454 REM OFFEVENT "game" was called before RUN switched context away. The
3455 REM keyboard overlay's gray panel may still be sitting on screen over
3456 REM this whole area (it doesn't CLS -- see keyboard.bas), so blank every
3457 REM row it could have covered before redrawing this screen's content.
3458 FOR kbClearRow = 0 TO height - 2
3459   PRINT 0, kbClearRow, lineEmpty, 0, 0
3461 NEXT kbClearRow
3463 LET AUTHORVAL = KEYBOARDINPUT
3465 GOSUB 8910
3467 GOSUB 8010 : GOSUB 8110 : GOSUB 8210 : GOSUB 8310 : GOSUB 8510
3469 END

3500 REM commit the selected EXIT action (GOSUB target)
3510 IF EXITMODE = 0 THEN GOSUB 3610
3520 RETURN

3600 REM persist edits to disk and reload the workshop test cabinet
3610 CALL CABDBSETINFO(CABNAME, "rom", ROMVAL)
3620 CALL CABDBSETINFO(CABNAME, "year", STR(YEARVAL))
3630 CALL CABDBSETINFO(CABNAME, "core", COREVAL)
3640 CALL CABDBSETINFO(CABNAME, "timetoload", STR(TTLVAL))
3650 CALL CABDBSETINFO(CABNAME, "space", SPACEVAL)
3655 CALL CABDBSETINFO(CABNAME, "author", AUTHORVAL)
3660 CALL WORKSHOPRELOAD()
3670 RETURN


3800 REM JOYPAD_Y: jump to the EXIT field so the user can choose SAVE or
3802 REM EXIT-without-save, same as reaching that row via UP/DOWN.
3810 LET FIELD = 6
3812 GOSUB 8310 : GOSUB 8510
3814 END

8000 REM draw title row
8010 PRINT 0, 0, SUBSTR("WORKSHOP CABINET CONFIGURATION ---------", 0, width - 1), 0, 0
8020 SHOW
8030 RETURN

8100 REM draw menu row with GAME inverted
8110 PRINT 0, 1, lineEmpty, 0, 0
8120 PRINT 0, 1, "[GAME]", 1, 0
8130 IF width > 6 THEN PRINT 6, 1, SUBSTR("[CRT][MODEL][VIDEO][PARTS][FILES]", 0, width - 7), 0, 0
8140 SHOW
8150 RETURN

8200 REM draw separator
8210 PRINT 0, 2, (width - 1) * "-", 0, 0
8220 SHOW
8230 RETURN

8300 REM draw each field row directly (no loop); only the row matching FIELD is inverted
8310 PRINT 0, 3, "ROM  : < " + ROMVAL + " >", FIELD = 0, 0
8320 PRINT 0, 4, "YEAR : < " + STR(YEARVAL) + " >", FIELD = 1, 0
8330 PRINT 0, 5, "CORE : < " + COREVAL + " >", FIELD = 2, 0
8340 PRINT 0, 6, "TIME TO LOAD: < " + STR(TTLVAL) + " > (secs)", FIELD = 3, 0
8350 PRINT 0, 7, "SPACE: < " + SPACEVAL + " >", FIELD = 4, 0
8355 PRINT 0, 8, "AUTHOR: " + AUTHORVAL + "  (B: EDIT)", FIELD = 5, 0
8360 PRINT 0, 9, "EXIT: < " + IIF(EXITMODE = 0, "SAVE", "EXIT Without save") + " >", FIELD = 6, 0
8430 SHOW
8440 RETURN

8500 REM draw footer help line, context-sensitive on FIELD
8505 IF FIELD = 5 THEN LET foot = "B: EDIT NAME  ^v MOVE  Y:EXIT"
8510 IF FIELD = 6 THEN LET foot = "<-> SAVE/NO-SAVE  ^v MOVE  Y:EXIT"
8520 IF FIELD != 5 && FIELD != 6 THEN LET foot = "<-> VALUE  ^v MOVE  Y:EXIT"
8530 FGCOLOR "WHITE" : BGCOLOR "BLUE"
8540 PRINT 0, height - 1, lineEmpty, 0, 0
8550 PRINT 0, height - 1, SUBSTR(foot, 0, width - 1), 0, 0
8560 RESETCOLOR
8570 SHOW
8580 RETURN

8900 REM register control event handlers as group "game"; OFFEVENT'd as a
8902 REM unit at every real exit point (3110, 3415, 3810) before handing
8904 REM control back to main.bas via EVENTTRIGGER("main_resume"); also
8906 REM re-registered at 3464 after the keyboard.bas overlay returns.
8910 ONEVENT ONCONTROL("JOYPAD_DOWN", "pressed") GOTO 3010 NAME "game"
8920 ONEVENT ONCONTROL("JOYPAD_UP", "pressed") GOTO 3110 NAME "game"
8930 ONEVENT ONCONTROL("JOYPAD_LEFT", "pressed") GOTO 3210 NAME "game"
8940 ONEVENT ONCONTROL("JOYPAD_RIGHT", "pressed") GOTO 3310 NAME "game"
8950 ONEVENT ONCONTROL("JOYPAD_B", "pressed") GOTO 3410 NAME "game"
8955 ONEVENT ONCONTROL("JOYPAD_Y", "pressed") GOTO 3810 NAME "game"
8970 RETURN
