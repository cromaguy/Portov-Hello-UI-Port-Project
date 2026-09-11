import os
import zipfile

addon_dir = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', 'addons', 'window_blurs'))
output_paths = [
    os.path.abspath(os.path.join(os.path.dirname(__file__), '..', 'Portov_Window_Blurs_Addon.zip')),
    r'C:\Users\anjic\Desktop\Projects\Portov\Portov_Port_Retin\Portov_Window_Blurs_Addon.zip',
    r'C:\Users\anjic\Desktop\Projects\Portov\Portov_Window_Blurs_Addon.zip'
]

print("=" * 65)
print(" Moto G67 Power 5G - Window Blurs Add-on Packaging Tool")
print("=" * 65)

files_to_pack = [
    'manage_window_blurs.bat',
    'manage_window_blurs.sh',
    'README.txt'
]

for out_path in output_paths:
    print(f"[*] Packaging into: {out_path} ...")
    os.makedirs(os.path.dirname(out_path), exist_ok=True)
    with zipfile.ZipFile(out_path, 'w', compression=zipfile.ZIP_DEFLATED, compresslevel=9) as z:
        for fname in files_to_pack:
            fpath = os.path.join(addon_dir, fname)
            if os.path.exists(fpath):
                # Normalize line endings in .sh to LF
                if fname.endswith('.sh'):
                    with open(fpath, 'rb') as f:
                        data = f.read().replace(b'\r\n', b'\n')
                    z.writestr(fname, data)
                else:
                    z.write(fpath, fname)
                print(f"    [+] Added {fname}")
            else:
                print(f"    [!] Warning: {fpath} not found!")

    sz_kb = os.path.getsize(out_path) / 1024
    print(f"[+] Successfully created: {out_path} ({sz_kb:.2f} KB)\n")

print("[SUCCESS] All add-on ZIP archives built successfully!")
