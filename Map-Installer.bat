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
echo %B%       DOOM AUTOMATIC INSTALLER - IWAD v7.4%W%
echo %B%======================================================%W%
echo.

if not exist "%INSTALL_DIR%" mkdir "%INSTALL_DIR%"

for %%Z in ("%INSTALL_DIR%\*.zip" "%INSTALL_DIR%\*.7z" "%INSTALL_DIR%\*.rar") do (
    set /a count_zip+=1
    echo %Y%[ ARCHIV ]%W% %%~nxZ
    set "targetZipDir=%INSTALL_DIR%\%%~nZ"
    if not exist "!targetZipDir!" mkdir "!targetZipDir!"
    if /i "%%~xZ"==".zip" ( tar -xf "%%Z" -C "!targetZipDir!" >nul 2>&1 ) else (
        powershell -command "$shell = New-Object -ComObject Shell.Application; $zip = $shell.NameSpace('%%~fZ'); $dest = $shell.NameSpace((Get-Item '!targetZipDir!').FullName); $dest.CopyHere($zip.Items(), 0x14)" >nul 2>&1
    )
    del "%%Z"
    echo %G%  - Entpackt.%W%
)

for /d %%D in ("%INSTALL_DIR%\*") do (
    set "bestFile="
    for %%F in ("%%~fD\*.txt") do (
        set "fn=%%~nxF"
        echo !fn! | findstr /i "credits license legal version" >nul
        if errorlevel 1 if not defined bestFile set "bestFile=%%~fF"
    )
    if defined bestFile (
        call :process "%%~fD" "!bestFile!"
        rd /s /q "%%~fD"
    )
)

for %%F in ("%INSTALL_DIR%\*.txt") do (
    set "fn=%%~nxF"
    echo !fn! | findstr /i "credits license" >nul
    if errorlevel 1 call :process "%INSTALL_DIR%" "%%~fF"
)

REM --- ABSCHLUSS-BERICHT ---
echo.
echo %B%======================================================%W%
echo %B%                INSTALLATIONS-BERICHT%W%
echo %B%======================================================%W%
echo  Archive verarbeitet : %Y%!count_zip!%W%
echo  Mods installiert    : %G%!count_installed!%W%
echo %B%======================================================%W%
pause
exit /b

:process
set "src=%~1"
set "txt=%~2"
set "m_name="
set "m_fold="
set "m_iwad=doom2.wad"
set "base=%~n2"

echo %B%[ SCAN ]%W% Analysiere: %Y%!base!.txt%W%

for /f "usebackq tokens=*" %%A in (`powershell -command "$c = Get-Content '%txt%'; $line = $c | Select-String 'Title\s*:' | Select-Object -First 1; if($line){ $val = $line.ToString().Split(':',2)[1].Trim(); (Get-Culture).TextInfo.ToTitleCase($val.ToLower()) } else { '!base!' }"`) do set "m_name=%%A"
if "!m_name!"=="" set "m_name=!base!"

powershell -command "$c = Get-Content '%txt%' | Out-String; if($c -match 'Ultimate|Doom1|Doom.wad'){ exit 1 } elseif($c -match 'Plutonia'){ exit 2 } elseif($c -match 'TNT|Evilution'){ exit 3 } else { exit 0 }"
set "iwad_check=%errorlevel%"

if %iwad_check%==1 set "m_iwad=doom.wad"
if %iwad_check%==2 set "m_iwad=plutonia.wad"
if %iwad_check%==3 set "m_iwad=tnt.wad"

for /f "usebackq tokens=*" %%A in (`powershell -command "$f = '!m_name!'.Split(' ')[0]; $f = $f -replace '[^a-zA-Z0-9]', ''; if($f.Length -lt 2){ '!base!' } else { $f }"`) do set "m_fold=%%A"

echo   %G%^>%W% Titel : %Y%!m_name!%W%
echo   %G%^>%W% IWAD  : %Y%!m_iwad!%W%
echo   %G%^>%W% Pfad  : %B%!m_fold!\%W%

set "targetPath=%PWAD_BASE%\!m_fold!"
if not exist "!targetPath!" mkdir "!targetPath!" 2>nul

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
        if !blankCount!==2 (echo !id!,!m_iwad!,!m_name!,0,!m_fold!\)
        echo.
    ) else (echo(!line!)
)) > temp.csv
move /y temp.csv "%CSV_FILE%" >nul

set "isP=0"
(for /f "tokens=1* delims=:" %%A in ('findstr /n "^" "%TXT_FILE%"') do (
    set "line=%%B"
    if "!line!"=="" (
        if !isP!==1 (echo !id! - !m_name!& set "isP=0")
        echo.
    ) else (
        echo(!line!
        set "check=!line: =!"
        if /i "!check!"=="PWad" set "isP=1"
    )
)) > temp.txt
move /y temp.txt "%TXT_FILE%" >nul

set "m_stem="
for /f "usebackq tokens=*" %%A in (`powershell -command "$line = (Get-Content '%txt%' | Select-String 'Filename\s*:' | Select-Object -First 1); if($line){ $line.ToString().Split(':',2)[1].Trim().Replace('.wad','').Replace('.WAD','').Trim() } else { '!base!' }"`) do set "m_stem=%%A"

if exist "%src%\!m_stem!*.*" move /y "%src%\!m_stem!*.*" "!targetPath!\" >nul 2>&1
for %%E in (wad pk3 deh bex txt) do if exist "%src%\*.%%E" move /y "%src%\*.%%E" "!targetPath!\" >nul 2>&1

set /a count_installed+=1
echo %G%[ OK ]%W% Registriert mit !m_iwad!
echo %B%------------------------------------------------------%W%
exit /b