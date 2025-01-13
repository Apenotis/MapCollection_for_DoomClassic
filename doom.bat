::[Bat To Exe Converter]
::
::YAwzoRdxOk+EWAnk
::fBw5plQjdG8=
::YAwzuBVtJxjWCl3EqQJgSA==
::ZR4luwNxJguZRRnk
::Yhs/ulQjdF+5
::cxAkpRVqdFKZSjk=
::cBs/ulQjdF+5
::ZR41oxFsdFKZSDk=
::eBoioBt6dFKZSDk=
::cRo6pxp7LAbNWATEpCI=
::egkzugNsPRvcWATEpCI=
::dAsiuh18IRvcCxnZtBJQ
::cRYluBh/LU+EWAnk
::YxY4rhs+aU+JeA==
::cxY6rQJ7JhzQF1fEqQJQ
::ZQ05rAF9IBncCkqN+0xwdVs0
::ZQ05rAF9IAHYFVzEqQJQ
::eg0/rx1wNQPfEVWB+kM9LVsJDGQ=
::fBEirQZwNQPfEVWB+kM9LVsJDGQ=
::cRolqwZ3JBvQF1fEqQJQ
::dhA7uBVwLU+EWDk=
::YQ03rBFzNR3SWATElA==
::dhAmsQZ3MwfNWATElA==
::ZQ0/vhVqMQ3MEVWAtB9wSA==
::Zg8zqx1/OA3MEVWAtB9wSA==
::dhA7pRFwIByZRRnk
::Zh4grVQjdCqDJH2L+08MDBRbQUqHJG7a
::YB416Ek+ZG8=
::
::
::978f952a14a936cc963da21a135fa983
@echo off

chcp 65001 >nul

setlocal enabledelayedexpansion

SET "gz=Engine\GzDoom\gzdoom.exe"
SET "PBD=Maps\Mod\PB-0_1_0-alpha.pk3"
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

for /f "skip=1 tokens=1-12 delims=," %%a in (maps.csv) do (
    set "map[%%a]=%%b,%%c,%%d,%%e,%%f,%%g,%%h,%%i,%%j,%%k,%%l"
)

IF "%M%"=="0" exit /B
IF "%M%"=="r" GOTO menu
if "%M%"=="" goto menu
if not defined map[%M%] goto menu

for /f "tokens=1-12 delims=," %%a in ("!map[%M%]!") do (
    set "core=%%a"
    
    if "%%a"=="maps\iwad\doom.wad" (
        set "displayCore=Doom I"
    ) else if "%%a"=="maps\iwad\doom2.wad" (
        set "displayCore=Doom II"
    ) else if "%%a"=="maps\iwad\Plutonia.wad" (
        set "displayCore=Final Doom Plutonia"
    ) else if "%%a"=="maps\iwad\tnt.wad" (
        set "displayCore=Final Doom TnT-Evilution"
    ) else if "%%a"=="maps\iwad\hexen.wad" (
        set "displayCore=Hexen - Beyond Heretic"
    ) else if "%%a"=="maps\iwad\heretic.wad" (
        set "displayCore=Heretic - Shadow of the Serpent Riders"
    )
     
    set "mapname=%%b"

    if not "%%c"=="" set "map1=%pwadPath%%%c"
    if not "%%d"=="" set "map2=%pwadPath%%%d"
    if not "%%e"=="" set "map3=%pwadPath%%%e"
    if not "%%f"=="" set "map4=%pwadPath%%%f"
    if not "%%g"=="" set "map5=%pwadPath%%%g"
    if not "%%h"=="" set "map6=%pwadPath%%%h"
    if not "%%i"=="" set "map7=%pwadPath%%%i"
    if not "%%j"=="" set "map8=%pwadPath%%%j"
    if not "%%k"=="" set "map9=%pwadPath%%%k"
    if not "%%l"=="" set "map9=%pwadPath%%%l"
)

set "firstPWAD=true"

for %%i in ("%map1%" "%map2%" "%map3%" "%map4%" "%map5%" "%map6%" "%map7%" "%map8%" "%map9%") do (
    if not "%%~i"=="" (
        if defined firstPWAD (
            set "fileParams=%%~i"
            set "firstPWAD="
        ) else (
            set "fileParams=!fileParams! %%~i"
        )
        set "displayFileParams=!displayFileParams! %%~nxi"
    )
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

echo Map:  %mapname%
echo Iwad: %displayCore%
echo Pwad:%displayFileParams%
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
