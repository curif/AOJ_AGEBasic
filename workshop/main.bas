
20 LET MENUNAMES = ARRAY("CAB", "GAME", "CRT", "MODEL", "VIDEO", "PARTS", "FILES")
30 LET HELPTEXT = ARRAY("Select the cabinet to configure. Press B to pick a different cab.", "Configure cores, ROMs, name, year, etc.", "Configure the CRT screen: type, orientation, shader and geometry.", "Configure the cabinet model, style and coin slot.", "Configure the attraction video and audio.", "Configure the cabinet parts: art, color, material, etc for each one.", "Configure the files distributed with the cabinet.")
120 LETS width, height = SCREENWIDTH(), SCREENHEIGHT()
130 LET lineEmpty = (width - 1) * " "
140 LET MENUSEL = 0
145 LET MENUOFFSET = 0
147 LET CABNAME = "test"

190 REM start the shared right-joystick cabinet-rotation handler (stays live across all workshop screens)
195 RUN "rotate.bas"

200 REM initial draw and event registration
210 CLS
220 GOSUB 7010
230 GOSUB 7110
240 GOSUB 7210
250 GOSUB 7910
260 ONEVENT ONCUSTOM("main_resume") GOTO 2610
265 ONEVENT ONCUSTOM("main_cab_resume") GOTO 2660
270 END

2000 REM JOYPAD_LEFT: move menu selection left, scrolling the window if needed
2010 LET MENUSEL = MENUSEL - IIF(MENUSEL > 0, 1, 0)
2015 IF MENUSEL < MENUOFFSET THEN LET MENUOFFSET = MENUSEL
2020 GOSUB 7110 : GOSUB 7210
2030 END

2100 REM JOYPAD_RIGHT: move menu selection right, scrolling the window if needed
2110 LET MENUSEL = MENUSEL + IIF(MENUSEL < LEN(MENUNAMES) - 1, 1, 0)
2115 GOSUB 7110
2120 IF MENUSEL > LASTVIS THEN LET MENUOFFSET = MENUOFFSET + 1 : GOTO 2115
2125 GOSUB 7210
2130 END

2200 REM JOYPAD_B: select the current menu option
2210 IF MENUSEL = 0 THEN GOSUB 2460 ELSE IF MENUSEL = 1 THEN GOSUB 2310 ELSE IF MENUSEL = 2 THEN GOSUB 2340 ELSE GOSUB 2410
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

2450 REM launch the cabinet picker: pickfile.bas filtered to folders under
2451 REM CABINETSDBPATH(); resumes via "main_cab_resume" (see line 2660), same
2452 REM hand-off mechanism as GAME/CRT above.
2460 LET PICKFILEPATH = CABINETSDBPATH()
2465 LET PICKFILEDIRSONLY = 1
2470 LET PICKFILEWILDCARD = "*"
2475 LET PICKFILETITLE = "SELECT CABINET"
2480 LET PICKFILERESUMEEVENT = "main_cab_resume"
2485 OFFEVENT "mainmenu"
2490 RUN "pickfile.bas"
2495 RETURN

2500 REM JOYPAD_Y: leave the configuration tool
2505 OFFEVENT "rotate"
2510 SHUTDOWN

2600 REM main_resume handoff (GOTO target of ONCUSTOM "main_resume"): the
2602 REM callee has already turned off its own handlers by this point.
2610 CLS
2620 GOSUB 7010 : GOSUB 7110 : GOSUB 7210
2630 GOSUB 7910
2640 END

2650 REM main_cab_resume handoff: pickfile.bas has already turned off its own
2651 REM handlers ("pickfile"/"pickfile_kb") by this point. PICKFILERESULT is
2652 REM the chosen cab folder name, or "" if the user cancelled (Y). Only
2653 REM rows 3.. need redrawing -- pickfile.bas never touches rows 0-2.
2660 IF PICKFILERESULT != "" THEN LET CABNAME = PICKFILERESULT : CALL WORKSHOPRELOAD(CABNAME)
2670 GOSUB 7210
2680 GOSUB 7910
2690 END

7000 REM draw title row
7010 PRINT 0, 0, SUBSTR("WORKSHOP CABINET CONFIGURATION ---------", 0, width - 1), 0, 0
7020 SHOW
7030 RETURN

7100 REM draw menu row from MENUOFFSET, inverting the selected item; sets LASTVIS
7101 REM to the last item index that fit, so callers can detect scroll-off (see 2120)
7110 PRINT 0, 1, lineEmpty, 0, 0
7120 LET col = 0 : LET LASTVIS = MENUOFFSET - 1
7130 FOR idx = MENUOFFSET TO LEN(MENUNAMES) - 1
7140   LET label = MENUNAMES[idx] + " "
7150   IF col + LEN(label) > width - 1 THEN GOTO 7185
7160   PRINT col, 1, label, IIF(idx = MENUSEL, 1, 0), 0
7165   LET col = col + LEN(label) : LET LASTVIS = idx
7170 NEXT idx
7185 SHOW
7190 RETURN

7200 REM draw separator, help body and control footer
7210 PRINT 0, 2, (width - 1) * "-", 0, 0
7220 FOR ln = 3 TO height - 2
7230   PRINT 0, ln, lineEmpty, 0, 0
7240 NEXT ln
7245 LET WRAPSTARTROW = 3
7248 IF MENUSEL = 0 THEN PRINT 0, 3, SUBSTR("Selected cab: " + CABNAME, 0, width - 1), 0, 0 : LET WRAPSTARTROW = 4
7250 LET WRAPTEXT = HELPTEXT[MENUSEL] : GOSUB 7410
7260 FGCOLOR "WHITE" : BGCOLOR "BLUE"
7270 PRINT 0, height - 1, lineEmpty, 0, 0
7275 LET FOOTERTEXT = IIF(MENUSEL = 0, "Press <-> to select, B: pick cab, Y: EXIT", "Press <-> to select, Y: EXIT")
7280 PRINT 0, height - 1, SUBSTR(FOOTERTEXT, 0, width - 1), 0, 0
7290 RESETCOLOR
7300 SHOW
7310 RETURN

7400 REM word-wrap WRAPTEXT across the help area (rows WRAPSTARTROW..height-2), width chars per row
7410 LET wrow = WRAPSTARTROW
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

