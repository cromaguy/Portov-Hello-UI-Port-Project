# Project Hello UI — Moto G67 Power 5G (Portov)

[![Platform](https://img.shields.io/badge/Platform-Qualcomm%20SM7435-blue.svg)](https://www.qualcomm.com)
[![Android Version](https://img.shields.io/badge/Android-17%20(API%2037)-green.svg)](https://developer.android.com)
[![Device](https://img.shields.io/badge/Device-Moto%20G67%20Power%205G-orange.svg)](https://motorola.com)
[![License](https://img.shields.io/badge/License-Apache%202.0-lightgrey.svg)](LICENSE)

An experimental composite ROM port of Motorola's official **Android 17 / Hello UI** firmware (sourced from Moto G57 `mumba`) adapted and patched for the **Motorola Moto G67 Power 5G (`portov`)**.

**Ported and maintained by Anjishnu.**

---

## 📱 Device Specifications & Compatibility

| Feature | Target Device (`portov`) | Base Hardware Source |
| :--- | :--- | :--- |
| **Model** | Motorola moto g67 power 5G | XT2533-3 / XT2533-4 / XT2533-5 |
| **SoC** | Qualcomm Snapdragon 7s Gen 2 (`sm7435`) | Qualcomm `parrot` platform |
| **Display** | 6.7″ FHD+ 120Hz IPS LCD | Portov native RRO overlay |
| **Rear Camera** | 50 MP Main + 8 MP Ultrawide | Portov Camera5 pipeline |
| **Front Camera** | 32 MP In-Display | Portov Camera5 pipeline |
| **Battery** | 7,000 mAh Fast Charging | Portov power profile |
| **Biometrics** | Side-mounted Fingerprint Sensor | Portov side FPS overlay |

---

## 🚀 Key Features & Adaptations

1. **Native Portov RRO Overlays:**
   * Injected Portov's 12 official RRO overlays (`framework-res`, `SystemUI`, `SettingsMoto`, `SettingsProvider`, `Launcher3QuickStep`).
   * Configures 120Hz refresh rate toggle, punch-hole cutout padding, and accurate 7000 mAh battery capacity reporting.
2. **Motorola Camera (MotoCam) Official App Integration:**
   * Integrated Portov's genuine stock `MotCamera5` APK with all 55 hardware sensor tuning libraries.
   * Registered dual camera features (`com.motorola.camera5.portov` and `com.motorola.camera5.mumba`) to eliminate device mismatch warnings (*"Please use the official app for your device"*).
   * Fully functional 50MP main, 8MP ultrawide, and 32MP selfie camera pipeline.
3. **Moto System Updater Removed:**
   * Stripped `3c_ota` (`com.motorola.ccc.ota`) and associated background services from `system_ext` to prevent accidental OTA downloads from bricking the port.
4. **Android Verified Boot (AVB) & Verity Pre-Disabled:**
   * Patched `vbmeta.img` and `vbmeta_system.img` with AVB flags `0x00000003` (verity & verification disabled), avoiding `fastboot` `--disable-verity` buffer crashes (`AVB_MAGIC at offset: 0`).
5. **Carrier & SKU Alignment:**
   * Injected `hardware.sku.XT2533-5.prop` and `carrier.india.prop` for VoLTE/VoWiFi (IMS) reliability.
6. **System Architecture Alignment:**
   * Aligned system build properties and device targeting for `moto g67 power 5G` (`portov`).
   * Maintained exact SELinux file contexts, dynamic partition sizing, and filesystem integrity.

---

## 🛠️ How to Build from Source Firmware

To build the flashable packages yourself:

### 1. Prerequisites
* Python 3.10+
* `liblp` Python library (`pip install liblp`)
* `erofs-utils` (`extract.erofs` and `mkfs.erofs`)
* Official stock firmware zips:
  * Portov Base: `XT2533-3_PORTOV_RETIN_...zip`
  * Mumba Port: `XT2537-5_MUMBA_RETIN_17_...zip`

### 2. Extract and Unpack
```bash
python scripts/sparse_extractor.py mumba
python scripts/sparse_extractor.py portov
```

### 3. Patch Overlays & Properties
```bash
python scripts/patch_portov.py
```

### 4. Build Window-Level Blurs Add-on ZIP
```bash
python scripts/make_blur_addon_zip.py
```

---

## 📥 Downloads

| Package Name | Target Interface | File Size | Download Link |
| :--- | :--- | :--- | :--- |
| **Port Package (Fastboot)** | PC / Fastboot & FastbootD | ~5.7 GB | [Pixeldrain](https://pixeldrain.com/u/3tD6dd9Z) |
| **SELinux Permissive Flasher** | PC / Fastboot (`flash_permissive_boot`) | 96 MB | Included in Port Package (`boot_permissive.img`) |
| **Window-Level Native Blurs Add-on** | ADB / PC (Windows & Linux) | ~4.2 KB | [Pixeldrain](https://pixeldrain.com/u/uCDVaVy8) |

---

## 📦 Package Architecture & Partition Breakdown

| Partition File | Size | Classification | Technical Description |
| :--- | :--- | :--- | :--- |
| `boot_permissive.img` | 96 MB | Stock Portov A16 (Patched) | Portov Stock GKI 6.6.118 Kernel with `androidboot.selinux=permissive enforcing=0` cmdline |
| `boot.img` | 96 MB | Stock Portov A16 | Stock Portov GKI 6.6.118 Linux Kernel (enforcing backup) |
| `init_boot.img` | 8 MB | Stock Portov A16 | 100% Stock Portov A16 GKI Ramdisk |
| `vendor_boot.img` | 96 MB | Stock Portov A16 | 100% Stock Portov A16 Recovery Ramdisk, Kernel 6.6.118 Drivers & Device Tree |
| `dtbo.img` | 23 MB | Stock Portov A16 | 100% Stock Portov A16 Device Tree Blob Overlay |
| `recovery.img` | 128 MB | Stock Portov A16 | 100% Stock Portov A16 Recovery Partition & FastbootD daemon |
| `vbmeta.img` | 8 KB | Portov A16 (AVB Patched) | Stock Portov AVB (ARB 12) with flags `0x00000003` (verity & verification disabled) |
| `vbmeta_system.img` | 4 KB | Portov A16 (AVB Patched) | Stock Portov AVB System (ARB 12) with flags `0x00000003` |
| `vendor.img` | 722 MB | Stock Portov A16 | 100% Stock Portov A16 hardware HALs (Audio, Camera, Sensors, Display) |
| `vendor_dlkm.img` | 21.5 MB | Stock Portov A16 | 100% Stock Portov SM7435 kernel driver modules (Kernel 6.6.118) |
| `system_dlkm.img` | 7.3 MB | Stock Portov A16 | 100% Stock Portov GKI 6.6.118 system modules |
| `system.img` | 693 MB | Repacked for Port | Android 17 AOSP Framework & Core Services |
| `system_ext.img` | 549 MB | Repacked for Port | Motorola Hello UI System Extensions (OTA updater stripped) |
| `product.img` | 3.55 GB | Repacked for Port | Hello UI 17 Apps, Themes, and native Portov Camera5 |

---

## ⚡ Flashing Instructions

> [!WARNING]
> **Prerequisites:**
> 1. Your bootloader must be **UNLOCKED** (`fastboot oem unlock`).
> 2. Perform a **Format Data / Factory Reset** before booting into Android 17.
> 3. Keep a backup of your stock firmware handy via Motorola Rescue and Smart Assistant (RSA).
> 4. **NEVER lock your bootloader (`fastboot oem lock`)** while running a custom/ported ROM.

> [!IMPORTANT]
> **Key Bringup Finding — Dual-Slot Sync & Permissive Boot:**  
> Flashing the boot/recovery/vbmeta components to **BOTH slots (`_a` and `_b`)** and setting `--set-active=a` is strictly required on Motorola A/B devices to prevent rollback recovery loops. `boot_permissive.img` is flashed during initial setup to allow the Android 17 framework to communicate with Android 15 vendor policies seamlessly.

### Method A: Fastboot / FastbootD (PC)
1. Download and extract **HelloUI_A17_Portov_PackageByAnji**.
2. Put phone into **Bootloader mode** (Hold `Power + Volume Down`) and connect to PC.
3. **Windows:** Double-click `flash_portov_a17.bat`.  
   **Linux/macOS:** Run `chmod +x flash_portov_a17.sh && ./flash_portov_a17.sh`.

#### Manual Fastboot Execution Reference:
```cmd
:: Step 1: Boot, Recovery, and AVB
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

:: Step 2: Reboot to FastbootD
fastboot reboot fastboot

:: Step 3: Flash Dynamic Partitions
fastboot flash system system.img
fastboot flash system_ext system_ext.img
fastboot flash product product.img
fastboot flash vendor vendor.img
fastboot flash vendor_dlkm vendor_dlkm.img
fastboot flash system_dlkm system_dlkm.img

:: Step 4: Clean Wipe & Reboot
fastboot erase userdata
fastboot erase metadata
fastboot reboot
```
---

### 🛡️ SELinux Permissive Tool
If you ever re-flash a stock enforcing boot image and need to re-enable permissive mode:
* **Windows:** Run `flash_permissive_boot.bat` in Bootloader mode.
* **Linux / macOS:** Run `chmod +x flash_permissive_boot.sh && ./flash_permissive_boot.sh`.

---

### 🔮 Window-Level Native Blurs Add-on
Motorola disables hardware-accelerated window and background blurs on G-series devices by default to maximize battery efficiency and sustain fluid 120 Hz animations.

This repository includes a dedicated modular add-on allowing users to toggle and persist native hardware-accelerated Gaussian window blurs (behind the Quick Settings shade, volume slider, power menu, dialogs, and launcher app opening animations):
* **Location:** `addons/window_blurs/` or `Portov_Window_Blurs_Addon.zip`
* **Windows:** Double-click `manage_window_blurs.bat`
* **Linux / macOS:** Run `chmod +x manage_window_blurs.sh && ./manage_window_blurs.sh`
* **Features:**
  * **Option [1]:** Turn ON native window blurs with automated boot persistence (`post-fs-data.d` / `service.d` / Magisk systemless module).
  * **Option [2]:** Turn OFF / Revert back to stock solid/translucent Motorola styling anytime.
  * **Option [3]:** Live status inspector for all blur properties and persistence scripts.

---

## 🤝 Credits & Acknowledgements

* **Port Developer:** Anjishnu
* **Hardware Testing & Verification:** [Quartz750](https://github.com/Quartz750)
* **Upstream Tree Maintainers:** `parrot-66-dev`, `4mede`
* **Firmware Base:** Motorola Mobility LLC
* **Tools:** `liblp` (SebaUbuntu), `erofs-tools` (sekaiacg)
* Read [CREDITS.md](CREDITS.md) for full attribution.
