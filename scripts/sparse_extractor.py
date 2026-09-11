import os
import sys
import zipfile
import struct
import shutil
from pathlib import Path

sys.stdout.reconfigure(line_buffering=True)

from liblp import ReadMetadata, GetPartitionName, LP_SECTOR_SIZE
from liblp.partition_tools.lpunpack import ImageExtractor

def desparse_chunks(zip_path, chunk_prefix, output_raw_path):
    print(f"[*] Opening {zip_path} ...", flush=True)
    with zipfile.ZipFile(zip_path, 'r') as z:
        chunk_files = []
        i = 0
        while True:
            name = f"{chunk_prefix}.{i}"
            if name in z.namelist():
                chunk_files.append(name)
                i += 1
            else:
                break
        
        if not chunk_files:
            raise FileNotFoundError(f"No sparse chunks found with prefix {chunk_prefix} in {zip_path}")
            
        print(f"[*] Found {len(chunk_files)} sparse chunks: {chunk_files[0]} ... {chunk_files[-1]}", flush=True)
        
        # Read header of first chunk to determine total size
        with z.open(chunk_files[0], 'r') as cf0:
            h0 = cf0.read(28)
            magic, major, minor, fsz, csz, blk_sz, tblks, tchunks, csum = struct.unpack('<I4H4I', h0)
            expected_total_bytes = tblks * blk_sz
            print(f"[*] Target raw image size: {expected_total_bytes / (1024*1024):.2f} MB ({tblks} blocks)", flush=True)

        with open(output_raw_path, 'wb') as out_f:
            out_f.truncate(expected_total_bytes)
            
            for idx, chunk_name in enumerate(chunk_files):
                print(f"    [{idx+1}/{len(chunk_files)}] Processing {chunk_name} ...", flush=True)
                with z.open(chunk_name, 'r') as cf:
                    header = cf.read(28)
                    magic, major, minor, fsz, csz, blk_sz, tblks, tchunks, csum = struct.unpack('<I4H4I', header)
                    cur_blk = 0
                    for _ in range(tchunks):
                        chunk_header = cf.read(12)
                        ctype, res, cblocks, ctotalsz = struct.unpack('<2H2I', chunk_header)
                        data_sz = ctotalsz - 12
                        
                        if ctype == 0xCAC1: # RAW
                            out_f.seek(cur_blk * blk_sz)
                            bytes_left = data_sz
                            while bytes_left > 0:
                                read_sz = min(bytes_left, 4 * 1024 * 1024)
                                buf = cf.read(read_sz)
                                out_f.write(buf)
                                bytes_left -= len(buf)
                        elif ctype == 0xCAC2: # FILL
                            fill_val = cf.read(4)
                            if fill_val != b'\x00\x00\x00\x00':
                                out_f.seek(cur_blk * blk_sz)
                                fill_block = fill_val * (blk_sz // 4)
                                chunk_fill = fill_block * min(cblocks, 1024)
                                for _ in range(cblocks // 1024):
                                    out_f.write(chunk_fill)
                                if cblocks % 1024:
                                    out_f.write(fill_block * (cblocks % 1024))
                        elif ctype == 0xCAC3: # DONT_CARE
                            pass
                        elif ctype == 0xCAC4: # CRC32
                            cf.seek(data_sz, 1)
                            
                        cur_blk += cblocks
                        
        print(f"[+] De-sparsing complete: {output_raw_path} ({os.path.getsize(output_raw_path) / (1024*1024):.2f} MB)", flush=True)

def unpack_super(raw_path, output_dir, target_names):
    os.makedirs(output_dir, exist_ok=True)
    raw_path_obj = Path(raw_path)
    output_dir_obj = Path(output_dir)
    print(f"[*] Reading LP metadata from {raw_path} ...", flush=True)
    metadata = ReadMetadata(raw_path_obj, 0)
    
    actual_parts = []
    avail = {GetPartitionName(p): p for p in metadata.partitions}
    for t in target_names:
        if t in avail:
            actual_parts.append(t)
        elif f"{t}_a" in avail:
            actual_parts.append(f"{t}_a")
        else:
            print(f"[-] Warning: Partition {t} not found in metadata!", flush=True)
            
    print(f"[*] Extracting partitions {actual_parts} into {output_dir} ...", flush=True)
    with open(raw_path, 'rb') as f:
        extractor = ImageExtractor(f, metadata, actual_parts, output_dir_obj)
        extractor.Extract()
    print(f"[+] Extracted partitions to {output_dir}", flush=True)

def extract_firmware(zip_path, target_partitions, output_dir):
    os.makedirs(output_dir, exist_ok=True)
    temp_raw = os.path.join(output_dir, "temp_super.raw")
    try:
        desparse_chunks(zip_path, "super.img_sparsechunk", temp_raw)
        unpack_super(temp_raw, output_dir, target_partitions)
    finally:
        if os.path.exists(temp_raw):
            print(f"[*] Cleaning up temporary raw image {temp_raw} ...", flush=True)
            os.remove(temp_raw)
            print("[+] Cleaned up.", flush=True)

if __name__ == '__main__':
    mode = sys.argv[1] if len(sys.argv) > 1 else 'help'
    if mode == 'portov':
        zip_file = r'C:\Users\anjic\Desktop\Projects\Portov\XT2533-3_PORTOV_RETIN_15_V2VT35.34-28-18_subsidy-DEFAULT_regulatory-DEFAULT_cid50_CFC.xml.zip'
        out_dir = r'C:\Users\anjic\Desktop\Projects\Portov\port_workspace\portov_extracted'
        parts = ['vendor', 'vendor_dlkm', 'system_dlkm']
        extract_firmware(zip_file, parts, out_dir)
    elif mode == 'mumba':
        zip_file = r'C:\Users\anjic\Desktop\Projects\Portov\XT2537-5_MUMBA_RETIN_17_A171WAAH.31-9-4_subsidy-DEFAULT_regulatory-DEFAULT_cid50_CFC.xml.zip'
        out_dir = r'C:\Users\anjic\Desktop\Projects\Portov\port_workspace\mumba_extracted'
        parts = ['system', 'system_ext', 'product']
        extract_firmware(zip_file, parts, out_dir)
    else:
        print("Usage: python sparse_extractor.py [portov|mumba]")
