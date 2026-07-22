
5 REM rotate.bas -- shared right-joystick X-axis rotation for the workshop cabinet.
6 REM Call once with: RUN "rotate.bas" (intended caller: workshop/main.bas at startup).
7 REM Registers ONCONTROL handlers under NAME "rotate", which persist across every
8 REM workshop child screen since none of them OFFEVENT this group.
9 REM Config (set by the caller before RUN; all have defaults):
10 REM   ROTATEPOSITION  room position of the cabinet to rotate (default 0)
11 REM   ROTATESTEP      degrees applied per right-stick tilt (default 5)
20 DECLARE ROTATEPOSITION = 0
30 DECLARE ROTATESTEP = 5

100 REM right controller stick is port 1
110 ONEVENT ONCONTROL("JOYPAD_LEFT", "pressed", 1) GOTO 1010 NAME "rotate"
120 ONEVENT ONCONTROL("JOYPAD_RIGHT", "pressed", 1) GOTO 1020 NAME "rotate"
130 END

1010 CALL CABROOMROTATE(ROTATEPOSITION, "X", -ROTATESTEP)
1015 END

1020 CALL CABROOMROTATE(ROTATEPOSITION, "X", ROTATESTEP)
1025 END
