@echo off
cd /d "%~dp0"
title Portov - Flash Permissive Boot
color 0e
echo +------------------------------------------------------------------+
echo ^|                    Moto G67 Power 5G (portov)                    ^|
echo ^|                 SELinux Permissive Boot Flasher                  ^|
echo +------------------------------------------------------------------+
echo ^|  Android Version : 17                                            ^|
echo ^|  Security Patch  : August 2025                                   ^|
echo ^|  Update Channel  : RETIN                                         ^|
echo +------------------------------------------------------------------+
echo ^|                        Ported by Anjishnu                        ^|
echo +------------------------------------------------------------------+
echo.
echo [*] Checking Fastboot connection...
fastboot devices
if errorlevel 1 (
    echo [!] No device detected in fastboot! Please connect phone in Bootloader mode.
    pause
    exit /b 1
)
echo.
echo [*] Flashing SELinux Permissive Boot to Slot A and Slot B...
fastboot flash boot_a boot_permissive.img
fastboot flash boot_b boot_permissive.img
if errorlevel 1 (
    echo [!] Flashing failed!
    pause
    exit /b 1
)
echo.
echo [+] SELinux Permissive Boot flashed successfully to both slots!
echo [*] Rebooting system...
fastboot reboot
pause
