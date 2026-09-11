#!/usr/bin/env bash
set -e
echo "+------------------------------------------------------------------+"
echo "|                    Moto G67 Power 5G (portov)                    |"
echo "|                 SELinux Permissive Boot Flasher                  |"
echo "+------------------------------------------------------------------+"
echo "|  Android Version : 17                                            |"
echo "|  Security Patch  : August 2025                                   |"
echo "|  Update Channel  : RETIN                                         |"
echo "+------------------------------------------------------------------+"
echo "|                        Ported by Anjishnu                        |"
echo "+------------------------------------------------------------------+"
echo ""
echo "[*] Checking fastboot connection..."
fastboot devices
echo ""
echo "[*] Flashing SELinux Permissive Boot to Slot A and Slot B..."
fastboot flash boot_a boot_permissive.img
fastboot flash boot_b boot_permissive.img
echo ""
echo "[+] SELinux Permissive Boot flashed successfully to both slots!"
echo "[*] Rebooting system..."
fastboot reboot
