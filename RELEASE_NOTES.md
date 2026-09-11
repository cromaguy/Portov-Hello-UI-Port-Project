# 🚀 Moto G67 Power 5G (portov) — Android 17 / Hello UI Port v1.0

[![Release](https://img.shields.io/badge/Release-v1.0--Alpha-blue.svg)](https://github.com/)
[![Android Version](https://img.shields.io/badge/Android-17%20(API%2037)-green.svg)](https://developer.android.com)
[![Target Device](https://img.shields.io/badge/Device-Moto%20G67%20Power%205G%20(portov)-orange.svg)](https://motorola.com)
[![Status](https://img.shields.io/badge/Status-Booting%20%26%20Working-brightgreen.svg)](https://github.com/)

An experimental composite ROM port of Motorola's official **Android 17 / Hello UI** firmware (`A171WAAH.31-9-4`) sourced from Moto G57 (`mumba`) and tailored specifically for the **Motorola Moto G67 Power 5G (`portov`)**.

---

## 🌟 What's New & Included

### 1. Android 17 & Hello UI Experience
* Full Motorola **Hello UI 17** system suite: updated Moto Launcher, new clock/weather widgets, lockscreen customizations, and animations.
* Sourced from official Qualcomm `parrot` (SM7435/SM6450) Android 17 firmware.

### 2. Hardware Adaptations & Overlays for Portov
* **120Hz Display & Punch-Hole Layout:** Swapped Mumba's display overlays with Portov's native `framework-res` and `SystemUI` RRO overlays.
* **Side-Mounted Fingerprint Sensor:** Biometric sensor coordinates and settings adapted for Portov's physical capacitive scanner.
* **7,000 mAh Battery Profile:** System power profiles updated to match Portov's high-capacity battery.
* **Official Motorola Camera 5 Integration:** Integrated Portov's stock `MotCamera5` APK containing all 55 hardware sensor libraries and registered dual features (`com.motorola.camera5.portov` & `com.motorola.camera5.mumba`), completely resolving the device-mismatch error (*"Please use the official app for your device"*).
* **Moto System Updater Removed:** Stripped `3c_ota` (`com.motorola.ccc.ota`) from `system_ext` to avoid accidental OTA bricking on the port.
* **AVB & Verity Pre-Disabled:** Patched `vbmeta.img` and `vbmeta_system.img` with flags `0x00000003` to prevent `fastboot` `--disable-verity` crashes (`AVB_MAGIC at offset: 0`).
* **Carrier & SKU Optimization:** India carrier (`carrier.india.prop`) and Portov hardware SKU (`hardware.sku.XT2533-5.prop`) configurations injected.

### 3. System Architecture Alignment
* Aligned device identification target properties to `moto g67 power 5G` (`portov`).
* Built-in SELinux permissive boot image (`boot_permissive.img`) to bridge Android 17 framework services with Android 15 vendor policies seamlessly.
* Configured dynamic partition sizes and logical block mapping for clean fastbootd flashing.

---

## 📅 Development & Release Timeline

| Milestone | Phase | Details | Status |
| :--- | :--- | :--- | :--- |
| **M1: Research & Platform Bringup** | Exploration | Analyzed SM7435 parrot base, GKI 6.6 kernel, and official Mumba A17 firmware | ✅ Complete |
| **M2: Chunk-Aware De-Sparsing** | Extraction | Unspanned 8GB sparse super image into dynamic partitions | ✅ Complete |
| **M3: Hardware Overlay Migration** | Adaptation | Injected 12 native Portov overlays, 7000 mAh profile & MotoCam sensor configuration | ✅ Complete |
| **M4: EROFS Rebuild** | Integration | Repacked dynamic partitions with lz4hc compression and SELinux contexts | ✅ Complete |
| **M5: Package Assembly** | Delivery | Built Fastboot & FastbootD flasher suite, permissive boot patcher & Window Blurs Add-on | ✅ Complete |
| **M6: v1.0 Alpha Release** | Milestone | Published documentation, flasher packages, and open-source toolkit | 🚀 Current |
| **M7: Hardware Subsystem Validation** | Testing | Verified booting & operational on physical hardware | ✅ Verified |
| **M8: SELinux Enforcing** | Security | Resolve sepolicy rules to transition from permissive to enforcing | ⏳ Upcoming |

---

## 📥 Downloads

| Package Name | Target Interface | File Size | Download Link |
| :--- | :--- | :--- | :--- |
| **Port Package (Fastboot)** | PC / Fastboot & FastbootD | ~5.7 GB | [Google Drive](https://drive.google.com/file/d/1i6MvSgaoAqQNo3DilyvF5gp3e4DmTPqi/view?usp=sharing) |
| **SELinux Permissive Flasher** | PC / Fastboot (`flash_permissive_boot`) | 96 MB | Included in Port Package (`boot_permissive.img`) |
| **Window-Level Native Blurs Add-on** | ADB / PC (Windows & Linux) | ~5.2 KB | Included in repository (`addons/window_blurs`) |

---

## ⚠️ Important Prerequisites & Safety Rules

> [!CAUTION]
> 1. **Unlocked Bootloader Required:** Your device must have an unlocked bootloader (`fastboot oem unlock`).
> 2. **Clean Flash / Format Data Mandatory:** You **must format data / wipe userdata** (type `yes` in recovery) before booting. Dirty flashing over stock will cause a bootloop due to encryption key mismatches.
> 3. **⚠️ NEVER Relock Bootloader:** Do NOT execute `fastboot oem lock` or `fastboot flashing lock` while running custom/ported software.
> 4. **Safety Net:** Keep Motorola Rescue and Smart Assistant (RSA) installed on your PC in case you ever need to restore official factory stock.

---

## 🛠️ Installation Instructions

> [!IMPORTANT]
> **Key Bringup Finding — Stable FastbootD & Hardware Drivers:**  
> When coming from custom ROMs or third-party recoveries, flashing the stock Portov base images (`boot`, `init_boot`, `vendor_boot`, `dtbo`, `recovery`, `vbmeta`, `vbmeta_system`) to **BOTH slots (`_a` and `_b`)** is strictly required to initialize the official Qualcomm SM7435 hardware drivers and stock recovery kernel. This enables the device to transition reliably into a stable **FastbootD** environment to flash the dynamic partitions without bootloops.

### Method 1: Fastboot & FastbootD (PC) — Verified Working Method
1. Download and extract the **Port Package** on your PC.
2. Put phone into **Bootloader mode** (Hold `Power + Volume Down`) and connect to PC.
3. Open CMD/PowerShell in the package folder and run:
   ```cmd
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

   fastboot reboot fastboot
   ```
4. Once the phone screen displays **FASTBOOTD**, flash the dynamic partitions:
   ```cmd
   fastboot flash vendor vendor.img
   fastboot flash vendor_dlkm vendor_dlkm.img
   fastboot flash system_dlkm system_dlkm.img
   fastboot flash system system.img
   fastboot flash system_ext system_ext.img
   fastboot flash product product.img

   fastboot erase userdata
   fastboot erase metadata
   fastboot reboot
   ```
   *(Or double-click `flash_portov_a17.bat` to run automatically).*

---

### 🛡️ Troubleshooting: SELinux Permissive Boot Flasher
If your device hangs on the Motorola boot logo or bootloops due to SELinux policy denials:
* **Windows:** Put phone in bootloader mode and run `flash_permissive_boot.bat`.
* **Linux / macOS:** Put phone in bootloader mode and run `chmod +x flash_permissive_boot.sh && ./flash_permissive_boot.sh`.

---

## 🤝 Credits & Acknowledgements

* **Port Developer & Maintainer:** Anjishnu
* **Hardware Testing & Verification:** [Quartz750](https://github.com/Quartz750)
* **Device & Vendor Trees:** `parrot-66-dev`, `4mede`
* **Stock Firmware & Hello UI Apps:** Motorola Mobility LLC
* **Upstream Projects:** The LineageOS Project, Android Open Source Project (AOSP)
* **Tooling:** `erofs-utils` (sekaiacg), `liblp` (SebaUbuntu)
