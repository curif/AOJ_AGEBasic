
5 REM pickfile.bas -- reusable generic file picker overlay (paginated, wildcard filter).
6 REM Call with: RUN "pickfile.bas" (or COMBINEPATH(AGEBASICPATH(), "pickfile.bas")).
7 REM Config in (set by the caller before RUN; all have defaults):
8 REM   PICKFILEPATH         folder to list (default ROOTPATH())
9 REM   PICKFILEWILDCARD     MS-DOS style filename wildcard, e.g. "*.zip" (default "*" = all files)
10 REM   PICKFILETITLE        prompt text shown above the filter field (default "SELECT FILE")
11 REM   PICKFILERESUMEEVENT  name of the ONCUSTOM event the caller registered
12 REM                        during ITS OWN setup (not inside a nested handler
13 REM                        right before RUN-ing this script) -- fired via
14 REM                        EVENTTRIGGER once a file is chosen (B in list mode)
15 REM                        or cancelled (Y) (default "pickfile_done")
16 REM Result: PICKFILERESULT holds the chosen filename, or "" if cancelled.
17 REM Layout: this callee does NOT CLS -- it only uses rows 3.. and the footer row
18 REM (height-1), the same zone-ownership rule game.bas's own content follows (see
19 REM CLAUDE.md "Screen zone ownership"). It blanks that zone itself on entry with
20 REM a solid DBOX (like keyboard.bas's gray panel) so leftover caller content
21 REM can't show through gaps its own PRINTs don't cover. Caller must still blank
22 REM its own zone before redrawing once PICKFILERESUMEEVENT fires (see game.bas's
23 REM keyboard-resume block for the reference pattern).
24 REM Paging: files are fetched one screen page at a time via GETFILESARRAY's native
25 REM wildcard/pageOffset/pageCount args -- there is no full in-memory file list, so
26 REM this scales to large directories. Filtering is done by editing PF_WILDCARD via
27 REM the keyboard.bas overlay (press B while the filter field is focused, see line
28 REM 4000). DOWN/UP at the bottom/top edge of the visible page loads the adjacent
29 REM page, showing a "Loading..." line meanwhile (see line 9100) -- GETFILESARRAY
30 REM itself is synchronous, so this is a UX flash, not a real async wait.

40 DECLARE PICKFILEPATH = ROOTPATH()
50 DECLARE PICKFILEWILDCARD = "*"
60 DECLARE PICKFILETITLE = "SELECT FILE"
70 DECLARE PICKFILERESUMEEVENT = "pickfile_done"

80 LET PF_WILDCARD = PICKFILEWILDCARD
90 LET PF_PAGEOFFSET = 0
100 LET PF_CURSORIDX = 0
110 LET PF_FOCUS = 1
120 LET PF_CURSOR = 1
130 LET PICKFILERESULT = ""
140 LETS width, height = SCREENWIDTH(), SCREENHEIGHT()
145 LETS dwidth, dheight = DSCREENWIDTH(), DSCREENHEIGHT()
146 LETS charw, charh = dwidth / width, dheight / height
150 LET lineEmpty = (width - 1) * " "
160 LET PF_LISTTOP = 6
170 LET PF_PAGESIZE = height - 1 - PF_LISTTOP
180 LET PF_LISTCOUNT = 0
190 LET PF_HASNEXT = 0
200 LET PF_HASPREV = 0
210 DIM PF_BLACK[3]
220 LETS PF_BLACK[0], PF_BLACK[1], PF_BLACK[2] = 0, 0, 0
230 DIM PF_LIST[1]

300 REM initial draw and event registration; no CLS -- this callee only owns
301 REM rows 3..height-2 plus the footer row, same zone as game.bas's own content.
302 REM blank that whole zone with a solid DBOX first (like keyboard.bas's gray
303 REM panel) so no stray characters from the caller's previous screen linger
304 REM in gaps this script's own PRINTs never touch.
305 DBOX ARRAY(0, 3 * charh), ARRAY(width * charw, (height - 3) * charh), PF_BLACK, 1, PF_BLACK
310 GOSUB 9910
320 GOSUB 9105
330 GOSUB 8110
340 GOSUB 8510
350 GOSUB 9810
360 END

3000 REM JOYPAD_DOWN: from the field, drop into the list; in the list, move down
3001 REM one row, or turn to the next page when at the last visible row
3010 IF PF_FOCUS = 1 && PF_LISTCOUNT > 0 THEN LET PF_FOCUS = 2 : LET PF_CURSORIDX = 0 : GOSUB 8110 : GOSUB 8510 : LET PF_CURSOR = 1 : GOSUB 8410
     ELSE IF PF_FOCUS = 2 && PF_CURSORIDX < PF_LISTCOUNT - 1 THEN GOSUB 8610
     ELSE IF PF_FOCUS = 2 && PF_HASNEXT THEN LET PF_PAGEOFFSET = PF_PAGEOFFSET + PF_PAGESIZE : GOSUB 9105 : LET PF_CURSORIDX = 0 : LET PF_CURSOR = 1 : GOSUB 8410
3020 END

3100 REM JOYPAD_UP: move up within the list, turn to the previous page when at
3101 REM the top visible row, or (with no previous page) go back to the field
3110 IF PF_FOCUS = 2 && PF_CURSORIDX > 0 THEN GOSUB 8710
     ELSE IF PF_FOCUS = 2 && PF_HASPREV THEN LET PF_PAGEOFFSET = PF_PAGEOFFSET - PF_PAGESIZE : GOSUB 9105 : LET PF_CURSORIDX = PF_LISTCOUNT - 1 : LET PF_CURSOR = 1 : GOSUB 8410
     ELSE IF PF_FOCUS = 2 THEN LET PF_CURSOR = 0 : GOSUB 8410 : LET PF_FOCUS = 1 : LET PF_CURSOR = 1 : GOSUB 8110 : GOSUB 8510
3120 END

3400 REM JOYPAD_B: open the wildcard filter keyboard (field mode) or confirm the
3401 REM highlighted file (list mode)
3410 IF PF_FOCUS = 1 THEN GOTO 4010
     ELSE IF PF_FOCUS = 2 && PF_LISTCOUNT > 0 THEN LET PICKFILERESULT = PF_LIST[PF_CURSORIDX] : GOTO 3910
3420 END

3500 REM JOYPAD_A: reset the filter to "*" (field mode) or go back to the field
3501 REM without changing the filter (list mode)
3510 IF PF_FOCUS = 1 THEN LET PF_WILDCARD = "*" : LET PF_PAGEOFFSET = 0 : GOSUB 9105 : GOSUB 8110
     ELSE IF PF_FOCUS = 2 THEN LET PF_CURSOR = 0 : GOSUB 8410 : LET PF_FOCUS = 1 : LET PF_CURSOR = 1 : GOSUB 8110 : GOSUB 8510
3520 END

3700 REM ONTIMER blink handler: blink the focused field or the highlighted list row
3710 LET PF_CURSOR = 1 - PF_CURSOR
3720 IF PF_FOCUS = 1 THEN GOSUB 8110
     ELSE GOSUB 8410
3730 END

3800 REM JOYPAD_Y: cancel, either mode
3810 LET PICKFILERESULT = ""
3820 GOTO 3910

3900 REM hand control back to the caller; END must stay off this line --
3901 REM chaining it with CALL EVENTTRIGGER corrupts the expression stack
3902 REM when unwinding back into the caller's resume handler (see game.bas/keyboard.bas).
3910 OFFEVENT "pickfile"
3915 OFFEVENT "pickfile_kb"
3920 CALL EVENTTRIGGER(PICKFILERESUMEEVENT)
3930 END

4000 REM open the wildcard filter keyboard overlay (field mode, B pressed); no
4001 REM END chained to RUN -- mirrors game.bas's ROM/AUTHOR keyboard call sites.
4010 LET KEYBOARDINPUT = PF_WILDCARD
4020 LET KEYBOARDTITLE = "FILTER (WILDCARD, e.g. *.zip)"
4030 LET KEYBOARDMAXLEN = 40
4040 LET KEYBOARDRESUMEEVENT = "pickfile_kb_resume"
4050 OFFEVENT "pickfile"
4060 RUN "keyboard.bas"
4070 END

4100 REM resume here once the keyboard overlay finishes; re-register pickfile's
4101 REM own control handlers (OFFEVENT "pickfile" ran before RUN switched
4102 REM context away), read the typed wildcard, and reload from page 0.
4110 GOSUB 9810
4120 LET PF_WILDCARD = IIF(KEYBOARDINPUT = "", "*", KEYBOARDINPUT)
4130 LET PF_PAGEOFFSET = 0
4140 LET PF_FOCUS = 1
4150 LET PF_CURSOR = 1
4160 FOR pfClearRow = 3 TO height - 2
4170   PRINT 0, pfClearRow, lineEmpty, 0, 0
4180 NEXT pfClearRow
4190 GOSUB 9105
4200 GOSUB 8110
4210 GOSUB 8510
4220 END

8000 REM draw title row (row 3), with the current page number or "no matches"
8010 PRINT 0, 3, lineEmpty, 0, 0
8020 LET PF_PAGENUM = INT(PF_PAGEOFFSET / PF_PAGESIZE) + 1
8030 IF PF_LISTCOUNT = 0 THEN LET PF_TITLE = PICKFILETITLE + " (no matches)"
     ELSE LET PF_TITLE = PICKFILETITLE + " (page " + STR(PF_PAGENUM) + ")"
8040 PRINT 0, 3, SUBSTR(PF_TITLE, 0, width - 1), 0, 0
8050 SHOW
8060 RETURN

8100 REM draw the filter field row (row 4); inverted while focused and blinked
8101 REM on (PF_FOCUS = 1 && PF_CURSOR = 1), GOSUB target
8110 PRINT 0, 4, lineEmpty, 0, 0
8120 PRINT 0, 4, SUBSTR("Filter: " + PF_WILDCARD, 0, width - 1), (PF_FOCUS = 1 && PF_CURSOR = 1), 0
8130 SHOW
8140 RETURN

8300 REM clear the list area (rows PF_LISTTOP..height-2)
8310 FOR pfscr = PF_LISTTOP TO height - 2
8320   PRINT 0, pfscr, lineEmpty, 0, 0
8330 NEXT pfscr
8340 RETURN

8350 REM draw the current page's files, GOSUB target
8360 GOSUB 8310
8370 FOR pfrow = 0 TO PF_LISTCOUNT - 1
8380   PRINT 0, PF_LISTTOP + pfrow, SUBSTR(PF_LIST[pfrow], 0, width - 1), 0, 0
8390 NEXT pfrow
8395 SHOW
8398 RETURN

8400 REM highlight/blink the currently selected list row (single-row redraw, GOSUB target)
8410 IF PF_LISTCOUNT = 0 THEN RETURN
8420 PRINT 0, PF_LISTTOP + PF_CURSORIDX, SUBSTR(PF_LIST[PF_CURSORIDX], 0, width - 1), PF_CURSOR, 0
8430 SHOW
8440 RETURN

8500 REM draw footer help line, context-sensitive on PF_FOCUS
8510 IF PF_FOCUS = 1 THEN LET PF_FOOT = "B:FILTER  A:CLEAR  vDOWN:LIST  Y:CANCEL"
     ELSE LET PF_FOOT = "^v MOVE/PAGE  B:SELECT  A:BACK  Y:CANCEL"
8520 FGCOLOR "WHITE" : BGCOLOR "BLUE"
8530 PRINT 0, height - 1, lineEmpty, 0, 0
8540 PRINT 0, height - 1, SUBSTR(PF_FOOT, 0, width - 1), 0, 0
8550 RESETCOLOR
8560 SHOW
8570 RETURN

8600 REM move the highlight to the next row within the current page (GOSUB target)
8610 LET PF_CURSOR = 0 : GOSUB 8410
8620 LET PF_CURSORIDX = PF_CURSORIDX + 1
8630 LET PF_CURSOR = 1 : GOSUB 8410
8640 RETURN

8700 REM move the highlight to the previous row within the current page (GOSUB target)
8710 LET PF_CURSOR = 0 : GOSUB 8410
8720 LET PF_CURSORIDX = PF_CURSORIDX - 1
8730 LET PF_CURSOR = 1 : GOSUB 8410
8740 RETURN

9100 REM load one page of files honoring PF_WILDCARD/PF_PAGEOFFSET; GETFILESARRAY
9101 REM is synchronous, but a "Loading..." line is drawn first and cleared by
9102 REM the page redraw right after, giving the requested page-turn feedback.
9103 REM Fetches PF_PAGESIZE + 1 items so PF_HASNEXT can be known without a
9104 REM separate count call. GOSUB target is 9105 (this REM block is not one).
9105 GOSUB 8310
9110 PRINT 0, PF_LISTTOP, SUBSTR("Loading...", 0, width - 1), 0, 0
9115 SHOW
9120 LET PF_RAW = GETFILESARRAY(PICKFILEPATH, 0, PF_WILDCARD, PF_PAGEOFFSET, PF_PAGESIZE + 1)
9125 LET PF_RAWCOUNT = LEN(PF_RAW)
9130 LET PF_HASNEXT = (PF_RAWCOUNT > PF_PAGESIZE)
9135 LET PF_LISTCOUNT = MIN(PF_RAWCOUNT, PF_PAGESIZE)
9140 LET PF_HASPREV = (PF_PAGEOFFSET > 0)
9145 DIM PF_LIST[MAX(PF_LISTCOUNT, 1)]
9150 FOR pfidx = 0 TO PF_LISTCOUNT - 1
9155   LET PF_LIST[pfidx] = PF_RAW[pfidx]
9160 NEXT pfidx
9165 GOSUB 8360
9170 GOSUB 8010
9175 RETURN

9800 REM register control event handlers as group "pickfile"; OFFEVENT'd as a
9801 REM unit before handing control back to the caller (3910) or before
9802 REM launching keyboard.bas (4050), and re-registered on return from
9803 REM either transition (see 4110). GOSUB target is 9810 (this REM is not one).
9810 ONEVENT ONCONTROL("JOYPAD_DOWN", "pressed") GOTO 3010 NAME "pickfile"
9820 ONEVENT ONCONTROL("JOYPAD_UP", "pressed") GOTO 3110 NAME "pickfile"
9830 ONEVENT ONCONTROL("JOYPAD_B", "pressed") GOTO 3410 NAME "pickfile"
9840 ONEVENT ONCONTROL("JOYPAD_A", "pressed") GOTO 3510 NAME "pickfile"
9850 ONEVENT ONCONTROL("JOYPAD_Y", "pressed") GOTO 3810 NAME "pickfile"
9860 ONEVENT ONTIMER(0.5) GOTO 3710 NAME "pickfile"
9870 RETURN

9900 REM register the keyboard-resume custom event as its own group
9901 REM ("pickfile_kb"), separate from the control handlers ("pickfile"), so
9902 REM tearing down "pickfile" before RUN "keyboard.bas" (4050) doesn't also
9903 REM remove this. Registered once here, during pickfile's own setup, not
9904 REM inside a nested handler right before a RUN (mirrors main.bas/game.bas).
9905 REM GOSUB target is 9910 (this REM block is not one).
9910 ONEVENT ONCUSTOM("pickfile_kb_resume") GOTO 4110 NAME "pickfile_kb"
9920 RETURN
