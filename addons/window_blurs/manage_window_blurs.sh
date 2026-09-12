#!/usr/bin/env bash
#
# Moto G67 Power 5G (portov) - Window Blurs Add-on Manager (Linux/macOS)
# Ported by Anjishnu
#

show_menu() {
    clear
    echo "+------------------------------------------------------------------+"
    echo "|                    Moto G67 Power 5G (portov)                    |"
    echo "|             Window-Level Native Blurs Manager Add-on             |"
    echo "+------------------------------------------------------------------+"
    echo "|  Android Version : 17                                            |"
    echo "|  Base Firmware   : Android 16 (Universal Global / RETIN cid50)   |"
    echo "|  Ported by       : Anjishnu                                      |"
    echo "+------------------------------------------------------------------+"
    echo ""
    echo "====================================================================="
    echo "  OPTIONS:"
    echo "====================================================================="
    echo "  [1] Turn ON Window-Level Native Blurs (Active)"
    echo "  [2] Turn OFF Window-Level Native Blurs (Solid / Power Save)"
    echo "  [3] Check Current Window Blurs Status"
    echo "  [4] Soft Restart (SurfaceFlinger & SystemUI)"
    echo "  [5] Full Device Reboot"
    echo "  [6] Exit"
    echo "====================================================================="
    read -p "Select an option [1-6]: " opt
}

check_device() {
    echo ""
    echo "[*] Checking ADB connection..."
    if ! adb devices | grep -v "^List" | grep -q "[a-zA-Z0-9]"; then
        echo "[!] No device detected via ADB!"
        echo "[*] Please make sure:"
        echo "    1. Phone is booted and connected via USB."
        echo "    2. USB Debugging is ENABLED in Developer Options."
        echo "    3. You have authorized this PC on the phone prompt."
        echo ""
        read -p "Press Enter to return to menu..."
        return 1
    fi
    adb wait-for-device
    return 0
}

enable_blur() {
    check_device || return
    echo ""
    echo "[*] Enabling Window-Level Native Blurs..."
    adb shell "settings put global disable_window_blurs 0"
    adb shell "setprop persist.sys.sf.disable_blurs 0"
    adb shell "su -c 'which resetprop >/dev/null 2>&1 && resetprop ro.surface_flinger.supports_background_blur 1 && resetprop vendor.display.supports_background_blur 1 && resetprop ro.launcher.blur.appLaunch 1' >/dev/null 2>&1"
    
    echo ""
    echo "====================================================================="
    echo "[+] Native Window Blurs successfully ENABLED!"
    echo "====================================================================="
    echo ""
    read -p "Do you want to soft restart SurfaceFlinger & SystemUI now? (y/n): " rst
    if [[ "$rst" =~ ^[Yy]$ ]]; then
        echo "[*] Restarting graphics compositor..."
        adb shell "su -c 'stop surfaceflinger; start surfaceflinger' 2>/dev/null || pkill -f com.android.systemui"
        echo "[+] UI restart triggered!"
    fi
    read -p "Press Enter to continue..."
}

disable_blur() {
    check_device || return
    echo ""
    echo "[*] Disabling Window-Level Native Blurs (Solid / Power Save mode)..."
    adb shell "settings put global disable_window_blurs 1"
    adb shell "setprop persist.sys.sf.disable_blurs 1"
    adb shell "su -c 'which resetprop >/dev/null 2>&1 && resetprop ro.launcher.blur.appLaunch 0' >/dev/null 2>&1"
    
    echo ""
    echo "====================================================================="
    echo "[+] Native Window Blurs successfully DISABLED (Solid / Stock styling)!"
    echo "====================================================================="
    echo ""
    read -p "Do you want to soft restart SurfaceFlinger & SystemUI now? (y/n): " rst
    if [[ "$rst" =~ ^[Yy]$ ]]; then
        echo "[*] Restarting graphics compositor..."
        adb shell "su -c 'stop surfaceflinger; start surfaceflinger' 2>/dev/null || pkill -f com.android.systemui"
        echo "[+] UI restart triggered!"
    fi
    read -p "Press Enter to continue..."
}

check_status() {
    check_device || return
    echo ""
    echo "====================================================================="
    echo "  CURRENT WINDOW BLUR STATUS:"
    echo "====================================================================="
    echo -n "[*] Hardware Capability (ro.surface_flinger.supports_background_blur): "
    adb shell getprop ro.surface_flinger.supports_background_blur
    echo -n "[*] Global Window Blurs Setting (0=Active, 1=Disabled): "
    adb shell settings get global disable_window_blurs
    echo -n "[*] SurfaceFlinger Blur Persistence (0=Active, 1=Disabled): "
    adb shell getprop persist.sys.sf.disable_blurs
    echo -n "[*] Launcher App Launch Blur (ro.launcher.blur.appLaunch): "
    adb shell getprop ro.launcher.blur.appLaunch
    echo "====================================================================="
    echo ""
    read -p "Press Enter to continue..."
}

soft_restart() {
    check_device || return
    echo ""
    echo "[*] Restarting SurfaceFlinger and SystemUI..."
    adb shell "su -c 'stop surfaceflinger; start surfaceflinger' 2>/dev/null || pkill -f com.android.systemui"
    echo "[+] Done!"
    read -p "Press Enter to continue..."
}

full_reboot() {
    check_device || return
    echo ""
    echo "[*] Rebooting device..."
    adb reboot
    echo "[+] Device reboot initiated."
    read -p "Press Enter to continue..."
}

while true; do
    show_menu
    case "$opt" in
        1) enable_blur ;;
        2) disable_blur ;;
        3) check_status ;;
        4) soft_restart ;;
        5) full_reboot ;;
        6) echo "Exiting. Have a great day!"; exit 0 ;;
        *) echo "[!] Invalid selection. Please choose 1 to 6."; sleep 2 ;;
    esac
done
