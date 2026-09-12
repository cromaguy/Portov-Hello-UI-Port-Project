@echo off
setlocal enabledelayedexpansion
cd /d "%~dp0"
title Moto G67 Power 5G - Window Blurs Add-on Manager
color 0b

:MENU
cls
echo +------------------------------------------------------------------+
echo ^|                    Moto G67 Power 5G (portov)                    ^|
echo ^|             Window-Level Native Blurs Manager Add-on             ^|
echo +------------------------------------------------------------------+
echo ^|  Android Version : 17                                            ^|
echo ^|  Base Firmware   : Android 16 (Universal Global / RETIN cid50)   ^|
echo ^|  Ported by       : Anjishnu                                      ^|
echo +------------------------------------------------------------------+
echo.
echo =====================================================================
echo   OPTIONS:
echo =====================================================================
echo   [1] Turn ON Window-Level Native Blurs (Active)
echo   [2] Turn OFF Window-Level Native Blurs (Solid / Power Save)
echo   [3] Check Current Window Blurs Status
echo   [4] Soft Restart (SurfaceFlinger ^& SystemUI)
echo   [5] Full Device Reboot
echo   [6] Exit
echo =====================================================================
set /p opt="Select an option [1-6]: "

if "%opt%"=="1" goto ENABLE_BLUR
if "%opt%"=="2" goto DISABLE_BLUR
if "%opt%"=="3" goto CHECK_STATUS
if "%opt%"=="4" goto SOFT_RESTART
if "%opt%"=="5" goto FULL_REBOOT
if "%opt%"=="6" goto EXIT_SCRIPT
echo [!] Invalid selection. Please choose 1 to 6.
timeout /t 2 >nul
goto MENU

:CHECK_DEVICE
echo.
echo [*] Checking ADB connection...
adb devices | findstr /v /r "^List" | findstr /r "[a-zA-Z0-9]" >nul
if errorlevel 1 (
    echo [!] No device detected via ADB!
    echo [*] Please make sure:
    echo     1. Phone is booted and connected via USB.
    echo     2. USB Debugging is ENABLED in Developer Options.
    echo     3. You have authorized this PC on the phone prompt.
    echo.
    pause
    goto MENU
)
adb wait-for-device
exit /b 0

:ENABLE_BLUR
call :CHECK_DEVICE
echo.
echo [*] Enabling Window-Level Native Blurs...

REM Set user/system toggles (works on all devices without root)
adb shell "settings put global disable_window_blurs 0"
adb shell "setprop persist.sys.sf.disable_blurs 0"

REM If rooted with Magisk/KernelSU, apply resetprop for additional launcher hooks
adb shell "su -c 'which resetprop >/dev/null 2>&1 && resetprop ro.surface_flinger.supports_background_blur 1 && resetprop vendor.display.supports_background_blur 1 && resetprop ro.launcher.blur.appLaunch 1' >/dev/null 2>&1"

echo.
echo =====================================================================
echo [+] Native Window Blurs successfully ENABLED!
echo =====================================================================
echo.
set /p rst="Do you want to soft restart SurfaceFlinger & SystemUI now? (Y/N): "
if /i "%rst%"=="Y" (
    echo [*] Restarting graphics compositor...
    adb shell "su -c 'stop surfaceflinger; start surfaceflinger' 2>/dev/null || pkill -f com.android.systemui"
    echo [+] UI restart triggered!
)
pause
goto MENU

:DISABLE_BLUR
call :CHECK_DEVICE
echo.
echo [*] Disabling Window-Level Native Blurs (Solid / Power Save mode)...

adb shell "settings put global disable_window_blurs 1"
adb shell "setprop persist.sys.sf.disable_blurs 1"
adb shell "su -c 'which resetprop >/dev/null 2>&1 && resetprop ro.launcher.blur.appLaunch 0' >/dev/null 2>&1"

echo.
echo =====================================================================
echo [+] Native Window Blurs successfully DISABLED (Solid / Stock styling)!
echo =====================================================================
echo.
set /p rst="Do you want to soft restart SurfaceFlinger & SystemUI now? (Y/N): "
if /i "%rst%"=="Y" (
    echo [*] Restarting graphics compositor...
    adb shell "su -c 'stop surfaceflinger; start surfaceflinger' 2>/dev/null || pkill -f com.android.systemui"
    echo [+] UI restart triggered!
)
pause
goto MENU

:CHECK_STATUS
call :CHECK_DEVICE
echo.
echo =====================================================================
echo   CURRENT WINDOW BLUR STATUS:
echo =====================================================================
echo [*] Hardware Capability (ro.surface_flinger.supports_background_blur):
adb shell getprop ro.surface_flinger.supports_background_blur
echo [*] Global Window Blurs Setting (0=Active, 1=Disabled):
adb shell settings get global disable_window_blurs
echo [*] SurfaceFlinger Blur Persistence (0=Active, 1=Disabled):
adb shell getprop persist.sys.sf.disable_blurs
echo [*] Launcher App Launch Blur (ro.launcher.blur.appLaunch):
adb shell getprop ro.launcher.blur.appLaunch
echo =====================================================================
echo.
pause
goto MENU

:SOFT_RESTART
call :CHECK_DEVICE
echo.
echo [*] Restarting SurfaceFlinger and SystemUI...
adb shell "su -c 'stop surfaceflinger; start surfaceflinger' 2>/dev/null || pkill -f com.android.systemui"
echo [+] Done!
pause
goto MENU

:FULL_REBOOT
call :CHECK_DEVICE
echo.
echo [*] Rebooting device...
adb reboot
echo [+] Device reboot initiated.
pause
goto MENU

:EXIT_SCRIPT
echo [*] Exiting. Have a great day!
timeout /t 1 >nul
exit /b 0
