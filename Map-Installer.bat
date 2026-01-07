@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

for /f %%a in ('echo prompt $E ^| cmd') do set "ESC=%%a"
set "G=%ESC%[92m" & set "Y=%ESC%[93m" & set "B=%ESC%[94m" & set "R=%ESC%[91m" & set "W=%ESC%[0m"
set "CY=%ESC%[96m" & set "GRA=%ESC%[90m"

set "INSTALL_DIR=Install"
set "PWAD_BASE=pwad"
set "CSV_FILE=maps.csv"
set "TXT_FILE=Maps.txt"

:main_menu
cls
echo %B%------------------------------------------------------%W%
echo                 %CY%DOOM MAP INSTALLER%W%
echo %B%------------------------------------------------------%W%
echo.

if not exist "%INSTALL_DIR%" mkdir "%INSTALL_DIR%"

set "found_files=0"
for /f %%A in ('dir /b /a "%INSTALL_DIR%" 2^>nul') do set "found_files=1"

if "%found_files%"=="0" (
    echo   %Y%i STATUS: Keine neuen Dateien im Install-Ordner.%W%
    echo.
    echo   1 - Beenden
    echo   2 - Datenbank-Backup wiederherstellen
    echo.
    set /p "opt=  Auswahl: "
    if "!opt!"=="2" goto :restore_logic
    exit /b
)

echo %G%* Scanne Install Ordner...%W%
if exist "%CSV_FILE%" copy /y "%CSV_FILE%" "%CSV_FILE%.bak" >nul 2>&1
if exist "%TXT_FILE%" copy /y "%TXT_FILE%" "%TXT_FILE%.bak" >nul 2>&1

REM --- ENTPACKEN ---
set "zip_found=0"
for %%Z in ("%INSTALL_DIR%\*.zip" "%INSTALL_DIR%\*.7z" "%INSTALL_DIR%\*.rar") do set "zip_found=1"
if "%zip_found%"=="1" (
    echo %G%* Archive erkannt - Entpacke Daten...%W%
    for %%Z in ("%INSTALL_DIR%\*.zip" "%INSTALL_DIR%\*.7z" "%INSTALL_DIR%\*.rar") do (
        set "targetZipDir=%INSTALL_DIR%\%%~nZ"
        if not exist "!targetZipDir!" mkdir "!targetZipDir!"
        tar -xf "%%Z" -C "!targetZipDir!" >nul 2>&1
        del "%%Z"
    )
)

echo %G%* Analysiere Karten-Strukturen...%W%
echo.

for /d %%D in ("%INSTALL_DIR%\*") do (
    set "m_name="
    set "m_iwad="
    set "m_fold=%%~nxD"
    set "m_fold=!m_fold: =!"
    
    echo   %Y%KARTE:%W% %CY%%%~nxD%W%
    
    for %%F in ("%%~fD\*.txt") do (
        if "!m_name!"=="" (
            for /f "usebackq tokens=*" %%A in (`powershell -command "$c = Get-Content '%%~fF'; $line = $c | Select-String 'Title\s*:' | Select-Object -First 1; if($line){ $val = $line.ToString().Split(':',2)[1].Trim(); (Get-Culture).TextInfo.ToTitleCase($val.ToLower()) }"`) do (
                set "m_name=%%A"
                echo   %GRA%--- Name gefunden in %%~nxF%W%
            )
        )
        if "!m_iwad!"=="" (
            powershell -command "$c = Get-Content '%%~fF'; $search = $c | Select-String 'Game|IWAD|Requires' | Out-String; if($search -match 'Doom 2|Doom II|Doom2'){ exit 2 } elseif($search -match 'Plutonia'){ exit 3 } elseif($search -match 'TNT|Evilution'){ exit 4 } elseif($search -match 'Ultimate|Doom1|Doom.wad'){ exit 1 } else { exit 0 }"
            set "iwad_check=!errorlevel!"
            if !iwad_check! NEQ 0 (
                if !iwad_check!==1 set "m_iwad=doom.wad"
                if !iwad_check!==2 set "m_iwad=doom2.wad"
                if !iwad_check!==3 set "m_iwad=plutonia.wad"
                if !iwad_check!==4 set "m_iwad=tnt.wad"
                echo   %GRA%--- IWAD gefunden in %%~nxF%W%
            )
        )
    )

    if "!m_name!"=="" set "m_name=%%~nxD"
    
    findstr /C:",!m_name!," "%CSV_FILE%" >nul 2>&1
    if !errorlevel! EQU 0 (
        echo   %Y%--- Karte bereits vorhanden. Überspringe...%W%
    ) else (
        if "!m_iwad!"=="" call :manual_selector "!m_name!"
        set "targetPath=%PWAD_BASE%\!m_fold!"
        if not exist "!targetPath!" mkdir "!targetPath!"
        for %%E in (wad pk3 deh bex txt) do if exist "%%~fD\*.%%E" move /y "%%~fD\*.%%E" "!targetPath!\" >nul 2>&1
        call :update_db "!m_name!" "!m_iwad!" "!m_fold!"
        echo   --- Einträge angelegt. ID: %CY%!id!%W% ^| IWAD: %CY%!m_iwad!%W% ^| Pfad: %CY%!m_fold!\%W%
    )
    rd /s /q "%%~fD"
    echo.
)

for %%W in ("%INSTALL_DIR%\*.wad" "%INSTALL_DIR%\*.pk3") do (
    set "m_name=%%~nW"
    set "m_fold=%%~nW"
    set "m_fold=!m_fold: =!"
    echo   %Y%KARTE:%W% %CY%%%~nxW%W%
    findstr /C:",!m_name!," "%CSV_FILE%" >nul 2>&1
    if !errorlevel! EQU 0 (
        echo   %Y%--- Karte bereits vorhanden. Überspringe...%W%
    ) else (
        call :manual_selector "!m_name!"
        set "targetPath=%PWAD_BASE%\!m_fold!"
        if not exist "!targetPath!" mkdir "!targetPath!" 2>nul
        move /y "%%~fW" "!targetPath!\" >nul 2>&1
        call :update_db "!m_name!" "!m_iwad!" "!m_fold!"
        echo   --- Einträge angelegt. ID: %CY%!id!%W% ^| IWAD: %CY%!m_iwad!%W% ^| Pfad: %CY%!m_fold!\%W%
    )
    echo.
)

echo %B%------------------------------------------------------%W%
echo %G%INSTALLATION ERFOLGREICH ABGESCHLOSSEN.%W%
echo %B%------------------------------------------------------%W%
pause
exit /b

:manual_selector
echo   --- %R%IWAD konnte nicht automatisch bestimmt werden.%W%
echo       Wähle für: %CY%%~1%W%
echo       1:Doom1  2:Doom2  3:Plutonia  4:TNT
set "choice=2"
set /p "choice=      Auswahl - Standard 2: "
if "!choice!"=="1" (set "m_iwad=doom.wad") else if "!choice!"=="3" (set "m_iwad=plutonia.wad") else if "!choice!"=="4" (set "m_iwad=tnt.wad") else (set "m_iwad=doom2.wad")
exit /b

:update_db
set "d_name=%~1"
set "d_iwad=%~2"
set "d_fold=%~3"
set "id=0"
for /f "tokens=1 delims=," %%I in ('type "%CSV_FILE%"') do (
    set /a "val=%%I" 2>nul
    if !val! GTR !id! set "id=!val!"
)
set /a id+=1
set "blankCount=0"
(for /f "tokens=1* delims=:" %%A in ('findstr /n "^" "%CSV_FILE%"') do (
    set "line=%%B"
    if "!line!"=="" (
        set /a blankCount+=1
        if !blankCount!==2 (echo !id!,!d_iwad!,!d_name!,0,!d_fold!\)
        echo.
    ) else (echo(!line!)
)) > temp.csv
move /y temp.csv "%CSV_FILE%" >nul
set "isP=0"
(for /f "tokens=1* delims=:" %%A in ('findstr /n "^" "%TXT_FILE%"') do (
    set "line=%%B"
    if "!line!"=="" (
        if !isP!==1 (echo !id! - !d_name!& set "isP=0")
        echo.
    ) else (
        echo(!line!
        set "check=!line: =!"
        if /i "!check!"=="PWad" set "isP=1"
    )
)) > temp.txt
move /y temp.txt "%TXT_FILE%" >nul
exit /b

:restore_logic
copy /y "%CSV_FILE%.bak" "%CSV_FILE%" >nul 2>&1
copy /y "%TXT_FILE%.bak" "%TXT_FILE%" >nul 2>&1
echo   %G%BACKUP WIEDERHERGESTELLT.%W%
pause
goto :main_menu