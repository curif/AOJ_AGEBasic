# A configuration cabinet suite

This is a SPEC for a configuration cabinet set of programs that helps the user to create it's hown cabinets in AGE of Joy arcade experience.

This programs can run in a specific configuration cabinet. The player/user have the configured cabinet on sight, and they can see how changes affects that cabinet. That cabinet is the cabinet object of the configuration.

# Requirements
To proceed with the plan read @/mnt/d/AgeOfJoyQuartzDoc\content\Documents\Cabinets\CDL the Cabinet Description Language.md and the game configuration .net structure: @/mnt/c/Users\curif\desarr\ageofjoy.0.5.1\AgeOfJoy-2022.1\Assets\curif\LibRetroWrapper\CabinetInformation.cs

# Main screen (main.bas)

0123456789012345678901234567890123456789
WORKSHOP CABINET CONFIGURATION ---------| <- Title (line 0)
[GAME][CRT][MODEL][VIDEO][PARTS][FILES] | <- Menu area, change color on user selection
----------------------------------------| <- Separator
GAME:                                   | <- Main screen help area,
Use this option to configure cores,     |    The subprograms will use this area for their operation
ROMs, name, year, etc.                  |    living free the upper part.
                                        |
...
Press <-> to move between options       | <- Last line is the control helper button area.
0123456789012345678901234567890123456789

# navigation

Joystick to up/down/left/right.
B button: option select
From a subprogram going up (to the Main Screen menu area) will exit the subprogram.

# Subprograms

Main menu doesn't change anything, a subprogram does. When the use select an option (like GAME or CRT) a subprogram will handle that option. The subprogram uses the line 3 and below, going back to Main Menu line stops the program.

Example: 
GAME is selected and the user press A on it, the game.bas subprogram is called.

ROMs : < galaga >
YEAR : < 1980 >
CORE : < mame2003+ >
TIME TO LOAD: < 1 > (secs)
SPACE: < 1x1x2 >

EXIT: < restore >

# Screen structure

option A: < SELECTOR >

Example:

ROM: < GALAGA >

The `option A:` option must be inverted to visually indicate the option is active. Normal for non active.
The player moves from an option to the other using the up and down.

# Operation

Values with limited options, like years or file existing in disk must show a `< selector >`. left/right to change value. 

EXIT option: each subprogram must have it's own EXIT option: 
* `SAVE`: will save the configuration with the screen options and reload the workshop.
* `EXIT Without save`: loose configuration.
Pressing `A` will exit the subprogram.

# External docs

- user manual: `/mnt/d/AgeOfJoyQuartzDoc\content\Documents\Cabinets\CDL the Cabinet Description Language.md `
- the cabinet configuration in .net: `/mnt/c/Users\curif\desarr\ageofjoy.0.5.1\AgeOfJoy-2022.1\Assets\curif\LibRetroWrapper\CabinetInformation.cs`
- the AGEBasic user manual: /mnt/d/AgeOfJoyQuartzDoc/content/Documents/AGEBasic/AGEBasic programing.md

# Next step

Request the user what is the next configuration or action before proceed.
