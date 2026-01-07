@echo off
setlocal enabledelayedexpansion
chcp 65001 >nul

REM --- ANSI FARB-FIX ---
for /f "tokens=*" %%a in ('powershell -command "[console]::Out.Write('')"') do (set "dummy=%%a")
reg add HKCU\Console /v VirtualTerminalLevel /t REG_DWORD /d 1 /f >nul 2>&1
for /f %%a in ('echo prompt $E ^| cmd') do set "ESC=%%a"

set "G=%ESC%[92m" & set "Y=%ESC%[93m" & set "B=%ESC%[94m" & set "R=%ESC%[91m" & set "W=%ESC%[0m"

set "INSTALL_DIR=Install"
set "PWAD_BASE=pwad"
set "CSV_FILE=maps.csv"
set "TXT_FILE=Maps.txt"

set /a count_total=0
set /a count_success=0

cls
echo %B%======================================================%W%
echo %B%       DOOM AUTOMATIC INSTALLER - FULL OVERVIEW%W%
echo %B%======================================================%W%
echo.

if not exist "%INSTALL_DIR%" mkdir "%INSTALL_DIR%"

REM --- 1. ZIP DATEIEN ENTPACKEN ---
for %%Z in ("%INSTALL_DIR%\*.zip") do (
    set /a count_total+=1
    echo %Y%[ ARCHIV ]%W% Gefunden: %%~nxZ
    
    set "zipName=%%~nZ"
    set "tempFolder=%INSTALL_DIR%\!zipName!"
    if not exist "!tempFolder!" mkdir "!tempFolder!"
    
    echo %B%  - Entpacke Daten...%W%
    tar -xf "%%Z" -C "!tempFolder!"
    if !errorlevel! equ 0 (
        echo %G%  - Erfolg! Archiv gelöscht.%W%
        del "%%Z"
    ) else (
        echo %R%  - FEHLER beim Entpacken.%W%
    )
    echo %B%------------------------------------------------------%W%
)

REM --- 2. UNTERORDNER VERARBEITEN ---
for /d %%D in ("%INSTALL_DIR%\*") do (
    set "foundTxt="
    for %%F in ("%%~fD\*.txt") do (
        set "foundTxt=1"
        call :process_package "%%~fD" "%%~fF"
    )
    if defined foundTxt ( 
        rd /s /q "%%~fD" 2>nul 
    )
)

REM --- 3. LOSE DATEIEN ---
for %%F in ("%INSTALL_DIR%\*.txt") do (
    set /a count_total+=1
    call :process_package "%INSTALL_DIR%" "%%~fF"
)

REM --- ABSCHLUSS-STATISTIK ---
echo.
echo %B%======================================================%W%
echo %B%                INSTALLATIONS-BERICHT%W%
echo %B%======================================================%W%
echo  Verarbeitete Pakete : %Y%!count_total!%W%
echo  Erfolgreich         : %G%!count_success!%W%
echo.
if !count_success! GTR 0 (
    echo  %G%Status: Alle Karten sind spielbereit.%W%
) else (
    echo  %R%Status: Keine neuen Karten installiert.%W%
)
echo %B%======================================================%W%
pause
exit /b

:process_package
set "srcDir=%~1"
set "infoFile=%~2"
set "m_name="
set "m_iwad=doom2.wad"
set "name_stem="
set "stopScan="

echo %B%[ SCAN ]%W% Analysiere: %Y%%~nx2%W%

REM Header-Scan
set "lineCount=0"
for /f "usebackq tokens=1* delims=:" %%A in ("%infoFile%") do (
    set /a lineCount+=1
    if !lineCount! GTR 50 set "stopScan=1"
    set "key=%%A"
    set "val=%%B"
    if not defined stopScan (
        echo !key! | findstr /i "Title" >nul
        if !errorlevel!==0 if not defined m_name (
            for /f "tokens=*" %%x in ("!val!") do set "m_name=%%x"
        )
        echo !key! | findstr /i "Filename" >nul
        if !errorlevel!==0 if not defined name_stem (
            for /f "tokens=1" %%x in ("!val!") do (
                set "fname=%%x"
                set "name_stem=!fname:~0,-4!"
            )
        )
        echo !key! | findstr /i "Description" >nul
        if !errorlevel!==0 set "stopScan=1"
    )
)

if not defined m_name set "m_name=%~n2"
if not defined name_stem set "name_stem=%~n2"

for /f "tokens=1" %%a in ("!m_name!") do set "m_folder=%%a"
set "m_folder=!m_folder:.=!"
set "m_folder=!m_folder::=!"

set "highest=0"
if exist "%CSV_FILE%" (
    for /f "tokens=1 delims=," %%I in ('type "%CSV_FILE%"') do (
        set /a "num=%%I" 2>nul
        if "!num!"=="%%I" if %%I GTR !highest! set "highest=%%I"
    )
)
set /a "new_id=highest + 1"

echo   %G%^>%W% Titel : !m_name!
echo   %G%^>%W% Pfad  : %B%!m_folder!\%W% (ID: !new_id!)

REM Schreibvorgänge
set "targetPath=%PWAD_BASE%\!m_folder!"
if not exist "!targetPath!" mkdir "!targetPath!"

REM CSV Update
set "bC=0" & set "cD=0"
set "tC=csv.tmp"
(for /f "tokens=1* delims=:" %%A in ('findstr /n "^" "%CSV_FILE%"') do (
    set "ln=%%B"
    if "!ln!"=="" (
        set /a bC+=1
        if !bC!==2 (if !cD!==0 (echo !new_id!,!m_iwad!,!m_name!,0,!m_folder!\& set "cD=1"))
        echo.
    ) else (echo(!ln!)
)) > "!tC!"
move /y "!tC!" "%CSV_FILE%" >nul

REM TXT Update
set "iP=0" & set "tD=0"
set "tT=txt.tmp"
(for /f "tokens=1* delims=:" %%A in ('findstr /n "^" "%TXT_FILE%"') do (
    set "ln=%%B"
    if "!ln!"=="" (
        if !iP!==1 (if !tD!==0 (echo !new_id! - !m_name!& set "tD=1"& set "iP=0"))
        echo.
    ) else (
        echo(!ln!
        set "cl=!ln: =!"
        if /i "!cl!"=="PWad" set "iP=1"
    )
)) > "!tT!"
move /y "!tT!" "%TXT_FILE%" >nul

REM Verschieben
if defined name_stem (
    move /y "%srcDir%\!name_stem!*.*" "!targetPath!\" >nul 2>&1
)
for %%E in (wad pk3 deh pk7 sf2 lev res def bex ipk3 hhe txt) do (
    if exist "%srcDir%\*.%%E" move /y "%srcDir%\*.%%E" "!targetPath!\" >nul 2>&1
)

set /a count_success+=1
echo %G%[ OK ] Installation abgeschlossen.%W%
echo %B%------------------------------------------------------%W%
exit /b