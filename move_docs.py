#!/usr/bin/env python3
import os
import shutil
from pathlib import Path

# Paths
source_dir = Path("/workspaces/HRMS")
dest_dir = Path("/workspaces/HRMS/MD")

# Create destination if it doesn't exist
dest_dir.mkdir(exist_ok=True)

# Get all .md files in root
md_files = sorted([f for f in source_dir.iterdir() if f.suffix == '.md' and f.is_file()])

print(f"Found {len(md_files)} markdown files to move:\n")

moved = 0
for file_path in md_files:
    dest_path = dest_dir / file_path.name
    try:
        # Copy file content
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
        with open(dest_path, 'w', encoding='utf-8') as f:
            f.write(content)
        
        # Remove original
        os.remove(file_path)
        
        print(f"✓ {file_path.name}")
        moved += 1
    except Exception as e:
        print(f"✗ {file_path.name}: {e}")

print(f"\n✅ Successfully moved {moved}/{len(md_files)} markdown files to MD/ folder")
print(f"\n📁 New structure: /workspaces/HRMS/MD/")
