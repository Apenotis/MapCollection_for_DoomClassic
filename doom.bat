@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

reg add "HKCU\Console" /v VirtualTerminalLevel /t REG_DWORD /d 1 /f >nul 2>&1

set "IWAD_DIR=%~dp0iwad"
set "PWAD_DIR=%~dp0pwad"
SET "UZ=UzDoom\uzdoom.exe"
SET "PB=Mods\BrutalProject\*.pk3"
SET "Black=Mods\BrutalBlack\*.pk3"
SET "Hexen=Mods\BrutalHexen\*.pk3"
SET "Heretic=Mods\BrutalHeretic\*.pk3"
SET "Wolf3D=Mods\BrutalWolfenstein\*.pk3"
SET "Voxel=Mods\cheello_voxels.zip"

:map_selection
REM Fensterbreite auf 235 Zeichen optimiert
mode con: cols=235 lines=50

for /F "tokens=1,2 delims=#" %%a in ('"prompt #$H#$E# & echo on & for %%b in (1) do rem"') do set "ESC=%%b"
set "C_Cyan=!ESC![36m"
set "C_Green=!ESC![32m"
set "C_Yellow=!ESC![33m"
set "C_Gray=!ESC![90m"
set "C_Red=!ESC![31m"
set "C_Reset=!ESC![0m"

CLS
echo.
echo  %C_Cyan%============================================================================================================================================================================================================================
echo      I W A D S (1-10)                   ^|   P W A D S (11-40)                                                         ^|   P W A D S (41-70)                                               ^|   H E R E T I C / H E X E N
echo  ============================================================================================================================================================================================================================%C_Reset%
echo.

REM Arrays leeren
for /L %%i in (1,1,120) do (set "col1[%%i]=" & set "col2[%%i]=" & set "col3[%%i]=" & set "col4[%%i]=")
set "currentCol=0"
set "idx1=0" & set "idx2=0" & set "idx3=0" & set "idx4=0"

REM Datei Maps.txt einlesen
if not exist "Maps.txt" (
    echo %C_Red%Datei Maps.txt nicht gefunden!%C_Reset%
    pause
    goto :eof
)

for /f "usebackq tokens=*" %%l in ("Maps.txt") do (
    set "line=%%l"
    set "isHeader=0"
    set "cleanLine=!line: =!"
    if /i "!cleanLine!"=="IWad" (set "currentCol=1" & set "isHeader=1")
    if /i "!cleanLine!"=="PWad" (set "currentCol=2" & set "isHeader=1")
    if /i "!cleanLine!"=="Heretic" (set "currentCol=4" & set "isHeader=1")
    if /i "!cleanLine!"=="Hexen" (set "currentCol=4" & set "isHeader=1")
    if /i "!cleanLine!"=="Wolfenstein3D" (set "currentCol=4" & set "isHeader=1")

    if "!isHeader!"=="0" if not "!line!"=="" (
        if "!currentCol!"=="1" (set /a idx1+=1 & set "col1[!idx1!]=!line!")
        if "!currentCol!"=="2" (
            for /f "tokens=1" %%n in ("!line!") do set "firstToken=%%n"
            set "isHigh=0"
            if !firstToken! GEQ 41 set "isHigh=1"
            if "!isHigh!"=="1" (set /a idx3+=1 & set "col3[!idx3!]=!line!") else (set /a idx2+=1 & set "col2[!idx2!]=!line!")
        )
        if "!currentCol!"=="4" (set /a idx4+=1 & set "col4[!idx4!]=!line!")
    )
)

set "maxIdx=!idx2!"
if !idx1! GTR !maxIdx! set "maxIdx=!idx1!"
if !idx3! GTR !maxIdx! set "maxIdx=!idx3!"
if !idx4! GTR !maxIdx! set "maxIdx=!idx4!"

for /L %%i in (1,1,!maxIdx!) do (
    set "c1=!col1[%%i]!                                              "
    set "c2=!col2[%%i]!                                                                                "
    set "c3=!col3[%%i]!                                                                                "
    set "c4=!col4[%%i]!"
    echo   %C_Green%!c1:~0,38! %C_Gray%^|%C_Green% !c2:~0,67! %C_Gray%^|%C_Green% !c3:~0,67! %C_Gray%^|%C_Green% !c4!%C_Reset%
)

echo.
echo  %C_Cyan%============================================================================================================================================================================================================================%C_Reset%
echo   %C_Yellow%[0] Beenden    [R] Reset/Neu laden%C_Reset%
echo.
set /p "M=%C_Yellow%  Gib die ID ein: %C_Reset%"

if /i "%M%"=="0" exit
if /i "%M%"=="r" goto map_selection

REM --- Ab hier folgt die CSV-Verarbeitung ---
set "found=0"
for /f "usebackq skip=1 tokens=1,* delims=," %%a in ("maps.csv") do (
    if /i "%%a"=="%M%" (
        set "mapData=%%b"
        set "found=1"
    )
)

if "!found!"=="0" (
    echo %C_Red%Ungueltige ID!%C_Reset%
    timeout /t 2 >nul
    goto map_selection
)

for /f "tokens=1,2,* delims=," %%x in ("!mapData!") do (
    set "core=%%x"
    set "mapname=%%y"
    set "remaining=%%z"
)

set "iwadPath=!IWAD_DIR!\!core!"
set "fileParams="
set "displayFileParams="
set "extraParams="
set "modFlag=0"
set "nextIsValue=0"

for %%p in (!remaining!) do (
    set "item=%%~p"
    set "firstChar=!item:~0,1!"
    if "!nextIsValue!"=="1" (
        set "extraParams=!extraParams! !item!"
        set "nextIsValue=0"
    ) else if "!item!"=="1" (
        set "modFlag=1"
    ) else if "!item!"=="0" (
        set "modFlag=0"
    ) else if "!firstChar!"=="-" (
        set "extraParams=!extraParams! !item!"
        if /i "!item!"=="-warp" set "nextIsValue=1"
        if /i "!item!"=="-skill" set "nextIsValue=1"
        if /i "!item!"=="-config" set "nextIsValue=1"
    ) else if "!firstChar!"=="+" (
        set "extraParams=!extraParams! !item!"
    ) else (
        set "targetPath="
        if exist "%PWAD_DIR%\!item!" (
            set "targetPath=%PWAD_DIR%\!item!"
        ) else if exist "%IWAD_DIR%\!item!" (
            set "targetPath=%IWAD_DIR%\!item!"
        )

        if defined targetPath (
            if exist "!targetPath!\" (
                for %%f in ("!targetPath!\*.wad" "!targetPath!\*.pk3" "!targetPath!\*.deh" "!targetPath!\*.pk7" "!targetPath!\*.SF2" "!targetPath!\*.lev" "!targetPath!\*.res" "!targetPath!\*.def" "!targetPath!\*.bex" "!targetPath!\*.ipk3") do (
                    set "fileParams=!fileParams! "%%~f""
                    set "displayFileParams=!displayFileParams! %%~nxf"
                )
            ) else (
                set "fileParams=!fileParams! "!targetPath!""
                for %%i in ("!targetPath!") do set "displayFileParams=!displayFileParams! %%~nxi"
            )
        )
    )
)

if /i "!core!"=="doom.wad" ( set "displayCore=Doom I"
) else if /i "!core!"=="doom2.wad" ( set "displayCore=Doom II"
) else if /i "!core!"=="Plutonia.wad" ( set "displayCore=Final Doom Plutonia"
) else if /i "!core!"=="tnt.wad" ( set "displayCore=Final Doom TnT-Evilution"
) else if /i "!core!"=="hexen.wad" ( set "displayCore=Hexen - Beyond Heretic"
) else if /i "!core!"=="heretic.wad" ( set "displayCore=Heretic - Shadow of the Serpent Riders"
) else ( set "displayCore=!core!" )

if "!modFlag!"=="1" (
    set "modChoice=5"
    goto summary_section
)

:mod_menu
mode con: cols=100 lines=30
COLOR A & CLS
echo.
echo  ======================================================
echo          SPIEL :  %displayCore%
echo          KARTE :  %mapname%
echo  ======================================================
echo.
echo                    WAEHLE DEINEN MOD
echo  ------------------------------------------------------

set "validChoices="

if /i "!core!"=="doom.wad" (
    echo     [1] Project Brutality      [5] Keine Mod
    echo     [2] Dark Mod               [6] Voxel Mod
    echo     [7] Multiplayer
    set "validChoices=1 2 5 6 7"
) else if /i "!core!"=="doom2.wad" (
    echo     [1] Project Brutality      [5] Keine Mod
    echo     [2] Dark Mod               [6] Voxel Mod
    echo     [7] Multiplayer            [8] Brutal Wolfenstein
    set "validChoices=1 2 5 6 7 8"
) else if /i "!core!"=="Plutonia.wad" (
    echo     [1] Project Brutality      [5] Keine Mod
    echo     [2] Dark Mod               [6] Voxel Mod
    set "validChoices=1 2 5 6"
) else if /i "!core!"=="tnt.wad" (
    echo     [1] Project Brutality      [5] Keine Mod
    echo     [2] Dark Mod               [6] Voxel Mod
    set "validChoices=1 2 5 6"
) else if /i "!core!"=="hexen.wad" (
    echo     [3] Brutal Hexen           [5] Keine Mod
    set "validChoices=3 5"
) else if /i "!core!"=="heretic.wad" (
    echo     [4] Brutal Heretic         [5] Keine Mod
    set "validChoices=4 5"
) else (
    echo     [5] Keine Mod
    set "validChoices=5"
)

echo.
set /P "modChoice=  DEINE WAHL: "

REM Überprüfung der Eingabe
set "checkChoice=0"
for %%c in (%validChoices%) do (
    if "%modChoice%"=="%%c" set "checkChoice=1"
)

if "%checkChoice%"=="0" (
    echo.
    echo  Ungueltige Auswahl! Bitte erneut waehlen.
    timeout /t 2 >nul
    goto mod_menu
)

:summary_section
CLS & COLOR 0B
echo  ======================================================
echo          U Z D O O M   S T A R T - B E R E I T
echo  ======================================================
echo    KARTE :  !mapname!
echo    IWAD  :  !displayCore!
echo    FILES : !displayFileParams!
echo.
if "%modChoice%"=="1" set "currentModName=Project Brutality"
if "%modChoice%"=="2" set "currentModName=Dark Mod"
if "%modChoice%"=="3" set "currentModName=Brutal Hexen"
if "%modChoice%"=="4" set "currentModName=Brutal Heretic"
if "%modChoice%"=="5" set "currentModName=Vanilla / Map-Mod"
if "%modChoice%"=="6" set "currentModName=Voxel Mod"
if "%modChoice%"=="7" set "currentModName=Multiplayer Host"
if "%modChoice%"=="8" set "currentModName=Brutal Wolfenstein"

echo    MOD   :  !currentModName!
echo    PARAM : !extraParams!
echo  ======================================================
timeout /t 2 >nul

REM --- START ENGINE ---
if "%modChoice%"=="1" ( 
    "%UZ%" +logfile "logfile.txt" -iwad "!iwadPath!" -file %PB% !fileParams! !extraParams!
) else if "%modChoice%"=="2" ( 
    "%UZ%" +logfile "logfile.txt" -iwad "!iwadPath!" -file %Black% !fileParams! !extraParams!
) else if "%modChoice%"=="3" ( 
    "%UZ%" +logfile "logfile.txt" -iwad "!iwadPath!" -file %Hexen% !fileParams! !extraParams!
) else if "%modChoice%"=="4" ( 
    "%UZ%" +logfile "logfile.txt" -iwad "!iwadPath!" -file %Heretic% !fileParams! !extraParams!
) else if "%modChoice%"=="5" ( 
    "%UZ%" +logfile "logfile.txt" -iwad "!iwadPath!" -file !fileParams! !extraParams!
) else if "%modChoice%"=="6" ( 
    "%UZ%" +logfile "logfile.txt" -iwad "!iwadPath!" -file %Voxel% !fileParams! !extraParams!
) else if "%modChoice%"=="7" ( 
    "%UZ%" +logfile "logfile.txt" -iwad "!iwadPath!" -file !fileParams! -host 2 !extraParams!
) else if "%modChoice%"=="8" ( 
    "%UZ%" +logfile "logfile.txt" -iwad "!iwadPath!" -file %Wolf3D% !fileParams! !extraParams!
)

set "mapname=" & set "core=" & set "iwadPath=" & set "fileParams=" & set "displayFileParams=" & set "displayCore=" & set "modFlag=" & set "validChoices="

pause
goto map_selection