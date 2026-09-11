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
echo ^|  Security Patch  : August 2025                                   ^|
echo ^|  Update Channel  : RETIN                                         ^|
echo +------------------------------------------------------------------+
echo ^|                        Ported by Anjishnu                        ^|
echo +------------------------------------------------------------------+
echo.
echo =====================================================================
echo   OPTIONS:
echo =====================================================================
echo   [1] Turn ON Window-Level Native Blurs (Enable & Persist)
echo   [2] Turn OFF / Revert Window-Level Blurs (Restore Stock)
echo   [3] Check Current Window Blurs Status
echo   [4] Soft Restart (SurfaceFlinger & SystemUI)
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
adb root >nul 2>&1
timeout /t 1 >nul
exit /b 0

:ENABLE_BLUR
call :CHECK_DEVICE
echo.
echo [*] Applying Window-Level Native Blur properties...

REM Set runtime & persistent props
adb shell "which resetprop >/dev/null 2>&1 && resetprop ro.surface_flinger.supports_background_blur 1 || setprop ro.surface_flinger.supports_background_blur 1"
adb shell "which resetprop >/dev/null 2>&1 && resetprop vendor.display.supports_background_blur 1 || setprop vendor.display.supports_background_blur 1"
adb shell "which resetprop >/dev/null 2>&1 && resetprop ro.launcher.blur.appLaunch 1 || setprop ro.launcher.blur.appLaunch 1"
adb shell "setprop persist.sys.sf.disable_blurs 0"
adb shell "settings put global disable_window_blurs 0"

echo [*] Installing boot persistence scripts...
REM 1. Magisk / KernelSU module structure
adb shell "if [ -d /data/adb/modules ]; then mkdir -p /data/adb/modules/native_blurs; echo 'id=native_blurs\nname=Portov Native Window Blurs\nversion=v1.0\nversionCode=1\nauthor=Anjishnu\ndescription=Enables native window and background blurs on Moto G67 Power 5G (portov).' > /data/adb/modules/native_blurs/module.prop; echo 'ro.surface_flinger.supports_background_blur=1\nvendor.display.supports_background_blur=1\nro.launcher.blur.appLaunch=1\npersist.sys.sf.disable_blurs=0\ndebug.sf.signal_protected_for_blur=1' > /data/adb/modules/native_blurs/system.prop; touch /data/adb/modules/native_blurs/auto_mount; fi"

REM 2. post-fs-data.d script (runs before SurfaceFlinger starts)
adb shell "if [ -d /data/adb ]; then mkdir -p /data/adb/post-fs-data.d; echo '#!/system/bin/sh\nwhich resetprop >/dev/null 2>&1 && resetprop ro.surface_flinger.supports_background_blur 1\nwhich resetprop >/dev/null 2>&1 && resetprop vendor.display.supports_background_blur 1\nwhich resetprop >/dev/null 2>&1 && resetprop ro.launcher.blur.appLaunch 1\nsetprop persist.sys.sf.disable_blurs 0' > /data/adb/post-fs-data.d/99_native_blurs.sh; chmod 755 /data/adb/post-fs-data.d/99_native_blurs.sh; fi"

REM 3. service.d script (late boot settings check)
adb shell "if [ -d /data/adb ]; then mkdir -p /data/adb/service.d; echo '#!/system/bin/sh\nsleep 3\nsettings put global disable_window_blurs 0' > /data/adb/service.d/99_native_blurs.sh; chmod 755 /data/adb/service.d/99_native_blurs.sh; fi"

echo.
echo =====================================================================
echo [+] Native Window Blurs successfully ENABLED and configured!
echo =====================================================================
echo.
set /p rst="Do you want to soft restart SurfaceFlinger & SystemUI now? (Y/N): "
if /i "%rst%"=="Y" (
    echo [*] Restarting graphics compositor...
    adb shell "pkill -f com.android.systemui; stop surfaceflinger; start surfaceflinger"
    echo [+] UI restarted!
)
pause
goto MENU

:DISABLE_BLUR
call :CHECK_DEVICE
echo.
echo [*] Reverting Window-Level Native Blurs to Stock (OFF)...

REM Remove persistence scripts & modules
adb shell "rm -f /data/adb/post-fs-data.d/99_native_blurs.sh"
adb shell "rm -f /data/adb/service.d/99_native_blurs.sh"
adb shell "rm -rf /data/adb/modules/native_blurs"

REM Reset properties to stock
adb shell "which resetprop >/dev/null 2>&1 && resetprop ro.surface_flinger.supports_background_blur 0 || setprop ro.surface_flinger.supports_background_blur 0"
adb shell "which resetprop >/dev/null 2>&1 && resetprop vendor.display.supports_background_blur 0 || setprop vendor.display.supports_background_blur 0"
adb shell "which resetprop >/dev/null 2>&1 && resetprop ro.launcher.blur.appLaunch 0 || setprop ro.launcher.blur.appLaunch 0"
adb shell "setprop persist.sys.sf.disable_blurs 1"
adb shell "settings put global disable_window_blurs 1"

echo.
echo =====================================================================
echo [+] Native Window Blurs successfully REVERTED to stock (Disabled)!
echo =====================================================================
echo.
set /p rst="Do you want to soft restart SurfaceFlinger & SystemUI now? (Y/N): "
if /i "%rst%"=="Y" (
    echo [*] Restarting graphics compositor...
    adb shell "pkill -f com.android.systemui; stop surfaceflinger; start surfaceflinger"
    echo [+] UI restarted!
)
pause
goto MENU

:CHECK_STATUS
call :CHECK_DEVICE
echo.
echo =====================================================================
echo   CURRENT WINDOW BLUR STATUS:
echo =====================================================================
echo [*] ro.surface_flinger.supports_background_blur:
adb shell getprop ro.surface_flinger.supports_background_blur
echo [*] vendor.display.supports_background_blur:
adb shell getprop vendor.display.supports_background_blur
echo [*] persist.sys.sf.disable_blurs:
adb shell getprop persist.sys.sf.disable_blurs
echo [*] ro.launcher.blur.appLaunch:
adb shell getprop ro.launcher.blur.appLaunch
echo [*] Global settings disable_window_blurs:
adb shell settings get global disable_window_blurs
echo [*] Persistence Script Check:
adb shell "if [ -f /data/adb/post-fs-data.d/99_native_blurs.sh ]; then echo '    Persistence: Active (/data/adb/post-fs-data.d/99_native_blurs.sh)'; else echo '    Persistence: Not Installed'; fi"
echo =====================================================================
echo.
pause
goto MENU

:SOFT_RESTART
call :CHECK_DEVICE
echo.
echo [*] Restarting SurfaceFlinger and SystemUI...
adb shell "pkill -f com.android.systemui; stop surfaceflinger; start surfaceflinger"
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
