@echo off

chcp 65001 >nul

setlocal enabledelayedexpansion

SET "gz=Engine\GzDoom\gzdoom.exe"
SET "PBD=Maps\Mod\PB-0_2_1-alpha.pk3"
SET "DARK=Maps\Mod\Dark\BDBE_v3.38.pk3 Maps\Mod\Dark\CatsVisorBASE1.10.3.pk3 Maps\Mod\Dark\CatsVisorC1.10.3.pk3"
SET "Hexen=Maps\Mod\hexen\BrutalHexenRPG_V7.5.pk3"
SET "Heretic=Maps\Mod\BrutalHereticRPG_V6.1.pk3"

:menu
COLOR C
cls

Type Maps.txt

echo.

set /P "M=Wähle eine Karte: "
cls

for /f "skip=1 tokens=1* delims=," %%a in (maps.csv) do (
    set "mapKey=%%a"
    set "mapData=%%b"
    set "map[%%a]=%%b"
)

IF "%M%"=="0" exit /B
IF "%M%"=="r" GOTO menu
if "%M%"=="" goto menu
if not defined map[%M%] goto menu

set "mapData=!map[%M%]!"
set "index=1"
for %%x in (!mapData!) do (
    set "column[!index!]=%%x"
    set /a index+=1
)

set "core=!column[1]!"
set "mapname=!column[2]!"

if "!core!"=="maps\iwad\doom.wad" (
    set "displayCore=Doom I"
) else if "!core!"=="maps\iwad\doom2.wad" (
    set "displayCore=Doom II"
) else if "!core!"=="maps\iwad\Plutonia.wad" (
    set "displayCore=Final Doom Plutonia"
) else if "!core!"=="maps\iwad\tnt.wad" (
    set "displayCore=Final Doom TnT-Evilution"
) else if "!core!"=="maps\iwad\hexen.wad" (
    set "displayCore=Hexen - Beyond Heretic"
) else if "!core!"=="maps\iwad\heretic.wad" (
    set "displayCore=Heretic - Shadow of the Serpent Riders"
)

set "firstPWAD=true"
set "fileParams="
set "displayFileParams="

for /L %%i in (3,1,%index%) do (
    if defined column[%%i] (
        if defined firstPWAD (
            set "fileParams=!column[%%i]!"
            for %%j in (!column[%%i]!) do set "displayFileParams=%%~nxj"
            set "firstPWAD="
        ) else (
            set "fileParams=!fileParams! !column[%%i]!"
            for %%j in (!column[%%i]!) do set "displayFileParams=!displayFileParams! %%~nxj"
        )
    )
)

COLOR A
CLS
echo Wähle einen Mod:

if "%displayCore%"=="Doom I" (
    echo 1 - Project Brutality Doom
    echo 2 - Brutal Doom: Black Edition
    echo 5 - Kein Mod
    set "validChoices=1 2 5"
) else if "%displayCore%"=="Doom II" (
    echo 1 - Project Brutality Doom
    echo 2 - Brutal Doom: Black Edition
    echo 5 - Kein Mod
    set "validChoices=1 2 5"
) else if "%displayCore%"=="Final Doom Plutonia" (
    echo 1 - Project Brutality Doom
    echo 2 - Brutal Doom: Black Edition
    echo 5 - Kein Mod
    set "validChoices=1 2 5"
) else if "%displayCore%"=="Final Doom TnT-Evilution" (
    echo 1 - Project Brutality Doom
    echo 2 - Brutal Doom: Black Edition
    echo 5 - Kein Mod
    set "validChoices=1 2 5"
) else if "%displayCore%"=="Hexen - Beyond Heretic" (
    echo 3 - Brutal Hexen
    echo 5 - Kein Mod
    set "validChoices=3 5"
) else if "%displayCore%"=="Heretic - Shadow of the Serpent Riders" (
    echo 4 - Brutal Heretic
    echo 5 - Kein Mod
    set "validChoices=4 5"
)

set /P "modChoice=Wähle Mod:"

CLS
timeout /t 1 >nul

echo Map:  %mapname%
echo Iwad: %displayCore%
echo Pwad: %displayFileParams%
rem echo Pfadvalidierung: "%gz%" +logfile "logfile.txt" -iwad "%core%" -file !fileParams!

if "%modChoice%"=="1" (
    echo Mod:  Project Brutality
    "%gz%" +logfile "logfile.txt" -iwad "%core%" -file %PBD% !fileParams!
) else if "%modChoice%"=="2" (
    echo Mod:  Dark Doom
    "%gz%" +logfile "logfile.txt" -iwad "%core%" -file %DARK% !fileParams!
) else if "%modChoice%"=="3" (
    echo Mod:  Brutal Hexen
    "%gz%" +logfile "logfile.txt" -iwad "%core%" -file %HEXEN% !fileParams!
) else if "%modChoice%"=="4" (
    echo Mod:  Brutal Heretic
    "%gz%" +logfile "logfile.txt" -iwad "%core%" -file %HERETIC% !fileParams!
) else if "%modChoice%"=="5" (
    echo Mod:  Kein Mod ausgewählt
    "%gz%" +logfile "logfile.txt" -iwad "%core%" -file !fileParams!
)
   
for /L %%i in (1,1,9) do (
    set "map%%i="
)

set "fileParams="
set "displayFileParams="
set "parameters="
set "core="
set "mapname="
set "displayCore="

pause
goto menu