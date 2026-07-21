
20 LET CABNAME = "test"
30 LET CRTTYPELIST = ARRAY("19i", "19i-fresnel", "19i-agebasic", "32i", "50i", "circle", "square", "19i-2x1", "19i-1x2", "19i-3x1", "19i-3x1-18deg", "dome-concave", "dome-convex", "no-crt", "custom")
70 LET CRTTYPECOUNT = LEN(CRTTYPELIST)
90 LET ORIENTLIST = ARRAY("vertical", "horizontal")
100 LET ORIENTCOUNT = LEN(ORIENTLIST)
115 REM crt.screen.shader is optional in CabinetInformation.cs (Screen.validate() only checks
116 REM it against ShaderScreen.Exists when non-empty) -- "" is a valid saved value, shown as (none).
120 LET SHADERLIST = ARRAY("", "crt", "crtlod", "damage", "clean", "crt-additive", "projector", "projectorlod")
140 LET SHADERCOUNT = LEN(SHADERLIST)
160 LET DAMAGELIST = ARRAY("none", "low", "medium", "high")
170 LET DAMAGECOUNT = LEN(DAMAGELIST)
190 LET TYPEVAL = CABDBGETINFO(CABNAME, "crt.type")
200 LET ORIENTVAL = CABDBGETINFO(CABNAME, "crt.orientation")
210 LET SHADERVAL = CABDBGETINFO(CABNAME, "crt.screen.shader")
220 LET DAMAGEVAL = CABDBGETINFO(CABNAME, "crt.screen.damage")
230 LET INVERTXVAL = IIF(LCASE(STR(CABDBGETINFO(CABNAME, "crt.screen.invertx"))) = "true", 1, 0)
240 LET INVERTYVAL = IIF(LCASE(STR(CABDBGETINFO(CABNAME, "crt.screen.inverty"))) = "true", 1, 0)
250 LET GAMMAVAL = CABDBGETINFO(CABNAME, "crt.screen.gamma")
260 LET BRIGHTNESSVAL = CABDBGETINFO(CABNAME, "crt.screen.brightness")
270 IF GAMMAVAL = "" THEN LET GAMMAVAL = "1.0"
280 IF BRIGHTNESSVAL = "" THEN LET BRIGHTNESSVAL = "1.0"
300 LET TYPEIDX = 0
310 FOR idx = 0 TO CRTTYPECOUNT - 1
320   IF CRTTYPELIST[idx] = TYPEVAL THEN LET TYPEIDX = idx : GOTO 340
330 NEXT idx
340 LET ORIENTIDX = 0
350 FOR idx = 0 TO ORIENTCOUNT - 1
360   IF ORIENTLIST[idx] = ORIENTVAL THEN LET ORIENTIDX = idx : GOTO 380
370 NEXT idx
380 LET SHADERIDX = 0
390 FOR idx = 0 TO SHADERCOUNT - 1
400   IF SHADERLIST[idx] = SHADERVAL THEN LET SHADERIDX = idx : GOTO 420
410 NEXT idx
420 LET DAMAGEIDX = 0
430 FOR idx = 0 TO DAMAGECOUNT - 1
440   IF DAMAGELIST[idx] = DAMAGEVAL THEN LET DAMAGEIDX = idx : GOTO 470
450 NEXT idx
470 LET FIELD = 0
480 LET EXITMODE = 0
490 LETS width, height = SCREENWIDTH(), SCREENHEIGHT()
500 LET lineEmpty = (width - 1) * " "

600 REM initial draw and event registration. Title (row 0), menu (row 1) and
601 REM separator (row 2) are main.bas's reserved zone -- they're already on
602 REM screen when main.bas RUNs this script, so no CLS and no redraw of them
603 REM here; this script only owns rows 3+ (its fields) and the footer.
610 GOSUB 8310
620 GOSUB 8510
630 GOSUB 8910
640 END

3000 REM JOYPAD_DOWN: move field cursor down
3010 LET FIELD = FIELD + IIF(FIELD < 8, 1, 0)
3030 GOSUB 8310 : GOSUB 8510
3040 END

3100 REM JOYPAD_UP: move field cursor up, or exit without saving if already at top
3110 IF FIELD = 0 THEN GOTO 3160
3120 LET FIELD = FIELD - 1
3140 GOSUB 8310 : GOSUB 8510
3150 END

3160 REM exit without saving: END must not be colon-chained onto the same
3161 REM line as CALL EVENTTRIGGER -- that corrupts the expression stack
3162 REM when unwinding back from the nested main_resume handler.
3163 OFFEVENT "crt"
3164 CALL EVENTTRIGGER("main_resume")
3165 END

3200 REM JOYPAD_LEFT: decrease/cycle the value of the current field
3210 IF FIELD = 0 THEN LET TYPEIDX = MAX(TYPEIDX - 1, 0) : LET TYPEVAL = CRTTYPELIST[TYPEIDX]
     ELSE IF FIELD = 1 THEN LET ORIENTIDX = MAX(ORIENTIDX - 1, 0) : LET ORIENTVAL = ORIENTLIST[ORIENTIDX]
     ELSE IF FIELD = 2 THEN LET SHADERIDX = MAX(SHADERIDX - 1, 0) : LET SHADERVAL = SHADERLIST[SHADERIDX]
     ELSE IF FIELD = 3 THEN LET DAMAGEIDX = MAX(DAMAGEIDX - 1, 0) : LET DAMAGEVAL = DAMAGELIST[DAMAGEIDX]
     ELSE IF FIELD = 4 THEN LET INVERTXVAL = 1 - INVERTXVAL
     ELSE IF FIELD = 5 THEN LET INVERTYVAL = 1 - INVERTYVAL
     ELSE IF FIELD = 6 THEN LET GAMMAVAL = STR(MAX(VAL(GAMMAVAL) - 0.1, 0.1))
     ELSE IF FIELD = 7 THEN LET BRIGHTNESSVAL = STR(MAX(VAL(BRIGHTNESSVAL) - 0.1, 0.1))
     ELSE IF FIELD = 8 THEN LET EXITMODE = 1 - EXITMODE
3300 GOSUB 8310
3310 END

3400 REM JOYPAD_RIGHT: increase/cycle the value of the current field
3410 IF FIELD = 0 THEN LET TYPEIDX = MIN(TYPEIDX + 1, CRTTYPECOUNT - 1) : LET TYPEVAL = CRTTYPELIST[TYPEIDX]
     ELSE IF FIELD = 1 THEN LET ORIENTIDX = MIN(ORIENTIDX + 1, ORIENTCOUNT - 1) : LET ORIENTVAL = ORIENTLIST[ORIENTIDX]
     ELSE IF FIELD = 2 THEN LET SHADERIDX = MIN(SHADERIDX + 1, SHADERCOUNT - 1) : LET SHADERVAL = SHADERLIST[SHADERIDX]
     ELSE IF FIELD = 3 THEN LET DAMAGEIDX = MIN(DAMAGEIDX + 1, DAMAGECOUNT - 1) : LET DAMAGEVAL = DAMAGELIST[DAMAGEIDX]
     ELSE IF FIELD = 4 THEN LET INVERTXVAL = 1 - INVERTXVAL
     ELSE IF FIELD = 5 THEN LET INVERTYVAL = 1 - INVERTYVAL
     ELSE IF FIELD = 6 THEN LET GAMMAVAL = STR(MIN(VAL(GAMMAVAL) + 0.1, 3.0))
     ELSE IF FIELD = 7 THEN LET BRIGHTNESSVAL = STR(MIN(VAL(BRIGHTNESSVAL) + 0.1, 3.0))
     ELSE IF FIELD = 8 THEN LET EXITMODE = 1 - EXITMODE
3500 GOSUB 8310
3510 END

3600 REM JOYPAD_B: only FIELD 8 (EXIT) does anything, commits SAVE/EXIT-without-save.
3601 REM END must stay off the EVENTTRIGGER line -- chaining it corrupts the
3602 REM expression stack when unwinding back from main_resume (see 3160).
3610 IF FIELD = 8 && EXITMODE = 0 THEN GOSUB 3810
3612 IF FIELD = 8 THEN OFFEVENT "crt" : CALL EVENTTRIGGER("main_resume")
3620 END

3800 REM persist edits to disk and reload the workshop test cabinet
3810 CALL CABDBSETINFO(CABNAME, "crt.type", TYPEVAL)
3820 CALL CABDBSETINFO(CABNAME, "crt.orientation", ORIENTVAL)
3830 CALL CABDBSETINFO(CABNAME, "crt.screen.shader", SHADERVAL)
3840 CALL CABDBSETINFO(CABNAME, "crt.screen.damage", DAMAGEVAL)
3850 CALL CABDBSETINFO(CABNAME, "crt.screen.invertx", STR(INVERTXVAL))
3860 CALL CABDBSETINFO(CABNAME, "crt.screen.inverty", STR(INVERTYVAL))
3870 CALL CABDBSETINFO(CABNAME, "crt.screen.gamma", GAMMAVAL)
3880 CALL CABDBSETINFO(CABNAME, "crt.screen.brightness", BRIGHTNESSVAL)
3890 CALL WORKSHOPRELOAD()
3900 RETURN

3950 REM JOYPAD_Y: jump to the EXIT field so the user can choose SAVE or
3951 REM EXIT-without-save, same as reaching that row via UP/DOWN.
3960 LET FIELD = 8
3970 GOSUB 8310 : GOSUB 8510
3980 END

8300 REM draw each field row directly (no loop); only the row matching FIELD is inverted
8310 PRINT 0, 3, lineEmpty, 0, 0 : PRINT 0, 3, "TYPE      : < " + TYPEVAL + " >", FIELD = 0, 0
8320 PRINT 0, 4, lineEmpty, 0, 0 : PRINT 0, 4, "ORIENT    : < " + ORIENTVAL + " >", FIELD = 1, 0
8330 PRINT 0, 5, lineEmpty, 0, 0 : PRINT 0, 5, "SHADER    : < " + IIF(SHADERVAL = "", "(none)", SHADERVAL) + " >", FIELD = 2, 0
8340 PRINT 0, 6, lineEmpty, 0, 0 : PRINT 0, 6, "DAMAGE    : < " + DAMAGEVAL + " >", FIELD = 3, 0
8350 PRINT 0, 7, lineEmpty, 0, 0 : PRINT 0, 7, "INVERT X  : < " + IIF(INVERTXVAL = 1, "YES", "NO") + " >", FIELD = 4, 0
8360 PRINT 0, 8, lineEmpty, 0, 0 : PRINT 0, 8, "INVERT Y  : < " + IIF(INVERTYVAL = 1, "YES", "NO") + " >", FIELD = 5, 0
8370 PRINT 0, 9, lineEmpty, 0, 0 : PRINT 0, 9, "GAMMA     : < " + GAMMAVAL + " >", FIELD = 6, 0
8380 PRINT 0, 10, lineEmpty, 0, 0 : PRINT 0, 10, "BRIGHTNESS: < " + BRIGHTNESSVAL + " >", FIELD = 7, 0
8390 PRINT 0, 11, lineEmpty, 0, 0 : PRINT 0, 11, "EXIT: < " + IIF(EXITMODE = 0, "SAVE", "EXIT Without save") + " >", FIELD = 8, 0
8430 SHOW
8440 RETURN

8500 REM draw footer help line, context-sensitive on FIELD
8510 IF FIELD = 8 THEN LET foot = "<-> SAVE/NO-SAVE  ^v MOVE  Y:EXIT" ELSE LET foot = "<-> VALUE  ^v MOVE  Y:EXIT"
8530 FGCOLOR "WHITE" : BGCOLOR "BLUE"
8540 PRINT 0, height - 1, lineEmpty, 0, 0
8550 PRINT 0, height - 1, SUBSTR(foot, 0, width - 1), 0, 0
8560 RESETCOLOR
8570 SHOW
8580 RETURN

8900 REM register control event handlers as group "crt"; OFFEVENT'd as a
8901 REM unit at every real exit point (3110-via-3160, 3610).
8910 ONEVENT ONCONTROL("JOYPAD_DOWN", "pressed") GOTO 3010 NAME "crt"
8920 ONEVENT ONCONTROL("JOYPAD_UP", "pressed") GOTO 3110 NAME "crt"
8930 ONEVENT ONCONTROL("JOYPAD_LEFT", "pressed") GOTO 3210 NAME "crt"
8940 ONEVENT ONCONTROL("JOYPAD_RIGHT", "pressed") GOTO 3410 NAME "crt"
8950 ONEVENT ONCONTROL("JOYPAD_B", "pressed") GOTO 3610 NAME "crt"
8955 ONEVENT ONCONTROL("JOYPAD_Y", "pressed") GOTO 3960 NAME "crt"
8970 RETURN
