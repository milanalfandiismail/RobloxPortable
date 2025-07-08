@echo off
setlocal enabledelayedexpansion

:: ====== KONFIGURASI AWAL ======
set "portableDir=%~dp0"
set "versionsPath=%~dp0Versions\Versions"

echo [DEBUG] Cek folder: %versionsPath%
if not exist "%versionsPath%" (
    echo [ERROR] Folder tidak ditemukan: %versionsPath%
    pause
    exit /b
)

echo.
echo [DEBUG] Daftar subfolder:
dir /b /ad "%versionsPath%"
echo.

:: TEST: LOOP MELIHAT ISI FOLDER
for /f "delims=" %%F in ('dir /b /ad "%versionsPath%"') do (
    set "folderName=%%F"
    set "folderPath=%versionsPath%\%%F"
    echo [CHECKING] !folderName!

    if exist "!folderPath!\RobloxPlayerBeta.exe" (
        echo     [FOUND] RobloxPlayerBeta.exe ada di !folderName!
    ) else (
        echo     [DELETE] Tidak ada RobloxPlayerBeta.exe, seharusnya dihapus: !folderPath!
        rmdir /s /q "!folderPath!"  ← untuk saat ini hanya simulasi
    )
)

echo.
echo [SELESAI] Debug selesai.



:: ====== REGISTRY KEY (5) ======
set "reg1=HKCU\Software\Roblox\RobloxStudioUrl"

:: ====== SYMLINK (5) ======
set "link1=%ProgramFiles(x86)%\Roblox"
set "target1=%portableDir%\Versions"

set "link2=%TEMP%\Roblox"
set "target2=%portableDir%\http"

set "link3=%programdata%\Roblox"
set "target3=%portableDir%\Downloads"


:: ====== BUAT MKLINK ======
echo [INFO] Membuat symbolic link...
if exist "%link1%" rmdir /s /q "%link1%"
mklink /D "%link1%" "%target1%"

if exist "%link2%" rmdir /s /q "%link2%"
mklink /D "%link2%" "%target2%"

if exist "%link3%" rmdir /s /q "%link3%"
mklink /D "%link3%" "%target3%"


:: ====== DETEKSI FOLDER VERSION TERBARU ======
echo [INFO] Mendeteksi versi Roblox terbaru...
pushd "%versionsPath%"
set "latestVersionFolder="

for /f "delims=" %%i in ('dir /b /ad /o-d ^| findstr /i "^version-"') do (
    set "latestVersionFolder=%%i"
    goto :found
)
:found
popd

if not defined latestVersionFolder (
    echo [ERROR] Tidak ditemukan folder version-* di %versionsPath%
    pause
    exit /b
)

set "robloxExe=%versionsPath%\%latestVersionFolder%\RobloxPlayerBeta.exe"
echo [INFO] Versi terbaru: %latestVersionFolder%

:: ====== TULIS REGISTRY ======
echo [INFO] Mengatur registry Roblox...
reg import "1.reg"
reg import "2.reg"


:: ====== EDIT PATH DI REGISTRY SETELAH IMPORT ======
echo [INFO] Mengupdate path registry Roblox...
reg add "HKLM\SOFTWARE\Classes\roblox-player\shell\open\command" /ve /d "\"%robloxExe%\" %%1" /f


:: ====== JALANKAN ROBLOX ======
echo [INFO] Menjalankan Roblox...
start "" "%robloxExe%"

endlocal
