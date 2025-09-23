import os
import shutil
import subprocess
from datetime import datetime

# --- Configuration ---
delphi_path = r"c:\app\Embarcadero\Studio"
delphi_version = "37.0"

# The target directory will be a 'delphi' folder in the same directory as the script.
repack_base_dir = os.path.join(os.path.dirname(os.path.abspath(__file__)), "delphi")

# --- Source Paths ---
source_base_dir = os.path.join(delphi_path, delphi_version)
source_bin_dir = os.path.join(source_base_dir, "bin")
source_lib_win32_release = os.path.join(source_base_dir, "lib", "win32", "release")
source_lib_win64_release = os.path.join(source_base_dir, "lib", "win64", "release")

# --- Target Paths ---
target_base_dir = os.path.join(repack_base_dir, delphi_version)
target_bin_dir = os.path.join(target_base_dir, "bin")
target_lib_win32_release = os.path.join(target_base_dir, "lib", "win32", "release")
target_lib_win64_release = os.path.join(target_base_dir, "lib", "win64", "release")

# --- Files to Copy ---
files_to_copy = [
    "lnkdfm" + delphi_version.replace('.', '') + ".dll",
    "rlink32.dll",
    "rw32core.dll",
    "brcc32.exe",
    "dcc32.exe",
    "dcc64.exe",
]

# --- Main Script ---
def create_directories():
    """Creates the necessary directory structure for the repack."""
    os.makedirs(target_bin_dir, exist_ok=True)
    os.makedirs(target_lib_win32_release, exist_ok=True)
    os.makedirs(target_lib_win64_release, exist_ok=True)
    print("Created repack directories.")


def copy_files():
    """Copies the specified files to the bin directory."""
    for filename in files_to_copy:
        src_path = os.path.join(source_bin_dir, filename)
        if os.path.exists(src_path):
            shutil.copy(src_path, target_bin_dir)
            print(f"Copied {filename} to {target_bin_dir}")
        else:
            print(f"Warning: Source file not found - {src_path}")


def copy_release_folders():
    """Copies the contents of the release folders."""
    if os.path.isdir(source_lib_win32_release):
        shutil.copytree(source_lib_win32_release, target_lib_win32_release, dirs_exist_ok=True)
        print(f"Copied contents of {source_lib_win32_release}")
    else:
        print(f"Warning: Source directory not found - {source_lib_win32_release}")

    if os.path.isdir(source_lib_win64_release):
        shutil.copytree(source_lib_win64_release, target_lib_win64_release, dirs_exist_ok=True)
        print(f"Copied contents of {source_lib_win64_release}")
    else:
        print(f"Warning: Source directory not found - {source_lib_win64_release}")


def create_7z_archive():
    """Creates a password-protected 7-Zip archive of the repack directory."""
    ver_str = delphi_version.split('.')[0]
    date_str = datetime.now().strftime("%y%m%d")
    archive_name = f"d{ver_str}.{date_str}.7z"

    print(f"\nCreating 7-Zip archive: {archive_name}")
    
    command = [
        '7z', 'a',
        archive_name,
        repack_base_dir,
        '-psasgis',
        '-mhe=on' # Encrypt file names
    ]

    try:
        subprocess.run(command, check=True, capture_output=True, text=True)
        print("Successfully created 7-Zip archive.")
    except FileNotFoundError:
        print("\nError: '7z' command not found.")
        print("Please make sure 7-Zip is installed and added to your system's PATH.")
    except subprocess.CalledProcessError as e:
        print(f"\nError creating 7-Zip archive:")
        print(e.stderr)


def cleanup():
    """Cleans up the repack directory."""
    if os.path.isdir(repack_base_dir):
        shutil.rmtree(repack_base_dir)


if __name__ == "__main__":
    create_directories()
    copy_files()
    copy_release_folders()
    create_7z_archive()
    cleanup()
    print("\nRepack creation process finished.")
