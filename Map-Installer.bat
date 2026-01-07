@echo off
setlocal enabledelayedexpansion
chcp 65001 >nul

for /f "tokens=*" %%a in ('powershell -command "[console]::Out.Write('')"') do (set "dummy=%%a")
reg add HKCU\Console /v VirtualTerminalLevel /t REG_DWORD /d 1 /f >nul 2>&1
for /f %%a in ('echo prompt $E ^| cmd') do set "ESC=%%a"
set "G=%ESC%[92m" & set "Y=%ESC%[93m" & set "B=%ESC%[94m" & set "R=%ESC%[91m" & set "W=%ESC%[0m"

set "INSTALL_DIR=Install"
set "PWAD_BASE=pwad"
set "CSV_FILE=maps.csv"
set "TXT_FILE=Maps.txt"

set /a count_zip=0
set /a count_installed=0

cls
echo %B%======================================================%W%
echo %B%       DOOM AUTOMATIC INSTALLER - AUTO-CAPS v6.4%W%
echo %B%======================================================%W%
echo.

if not exist "%INSTALL_DIR%" mkdir "%INSTALL_DIR%"

REM --- 1. ARCHIVE ENTPACKEN ---
for %%Z in ("%INSTALL_DIR%\*.zip" "%INSTALL_DIR%\*.7z" "%INSTALL_DIR%\*.rar") do (
    set /a count_zip+=1
    echo %Y%[ ARCHIV ]%W% %%~nxZ
    set "targetZipDir=%INSTALL_DIR%\%%~nZ"
    if not exist "!targetZipDir!" mkdir "!targetZipDir!"
    
    echo %B%  - Entpacke Daten...%W%
    if /i "%%~xZ"==".zip" (
        tar -xf "%%Z" -C "!targetZipDir!" >nul 2>&1
    ) else (
        powershell -command "$shell = New-Object -ComObject Shell.Application; $zip = $shell.NameSpace('%%~fZ'); $dest = $shell.NameSpace((Get-Item '!targetZipDir!').FullName); $dest.CopyHere($zip.Items(), 0x14)" >nul 2>&1
    )
    del "%%Z"
    echo %G%  - Fertig.%W%
    echo %B%------------------------------------------------------%W%
)

for /d %%D in ("%INSTALL_DIR%\*") do (
    set "bestFile="
    set "folderName=%%~nD"
    if exist "%%~fD\!folderName!.txt" (
        set "bestFile=%%~fD\!folderName!.txt"
    ) else (
        for %%F in ("%%~fD\*.txt") do (
            findstr /i "Title:" "%%~fT" >nul 2>&1
            if !errorlevel! equ 0 (
                set "fname=%%~nxF"
                echo !fname! | findstr /i "credits license legal version" >nul
                if !errorlevel! neq 0 set "bestFile=%%~fF"
            )
        )
    )
    if not defined bestFile (
        for %%F in ("%%~fD\*.txt") do (
            set "fname=%%~nxF"
            echo !fname! | findstr /i "credits license legal version" >nul
            if !errorlevel! neq 0 set "bestFile=%%~fF"
        )
    )
    if defined bestFile (
        call :process_package "%%~fD" "!bestFile!"
        rd /s /q "%%~fD"
    )
)

for %%F in ("%INSTALL_DIR%\*.txt") do (
    set "fname=%%~nxF"
    echo !fname! | findstr /i "credits license" >nul
    if !errorlevel! neq 0 call :process_package "%INSTALL_DIR%" "%%~fF"
)

REM --- ZUSAMMENFASSUNG ---
echo.
echo %B%======================================================%W%
echo %B%                INSTALLATIONS-BERICHT%W%
echo %B%======================================================%W%
echo  Archive entpackt : %Y%!count_zip!%W%
echo  Mods installiert : %G%!count_installed!%W%
echo %B%======================================================%W%
pause
exit /b

:process_package
set "srcDir=%~1"
set "infoFile=%~2"
set "m_name="
set "name_stem="

echo %B%[ SCAN ]%W% Analysiere: %Y%%~nx2%W%

for /f "tokens=1* delims=:" %%A in ('findstr /i "Title: Filename:" "%infoFile%"') do (
    set "key=%%A"
    set "val=%%B"
    set "val=!val:~1!"
    echo !key! | findstr /i "Title" >nul
    if !errorlevel!==0 if not defined m_name set "m_name=!val!"
    echo !key! | findstr /i "Filename" >nul
    if !errorlevel!==0 if not defined name_stem (
        set "name_stem=!val!"
        set "name_stem=!name_stem:.wad=!"
        set "name_stem=!name_stem:.pk3=!"
        set "name_stem=!name_stem: =!"
    )
)

if not defined m_name set "m_name=%~n2"
if not defined name_stem set "name_stem=%~n2"

for /f "usebackq tokens=*" %%C in (`powershell -command "(Get-Culture).TextInfo.ToTitleCase('!m_name!'.ToLower())"`) do set "m_name=%%C"

for /f "tokens=1" %%a in ("!m_name!") do set "m_folder=%%a"
set "m_folder=!m_folder:.=!"
set "m_folder=!m_folder::=!"

set "highest=0"
for /f "tokens=1 delims=," %%I in ('type "%CSV_FILE%"') do (
    set /a "num=%%I" 2>nul
    if !num! GTR !highest! set "highest=!num!"
)
set /a "new_id=highest + 1"

echo   %G%^>%W% Titel : %Y%!m_name!%W%
echo   %G%^>%W% ID    : !new_id!
echo   %G%^>%W% Pfad  : %B%!m_folder!\%W%

set "targetPath=%PWAD_BASE%\!m_folder!"
if not exist "!targetPath!" mkdir "!targetPath!"

set "bC=0" & set "cD=0"
(for /f "tokens=1* delims=:" %%A in ('findstr /n "^" "%CSV_FILE%"') do (
    set "ln=%%B"
    if "!ln!"=="" (
        set /a bC+=1
        if !bC!==2 if !cD!==0 (echo !new_id!,doom2.wad,!m_name!,0,!m_folder!\& set "cD=1")
        echo.
    ) else (echo(!ln!)
)) > csv.tmp
move /y csv.tmp "%CSV_FILE%" >nul

set "iP=0" & set "tD=0"
(for /f "tokens=1* delims=:" %%A in ('findstr /n "^" "%TXT_FILE%"') do (
    set "ln=%%B"
    if "!ln!"=="" (
        if !iP!==1 if !tD!==0 (echo !new_id! - !m_name!& set "tD=1")
        echo.
    ) else (
        echo(!ln!
        set "cl=!ln: =!"
        if /i "!cl!"=="PWad" set "iP=1"
    )
)) > txt.tmp
move /y txt.tmp "%TXT_FILE%" >nul

if exist "%srcDir%\!name_stem!*.*" move /y "%srcDir%\!name_stem!*.*" "!targetPath!\" >nul 2>&1
for %%E in (wad pk3 deh bex txt) do (
    if exist "%srcDir%\*.%%E" move /y "%srcDir%\*.%%E" "!targetPath!\" >nul 2>&1
)

set /a count_installed+=1
echo %G%[ OK ]%W% Abgeschlossen.
echo %B%------------------------------------------------------%W%
exit /b