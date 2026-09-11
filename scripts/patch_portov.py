import os
import shutil
import re

product_dir = r'C:\Users\anjic\Desktop\Projects\Portov\port_workspace\product_unpacked\product_a'
product_cfg_dir = r'C:\Users\anjic\Desktop\Projects\Portov\port_workspace\product_unpacked\config'
portov_product_dir = r'C:\Users\anjic\Desktop\Projects\Portov\port_workspace\portov_product_unpacked\product_a'

system_dir = r'C:\Users\anjic\Desktop\Projects\Portov\port_workspace\system_unpacked\system_a'
system_cfg_dir = r'C:\Users\anjic\Desktop\Projects\Portov\port_workspace\system_unpacked\config'

system_ext_dir = r'C:\Users\anjic\Desktop\Projects\Portov\port_workspace\system_ext_unpacked\system_ext_a'
system_ext_cfg_dir = r'C:\Users\anjic\Desktop\Projects\Portov\port_workspace\system_ext_unpacked\config'

print("=" * 60)
print("[*] Starting Portov Android 17 ROM Patching...")
print("=" * 60)

# -------------------------------------------------------------
# 1. RRO Overlays Replacement in Product
# -------------------------------------------------------------
print("\n[*] 1. Patching RRO Overlays...")
mumba_overlays_to_remove = [
    'framework-res__mumba_g__auto_generated_rro_product.apk',
    'SystemUI__mumba_g__auto_generated_rro_product.apk',
    'SettingsProvider__mumba_g__auto_generated_rro_product.apk',
    'MotorolaSettingsProvider__mumba_g__auto_generated_rro_product.apk',
    'MotoCoreSettingsExtMumbaOverlay.apk',
    'MotoLauncherAnimationOverlay40Mumba.apk',
    'Launcher3QuickStep__mumba_g__auto_generated_rro_product.apk',
    'LauncherConfigOverlayMumbaiRetid.apk',
    'AccessibilityMenu__mumba_g__auto_generated_rro_product.apk',
    'SetupWizardExt__mumba_g__auto_generated_rro_product.apk',
    'framework-rro-mumba-xt2537-3.apk',
    'framework-rro-mumba-xt2537-5.apk',
    'framework-rro-mumbap.apk',
    'wifi-overlay-mumbap.apk'
]

product_overlay_dir = os.path.join(product_dir, 'overlay')
for ov in mumba_overlays_to_remove:
    p = os.path.join(product_overlay_dir, ov)
    if os.path.exists(p):
        os.remove(p)
        print(f"    [-] Removed Mumba overlay: {ov}")

portov_overlays_to_copy = [
    'framework-res__portov_g__auto_generated_rro_product.apk',
    'SystemUI__portov_g__auto_generated_rro_product.apk',
    'SettingsMoto__portov_g__auto_generated_rro_product.apk',
    'SettingsProvider__portov_g__auto_generated_rro_product.apk',
    'MotorolaSettingsProvider__portov_g__auto_generated_rro_product.apk',
    'MotoCoreSettingsExtPortovOverlay.apk',
    'MotoLauncherAnimationOverlay40Portov.apk',
    'Launcher3QuickStep__portov_g__auto_generated_rro_product.apk',
    'LauncherConfigOverlayPortovRetid.apk',
    'AccessibilityMenu__portov_g__auto_generated_rro_product.apk',
    'SetupWizardExt__portov_g__auto_generated_rro_product.apk',
    'MotoSystemUIOverlaySysbar.apk'
]

portov_overlay_dir = os.path.join(portov_product_dir, 'overlay')
for ov in portov_overlays_to_copy:
    src = os.path.join(portov_overlay_dir, ov)
    dst = os.path.join(product_overlay_dir, ov)
    if os.path.exists(src):
        shutil.copy2(src, dst)
        print(f"    [+] Injected Portov overlay: {ov}")

# -------------------------------------------------------------
# 2. Camera Feature & Hardware Permissions
# -------------------------------------------------------------
print("\n[*] 2. Patching Camera & System Permissions...")
perm_dir = os.path.join(product_dir, 'etc', 'permissions')
portov_perm_dir = os.path.join(portov_product_dir, 'etc', 'permissions')

# Remove Mumba camera5 permission
m_cam = os.path.join(perm_dir, 'com.motorola.camera5.mumba.xml')
if os.path.exists(m_cam):
    os.remove(m_cam)
    print("    [-] Removed com.motorola.camera5.mumba.xml")

# Add Portov camera5 permission & features
perms_to_copy = [
    'com.motorola.camera5.portov.xml',
    'feature-com.motorola.aicore.xml',
    'feature-com.motorola.spaces.xml',
    'privapp-permissions-com.motorola.aicore.xml',
    'privapp-permissions-com.motorola.spaces.xml',
    'android.hardware.telephony.gsm.prebuilt.product.xml',
    'android.hardware.telephony.satellite.prebuilt.product.xml'
]
for p in perms_to_copy:
    src = os.path.join(portov_perm_dir, p)
    dst = os.path.join(perm_dir, p)
    if os.path.exists(src):
        shutil.copy2(src, dst)
        print(f"    [+] Injected Portov permission: {p}")

# -------------------------------------------------------------
# 3. Carrier & Hardware Props
# -------------------------------------------------------------
print("\n[*] 3. Injecting Portov Carrier & SKU props...")
props_dir = os.path.join(product_dir, 'etc', 'motorola', 'props')
portov_props_dir = os.path.join(portov_product_dir, 'etc', 'motorola', 'props')
if os.path.exists(props_dir) and os.path.exists(portov_props_dir):
    for prop in ['carrier.india.prop', 'hardware.sku.XT2533-5.prop', 'carrier.in.common.prop']:
        src = os.path.join(portov_props_dir, prop)
        dst = os.path.join(props_dir, prop)
        if os.path.exists(src):
            shutil.copy2(src, dst)
            print(f"    [+] Injected {prop}")

# -------------------------------------------------------------
# 4. Patching Product build.prop with Portov Branding & Anjishnu Credit
# -------------------------------------------------------------
print("\n[*] 4. Patching product/etc/build.prop...")
prod_bp = os.path.join(product_dir, 'etc', 'build.prop')

with open(prod_bp, 'r', encoding='utf-8', errors='replace') as f:
    lines = f.readlines()

new_lines = []
for line in lines:
    if line.startswith('ro.product.product.model='):
        new_lines.append('ro.product.product.model=moto g67 power 5G\n')
    elif line.startswith('ro.product.product.name='):
        new_lines.append('ro.product.product.name=portov_g\n')
    elif line.startswith('ro.product.device.canonical='):
        new_lines.append('ro.product.device.canonical=portov\n')
    elif line.startswith('ro.product.name.canonical='):
        new_lines.append('ro.product.name.canonical=portov_g\n')
    elif line.startswith('ro.product.soc.mkt_name='):
        new_lines.append('ro.product.soc.mkt_name=Qualcomm Snapdragon 7s Gen 2\n')
    else:
        new_lines.append(line)

# Add custom build properties for About Phone visibility
branding_props = '''
# -------------------------------------------------------------
# Portov Custom ROM Properties - Ported by Anjishnu
# -------------------------------------------------------------
ro.build.display.id=A171WAAH.31-9-4 (Ported by Anjishnu)
ro.build.user=Anjishnu
ro.build.host=Anjishnu-PC
ro.build.version.incremental=Ported_by_Anjishnu
ro.modversion=Android 17 - Ported by Anjishnu
ro.custom.porter=Anjishnu
ro.product.model=moto g67 power 5G
ro.product.device=portov
ro.product.name=portov_g
'''
new_lines.append(branding_props)

with open(prod_bp, 'w', encoding='utf-8') as f:
    f.writelines(new_lines)
print("    [+] Updated product/etc/build.prop with Portov properties and 'Ported by Anjishnu' branding.")

# -------------------------------------------------------------
# 5. Patching System build.prop
# -------------------------------------------------------------
print("\n[*] 5. Patching system/system/build.prop...")
# Check system build.prop location
sys_bp = os.path.join(system_dir, 'system', 'build.prop')
if not os.path.exists(sys_bp):
    sys_bp = os.path.join(system_dir, 'build.prop')

if os.path.exists(sys_bp):
    with open(sys_bp, 'r', encoding='utf-8', errors='replace') as f:
        sys_lines = f.readlines()
        
    new_sys_lines = []
    for line in sys_lines:
        if line.startswith('ro.product.system.model='):
            new_sys_lines.append('ro.product.system.model=moto g67 power 5G\n')
        elif line.startswith('ro.product.system.device='):
            new_sys_lines.append('ro.product.system.device=portov\n')
        elif line.startswith('ro.product.system.name='):
            new_sys_lines.append('ro.product.system.name=portov_g\n')
        elif line.startswith('ro.build.display.id='):
            new_sys_lines.append('ro.build.display.id=A171WAAH.31-9-4 (Ported by Anjishnu)\n')
        elif line.startswith('ro.build.user='):
            new_sys_lines.append('ro.build.user=Anjishnu\n')
        else:
            new_sys_lines.append(line)
            
    new_sys_lines.append('''
ro.build.display.id=A171WAAH.31-9-4 (Ported by Anjishnu)
ro.build.version.display=Android 17 - Ported by Anjishnu
ro.build.user=Anjishnu
ro.modversion=Android 17 - Ported by Anjishnu
ro.product.model=moto g67 power 5G
ro.product.device=portov
''')
    with open(sys_bp, 'w', encoding='utf-8') as f:
        f.writelines(new_sys_lines)
    print("    [+] Updated system build.prop with Portov properties and 'Ported by Anjishnu' branding.")

# -------------------------------------------------------------
# 6. Patching System_Ext build.prop
# -------------------------------------------------------------
print("\n[*] 6. Patching system_ext/etc/build.prop...")
sysext_bp = os.path.join(system_ext_dir, 'etc', 'build.prop')
if os.path.exists(sysext_bp):
    with open(sysext_bp, 'r', encoding='utf-8', errors='replace') as f:
        sysext_lines = f.readlines()
        
    new_sysext_lines = []
    for line in sysext_lines:
        if line.startswith('ro.product.system_ext.model='):
            new_sysext_lines.append('ro.product.system_ext.model=moto g67 power 5G\n')
        elif line.startswith('ro.product.system_ext.device='):
            new_sysext_lines.append('ro.product.system_ext.device=portov\n')
        elif line.startswith('ro.product.system_ext.name='):
            new_sysext_lines.append('ro.product.system_ext.name=portov_g\n')
        else:
            new_sysext_lines.append(line)
            
    new_sysext_lines.append('''
ro.product.system_ext.model=moto g67 power 5G
ro.product.system_ext.device=portov
ro.product.system_ext.name=portov_g
ro.build.display.id=A171WAAH.31-9-4 (Ported by Anjishnu)
ro.build.user=Anjishnu
''')
    with open(sysext_bp, 'w', encoding='utf-8') as f:
        f.writelines(new_sysext_lines)
    print("    [+] Updated system_ext/etc/build.prop.")

# -------------------------------------------------------------
# 7. Update fs_config and file_contexts for Product
# -------------------------------------------------------------
print("\n[*] 7. Updating product fs_config & file_contexts for repacking...")
fs_cfg_path = os.path.join(product_cfg_dir, 'product_a_fs_config')
fc_path = os.path.join(product_cfg_dir, 'product_a_file_contexts')

if os.path.exists(fs_cfg_path):
    with open(fs_cfg_path, 'r', encoding='utf-8', errors='replace') as f:
        existing_fs = f.read()
    
    # Add rules for newly added files
    new_fs_entries = []
    for root, dirs, files in os.walk(product_dir):
        for fname in files:
            rel = os.path.relpath(os.path.join(root, fname), product_dir).replace('\\', '/')
            line_pattern = f"{rel} "
            if line_pattern not in existing_fs:
                new_fs_entries.append(f"{rel} 0 0 644\n")
                
    if new_fs_entries:
        with open(fs_cfg_path, 'a', encoding='utf-8') as f:
            f.writelines(new_fs_entries)
        print(f"    [+] Added {len(new_fs_entries)} new fs_config entries.")

if os.path.exists(fc_path):
    with open(fc_path, 'r', encoding='utf-8', errors='replace') as f:
        existing_fc = f.read()
    
    new_fc_entries = []
    for root, dirs, files in os.walk(product_dir):
        for fname in files:
            rel = os.path.relpath(os.path.join(root, fname), product_dir).replace('\\', '/')
            pattern = f"/{rel}"
            if pattern not in existing_fc:
                new_fc_entries.append(f"/{rel} u:object_r:system_file:s0\n")
                
    if new_fc_entries:
        with open(fc_path, 'a', encoding='utf-8') as f:
            f.writelines(new_fc_entries)
        print(f"    [+] Added {len(new_fc_entries)} new file_contexts entries.")

print("\n[SUCCESS] All Portov adaptations, RRO overlays, permissions, and branding successfully patched!")
