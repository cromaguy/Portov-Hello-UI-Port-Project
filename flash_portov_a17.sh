#!/usr/bin/env bash
#
# Moto G67 Power 5G (portov) - Android 17 Flasher (Linux/macOS)
# Ported by Anjishnu
#

set -e

echo "+------------------------------------------------------------------+"
echo "|                    Moto G67 Power 5G (portov)                    |"
echo "|                     HelloUI Fastboot Flasher                     |"
echo "+------------------------------------------------------------------+"
echo "|  Android Version : 17                                            |"
echo "|  Base Firmware   : Android 16 (W1VTS36H.22-20-3-2-4 / cid50)      |"
echo "|  Update Channel  : Global Retail / RETIN (Universal)              |"
echo "+------------------------------------------------------------------+"
echo "|                        Ported by Anjishnu                        |"
echo "+------------------------------------------------------------------+"
echo ""
echo "[WARNING] Prerequisites:"
echo "  1. Bootloader must be UNLOCKED."
echo "  2. Backup all data (clean flash / factory reset required)."
echo ""
read -p "Press Enter to continue or Ctrl+C to cancel..."

echo "[*] Checking fastboot connection..."
fastboot devices

echo "[*] Step 1: Flashing Boot (Permissive SELinux), Recovery, and VBMeta..."
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

echo "[*] Rebooting to userspace fastbootd..."
fastboot reboot fastboot
sleep 10

echo "[*] Flashing Dynamic Partitions in FastbootD..."
fastboot flash system_a system.img
fastboot flash system system.img
fastboot flash system_ext_a system_ext.img
fastboot flash system_ext system_ext.img
fastboot flash product_a product.img
fastboot flash product product.img
fastboot flash vendor_a vendor.img
fastboot flash vendor vendor.img
fastboot flash vendor_dlkm_a vendor_dlkm.img
fastboot flash vendor_dlkm vendor_dlkm.img
fastboot flash system_dlkm_a system_dlkm.img
fastboot flash system_dlkm system_dlkm.img

echo "[*] Erasing Userdata (Factory Reset)..."
fastboot erase userdata
fastboot erase metadata

echo "[+] Flashing complete! Rebooting..."
fastboot reboot
