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

for /f "usebackq skip=1 tokens=1,* delims=," %%a in ("maps.csv") do (
    set "map[%%a]=%%b"
)

IF "%M%"=="0" exit /B
IF "%M%"=="r" GOTO menu
if "%M%"=="" goto menu
if not defined map[%M%] (
    echo Debug: Karte %M% nicht gefunden. Überprüfe die CSV und Eingabe.
    pause
    goto menu
)

set "mapData=!map[%M%]!"
set /a index=1

for /f "tokens=1,* delims=," %%x in ("!mapData!") do (
    set "column[1]=%%x"
    set "remainingData=%%y"
)

for /f "tokens=1* delims=," %%x in ("!remainingData!") do (
    set "mapname=%%x"
    set "pwadData=%%y"
)

set "fileParams="
set "displayFileParams="

for %%p in (!pwadData!) do (
    if not "%%~p"=="" (
        set "fileParams=!fileParams! %%~p"
        set "displayFileParams=!displayFileParams! %%~nxp"
    )
)

set "core=!column[1]!"
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

COLOR A
CLS
echo Wähle einen Mod:

if "%displayCore%"=="Doom I" (
    echo 1 - Project Brutality
    echo 2 - Dark
    echo 5 - Kein Mod
    set "validChoices=1 2 5"
) else if "%displayCore%"=="Doom II" (
    echo 1 - Project Brutality
    echo 2 - Dark
    echo 5 - Kein Mod
    set "validChoices=1 2 5"
) else if "%displayCore%"=="Final Doom Plutonia" (
    echo 1 - Project Brutality
    echo 2 - Dark
    echo 5 - Kein Mod
    set "validChoices=1 2 5"
) else if "%displayCore%"=="Final Doom TnT-Evilution" (
    echo 1 - Project Brutality
    echo 2 - Dark
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

rem Debug-Ausgabe
echo Debug: Map = %mapname%
echo Debug: IWAD = %displayCore%
echo Debug: PWAD = %displayFileParams%

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

set "mapname="
set "core="
set "fileParams="
set "displayFileParams="
set "displayCore="
set "pwadData="

pause
goto menu
