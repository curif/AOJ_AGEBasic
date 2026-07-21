
20 DIM MENUNAMES[6]
30 LETS MENUNAMES[0], MENUNAMES[1], MENUNAMES[2] = "GAME", "CRT", "MODEL"
40 LETS MENUNAMES[3], MENUNAMES[4], MENUNAMES[5] = "VIDEO", "PARTS", "FILES"
50 DIM HELPTEXT[6]
60 LET HELPTEXT[0] = "Configure cores, ROMs, name, year, etc."
70 LET HELPTEXT[1] = "Configure the CRT screen: type, orientation, shader and geometry."
80 LET HELPTEXT[2] = "Configure the cabinet model, style and coin slot."
90 LET HELPTEXT[3] = "Configure the attraction video and audio."
100 LET HELPTEXT[4] = "Configure the cabinet parts: art, color, material, etc for each one."
110 LET HELPTEXT[5] = "Configure the files distributed with the cabinet."
120 LETS width, height = SCREENWIDTH(), SCREENHEIGHT()
130 LET lineEmpty = (width - 1) * " "
140 LET MENUSEL = 0

200 REM initial draw and event registration
210 CLS
220 GOSUB 7010
230 GOSUB 7110
240 GOSUB 7210
250 GOSUB 7910
260 ONEVENT ONCUSTOM("main_resume") GOTO 2610
270 END

2000 REM JOYPAD_LEFT: move menu selection left
2010 LET MENUSEL = MENUSEL - IIF(MENUSEL > 0, 1, 0)
2020 GOSUB 7110 : GOSUB 7210
2030 END

2100 REM JOYPAD_RIGHT: move menu selection right
2110 LET MENUSEL = MENUSEL + IIF(MENUSEL < 5, 1, 0)
2120 GOSUB 7110 : GOSUB 7210
2130 END

2200 REM JOYPAD_B: select the current menu option
2210 IF MENUSEL = 0 THEN GOSUB 2310 ELSE IF MENUSEL = 1 THEN GOSUB 2340 ELSE GOSUB 2410
2220 END

2300 REM launch the GAME subprogram; hand off input ownership to it.
2302 REM Any called *.bas program signals "main_resume" via EVENTTRIGGER
2304 REM when it is really done (see line 2610) -- RUN itself returns as
2306 REM soon as the callee finishes registering its own handlers.
2310 OFFEVENT "mainmenu"
2320 RUN "game.bas"
2330 RETURN

2335 REM launch the CRT subprogram; same hand-off mechanism as GAME above.
2340 OFFEVENT "mainmenu"
2350 RUN "crt.bas"
2360 RETURN

2400 REM other menu options: not implemented yet
2410 PRINT 0, 3, lineEmpty, 0, 0
2420 PRINT 0, 3, "Not implemented yet.", 0, 0
2430 SHOW
2440 RETURN

2500 REM JOYPAD_Y: leave the configuration tool
2510 SHUTDOWN

2600 REM main_resume handoff (GOTO target of ONCUSTOM "main_resume"): the
2602 REM callee has already turned off its own handlers by this point.
2610 CLS
2620 GOSUB 7010 : GOSUB 7110 : GOSUB 7210
2630 GOSUB 7910
2640 END

7000 REM draw title row
7010 PRINT 0, 0, SUBSTR("WORKSHOP CABINET CONFIGURATION ---------", 0, width - 1), 0, 0
7020 SHOW
7030 RETURN

7100 REM draw menu row, inverting the selected item
7110 PRINT 0, 1, lineEmpty, 0, 0
7120 LET col = 0
7130 FOR idx = 0 TO 5
7140   LET label = "[" + MENUNAMES[idx] + "]"
7150   IF col + LEN(label) <= width - 1 THEN PRINT col, 1, label, IIF(idx = MENUSEL, 1, 0), 0
7160   LET col = col + LEN(label)
7170 NEXT idx
7180 SHOW
7190 RETURN

7200 REM draw separator, help body and control footer
7210 PRINT 0, 2, (width - 1) * "-", 0, 0
7220 FOR ln = 3 TO height - 2
7230   PRINT 0, ln, lineEmpty, 0, 0
7240 NEXT ln
7250 LET WRAPTEXT = HELPTEXT[MENUSEL] : GOSUB 7410
7260 FGCOLOR "WHITE" : BGCOLOR "BLUE"
7270 PRINT 0, height - 1, lineEmpty, 0, 0
7280 PRINT 0, height - 1, SUBSTR("Press <-> to select, Y: EXIT", 0, width - 1), 0, 0
7290 RESETCOLOR
7300 SHOW
7310 RETURN

7400 REM word-wrap WRAPTEXT across the help area (rows 3..height-2), width chars per row
7410 LET wrow = 3
7420 LET wline = ""
7430 LET wcount = COUNTMEMBERS(WRAPTEXT, " ")
7440 FOR widx = 0 TO wcount - 1
7450   LET wword = GETMEMBER(WRAPTEXT, widx, " ")
7460   LET wcand = IIF(wline = "", wword, wline + " " + wword)
7470   IF LEN(wcand) <= width - 1 THEN LET wline = wcand ELSE GOSUB 7520 : LET wline = wword
7480 NEXT widx
7490 IF wline != "" THEN GOSUB 7520
7500 RETURN

7510 REM flush wline to row wrow and advance; no-op once past the help area (GOSUB target)
7520 IF wrow > height - 2 THEN RETURN
7530 PRINT 0, wrow, SUBSTR(wline, 0, width - 1), 0, 0
7540 LET wrow = wrow + 1
7550 RETURN

7900 REM register main.bas's own control handlers as group "mainmenu";
7902 REM OFFEVENT-able as a unit (see line 2310) and safe to re-run
7904 REM (GOSUB target reused by the game_exit resume routine at 2630).
7910 ONEVENT ONCONTROL("JOYPAD_LEFT", "pressed") GOTO 2010 NAME "mainmenu"
7920 ONEVENT ONCONTROL("JOYPAD_RIGHT", "pressed") GOTO 2110 NAME "mainmenu"
7930 ONEVENT ONCONTROL("JOYPAD_B", "pressed") GOTO 2210 NAME "mainmenu"
7940 ONEVENT ONCONTROL("JOYPAD_Y", "pressed") GOTO 2510 NAME "mainmenu"
7950 RETURN

