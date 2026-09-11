#!/usr/bin/env bash
#
# Moto G67 Power 5G (portov) - Window-Level Native Blurs Manager Add-on
# Android 17 / Hello UI - Ported by Anjishnu
#

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

print_header() {
    clear
    echo -e "${CYAN}+------------------------------------------------------------------+"
    echo -e "|                    Moto G67 Power 5G (portov)                    |"
    echo -e "|             Window-Level Native Blurs Manager Add-on             |"
    echo -e "+------------------------------------------------------------------+"
    echo -e "|  Android Version : 17                                            |"
    echo -e "|  Security Patch  : August 2025                                   |"
    echo -e "|  Update Channel  : RETIN                                         |"
    echo -e "+------------------------------------------------------------------+"
    echo -e "|                        Ported by Anjishnu                        |"
    echo -e "+------------------------------------------------------------------+${NC}"
    echo ""
}

check_device() {
    echo -e "${YELLOW}[*] Checking ADB connection...${NC}"
    if ! adb devices | grep -v "^List" | grep -q "[a-zA-Z0-9]"; then
        echo -e "${RED}[!] No device detected via ADB!${NC}"
        echo "[*] Please make sure:"
        echo "    1. Phone is booted and connected via USB."
        echo "    2. USB Debugging is ENABLED in Developer Options."
        echo "    3. You have authorized this PC on the phone prompt."
        echo ""
        read -p "Press Enter to return to menu..."
        return 1
    fi
    adb wait-for-device
    adb root >/dev/null 2>&1 || true
    return 0
}

enable_blurs() {
    if ! check_device; then return; fi
    echo ""
    echo -e "${YELLOW}[*] Applying Window-Level Native Blur properties...${NC}"

    adb shell "which resetprop >/dev/null 2>&1 && resetprop ro.surface_flinger.supports_background_blur 1 || setprop ro.surface_flinger.supports_background_blur 1"
    adb shell "which resetprop >/dev/null 2>&1 && resetprop vendor.display.supports_background_blur 1 || setprop vendor.display.supports_background_blur 1"
    adb shell "which resetprop >/dev/null 2>&1 && resetprop ro.launcher.blur.appLaunch 1 || setprop ro.launcher.blur.appLaunch 1"
    adb shell "setprop persist.sys.sf.disable_blurs 0"
    adb shell "settings put global disable_window_blurs 0"

    echo -e "${YELLOW}[*] Installing boot persistence scripts...${NC}"
    # Magisk / KernelSU module structure
    adb shell "if [ -d /data/adb/modules ]; then mkdir -p /data/adb/modules/native_blurs; printf 'id=native_blurs\nname=Portov Native Window Blurs\nversion=v1.0\nversionCode=1\nauthor=Anjishnu\ndescription=Enables native window and background blurs on Moto G67 Power 5G (portov).\n' > /data/adb/modules/native_blurs/module.prop; printf 'ro.surface_flinger.supports_background_blur=1\nvendor.display.supports_background_blur=1\nro.launcher.blur.appLaunch=1\npersist.sys.sf.disable_blurs=0\ndebug.sf.signal_protected_for_blur=1\n' > /data/adb/modules/native_blurs/system.prop; touch /data/adb/modules/native_blurs/auto_mount; fi"

    # post-fs-data.d script (runs before SurfaceFlinger starts)
    adb shell "if [ -d /data/adb ]; then mkdir -p /data/adb/post-fs-data.d; printf '#!/system/bin/sh\nwhich resetprop >/dev/null 2>&1 && resetprop ro.surface_flinger.supports_background_blur 1\nwhich resetprop >/dev/null 2>&1 && resetprop vendor.display.supports_background_blur 1\nwhich resetprop >/dev/null 2>&1 && resetprop ro.launcher.blur.appLaunch 1\nsetprop persist.sys.sf.disable_blurs 0\n' > /data/adb/post-fs-data.d/99_native_blurs.sh; chmod 755 /data/adb/post-fs-data.d/99_native_blurs.sh; fi"

    # service.d script (late boot settings check)
    adb shell "if [ -d /data/adb ]; then mkdir -p /data/adb/service.d; printf '#!/system/bin/sh\nsleep 3\nsettings put global disable_window_blurs 0\n' > /data/adb/service.d/99_native_blurs.sh; chmod 755 /data/adb/service.d/99_native_blurs.sh; fi"

    echo ""
    echo -e "${GREEN}=====================================================================${NC}"
    echo -e "${GREEN}[+] Native Window Blurs successfully ENABLED and configured!${NC}"
    echo -e "${GREEN}=====================================================================${NC}"
    echo ""
    read -p "Do you want to soft restart SurfaceFlinger & SystemUI now? (y/n): " rst
    if [[ "$rst" =~ ^[Yy]$ ]]; then
        echo -e "${YELLOW}[*] Restarting graphics compositor...${NC}"
        adb shell "pkill -f com.android.systemui; stop surfaceflinger; start surfaceflinger"
        echo -e "${GREEN}[+] UI restarted!${NC}"
    fi
    read -p "Press Enter to return to menu..."
}

disable_blurs() {
    if ! check_device; then return; fi
    echo ""
    echo -e "${YELLOW}[*] Reverting Window-Level Native Blurs to Stock (OFF)...${NC}"

    adb shell "rm -f /data/adb/post-fs-data.d/99_native_blurs.sh"
    adb shell "rm -f /data/adb/service.d/99_native_blurs.sh"
    adb shell "rm -rf /data/adb/modules/native_blurs"

    adb shell "which resetprop >/dev/null 2>&1 && resetprop ro.surface_flinger.supports_background_blur 0 || setprop ro.surface_flinger.supports_background_blur 0"
    adb shell "which resetprop >/dev/null 2>&1 && resetprop vendor.display.supports_background_blur 0 || setprop vendor.display.supports_background_blur 0"
    adb shell "which resetprop >/dev/null 2>&1 && resetprop ro.launcher.blur.appLaunch 0 || setprop ro.launcher.blur.appLaunch 0"
    adb shell "setprop persist.sys.sf.disable_blurs 1"
    adb shell "settings put global disable_window_blurs 1"

    echo ""
    echo -e "${GREEN}=====================================================================${NC}"
    echo -e "${GREEN}[+] Native Window Blurs successfully REVERTED to stock (Disabled)!${NC}"
    echo -e "${GREEN}=====================================================================${NC}"
    echo ""
    read -p "Do you want to soft restart SurfaceFlinger & SystemUI now? (y/n): " rst
    if [[ "$rst" =~ ^[Yy]$ ]]; then
        echo -e "${YELLOW}[*] Restarting graphics compositor...${NC}"
        adb shell "pkill -f com.android.systemui; stop surfaceflinger; start surfaceflinger"
        echo -e "${GREEN}[+] UI restarted!${NC}"
    fi
    read -p "Press Enter to return to menu..."
}

check_status() {
    if ! check_device; then return; fi
    echo ""
    echo -e "${CYAN}====================================================================="
    echo "  CURRENT WINDOW BLUR STATUS:"
    echo -e "=====================================================================${NC}"
    echo -n "[*] ro.surface_flinger.supports_background_blur: "
    adb shell getprop ro.surface_flinger.supports_background_blur
    echo -n "[*] vendor.display.supports_background_blur: "
    adb shell getprop vendor.display.supports_background_blur
    echo -n "[*] persist.sys.sf.disable_blurs: "
    adb shell getprop persist.sys.sf.disable_blurs
    echo -n "[*] ro.launcher.blur.appLaunch: "
    adb shell getprop ro.launcher.blur.appLaunch
    echo -n "[*] Global settings disable_window_blurs: "
    adb shell settings get global disable_window_blurs
    echo "[*] Persistence Script Check:"
    adb shell "if [ -f /data/adb/post-fs-data.d/99_native_blurs.sh ]; then echo '    Persistence: Active (/data/adb/post-fs-data.d/99_native_blurs.sh)'; else echo '    Persistence: Not Installed'; fi"
    echo -e "${CYAN}=====================================================================${NC}"
    echo ""
    read -p "Press Enter to return to menu..."
}

soft_restart() {
    if ! check_device; then return; fi
    echo ""
    echo -e "${YELLOW}[*] Restarting SurfaceFlinger and SystemUI...${NC}"
    adb shell "pkill -f com.android.systemui; stop surfaceflinger; start surfaceflinger"
    echo -e "${GREEN}[+] Done!${NC}"
    read -p "Press Enter to return to menu..."
}

full_reboot() {
    if ! check_device; then return; fi
    echo ""
    echo -e "${YELLOW}[*] Rebooting device...${NC}"
    adb reboot
    echo -e "${GREEN}[+] Device reboot initiated.${NC}"
    read -p "Press Enter to return to menu..."
}

while true; do
    print_header
    echo "====================================================================="
    echo "  OPTIONS:"
    echo "====================================================================="
    echo "  [1] Turn ON Window-Level Native Blurs (Enable & Persist)"
    echo "  [2] Turn OFF / Revert Window-Level Blurs (Restore Stock)"
    echo "  [3] Check Current Window Blurs Status"
    echo "  [4] Soft Restart (SurfaceFlinger & SystemUI)"
    echo "  [5] Full Device Reboot"
    echo "  [6] Exit"
    echo "====================================================================="
    read -p "Select an option [1-6]: " opt
    case "$opt" in
        1) enable_blurs ;;
        2) disable_blurs ;;
        3) check_status ;;
        4) soft_restart ;;
        5) full_reboot ;;
        6) echo "Exiting. Have a great day!"; exit 0 ;;
        *) echo "Invalid option"; sleep 1 ;;
    esac
done
