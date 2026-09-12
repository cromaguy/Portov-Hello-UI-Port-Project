@echo off
cd /d "%~dp0"
title Portov (Moto G67 Power 5G) - Android 17 / Hello UI Port Flasher
color 0b
echo +------------------------------------------------------------------+
echo ^|                    Moto G67 Power 5G (portov)                    ^|
echo ^|                     HelloUI Fastboot Flasher                     ^|
echo +------------------------------------------------------------------+
echo ^|  Android Version : 17                                            ^|
echo ^|  Base Firmware   : Android 16 (W1VTS36H.22-20-3-2-4 / cid50)      ^|
echo ^|  Update Channel  : Global Retail / RETIN (Universal)              ^|
echo +------------------------------------------------------------------+
echo ^|                        Ported by Anjishnu                        ^|
echo +------------------------------------------------------------------+
echo.
echo [WARNING] DO NOT RUN THIS SCRIPT UNLESS:
echo   1. Your bootloader is UNLOCKED (fastboot oem unlock).
echo   2. You have a full backup of your personal data.
echo   3. You have Software Fix installed on PC.
echo.
echo Press Ctrl+C to cancel, or
pause

echo.
echo [*] Checking Fastboot connection...
fastboot devices
if errorlevel 1 (
    echo [!] No device detected in fastboot! Please connect phone in Bootloader mode.
    pause
    exit /b 1
)

echo.
echo [*] Step 1: Flashing Boot (Permissive SELinux), Recovery, and VBMeta...
fastboot --set-active=a
fastboot flash boot_a boot_permissive.img
fastboot flash boot_b boot_permissive.img
fastboot flash init_boot_a init_boot.img
fastboot flash init_boot_b init_boot.img
fastboot flash vendor_boot_a vendor_boot.img
fastboot flash vendor_boot_b vendor_boot.img
fastboot flash dtbo_a dtbo.img
fastboot flash dtbo_b dtbo.img
fastboot flash recovery_a recovery.img
fastboot flash recovery_b recovery.img
fastboot flash vbmeta_a vbmeta.img
fastboot flash vbmeta_b vbmeta.img
fastboot flash vbmeta_system_a vbmeta_system.img
fastboot flash vbmeta_system_b vbmeta_system.img

echo.
echo [*] Step 2: Rebooting into FastbootD (Userspace Fastboot)...
echo Your phone screen will reboot into the FastbootD menu (looks like recovery).
fastboot reboot fastboot
echo Waiting for FastbootD to load...
timeout /t 10 /nobreak >nul

echo.
echo [*] Step 3: Flashing Dynamic Partitions in FastbootD...
echo Flashing Android 17 System...
fastboot flash system_a system.img
fastboot flash system system.img

echo Flashing Android 17 System Ext...
fastboot flash system_ext_a system_ext.img
fastboot flash system_ext system_ext.img

echo Flashing Hello UI 17 Product...
fastboot flash product_a product.img
fastboot flash product product.img

echo Flashing Portov Base Vendor...
fastboot flash vendor_a vendor.img
fastboot flash vendor vendor.img

echo Flashing Kernel DLKM Drivers...
fastboot flash vendor_dlkm_a vendor_dlkm.img
fastboot flash vendor_dlkm vendor_dlkm.img
fastboot flash system_dlkm_a system_dlkm.img
fastboot flash system_dlkm system_dlkm.img

echo.
echo [*] Step 4: Factory Resetting Userdata (Clean Flash)...
fastboot erase userdata
fastboot erase metadata

echo.
echo =====================================================================
echo [SUCCESS] Flashing complete! Rebooting device now...
echo =====================================================================
fastboot reboot
echo Done. Press any key to exit.
pause >nul
