=====================================================================
 Moto G67 Power 5G (portov) - Window-Level Native Blurs Add-on
 Android Version : 17
 Security Patch  : August 2025
 Update Channel  : RETIN
 Ported by Anjishnu
=====================================================================

ABOUT THIS ADD-ON:
This add-on allows you to enable or revert hardware-accelerated
window-level background blurs (behind the Quick Settings notification
shade, volume panel, power menu, dialogs, and launcher app launch)
on your Moto G67 Power 5G running the Android 17 Hello UI Port.

By default, Motorola disables blurs on mid-range devices to preserve
maximum battery life and peak scrolling smoothness. This add-on gives
you the choice to turn them on or revert back to stock solid/translucent
styling whenever you want!

PREREQUISITES:
1. Moto G67 Power 5G (portov) running Android 17 (Hello UI Port).
2. Developer Options -> USB Debugging turned ON.
3. Phone connected to your PC via USB cable.

HOW TO USE:
1. Windows:
   Double-click "manage_window_blurs.bat".
2. Linux / macOS:
   Open a terminal and run:
   chmod +x manage_window_blurs.sh
   ./manage_window_blurs.sh

OPTIONS:
[1] Turn ON Window-Level Native Blurs:
    Activates SurfaceFlinger background blur rendering, enables
    window blur flags, and installs persistent boot scripts so blurs
    remain active across reboots.
[2] Turn OFF / Revert Window-Level Blurs:
    Restores original stock behavior (removes persistence scripts
    and resets properties).
[3] Check Current Window Blurs Status:
    Displays current status of all blur properties and persistence.
[4] Soft Restart:
    Quickly restarts SurfaceFlinger & SystemUI to apply changes.
[5] Full Device Reboot:
    Reboots the phone completely.
=====================================================================
