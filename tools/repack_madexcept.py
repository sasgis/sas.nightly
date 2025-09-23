import os
import shutil
import subprocess
from datetime import datetime

# --- Configuration ---
source_dir = r'c:\app\madCollection'
madexcept_version = '520'  # e.g., 5.2.0 -> 520

# The target directory will be a 'madexcept' folder in the same directory as the script.
repack_base_dir = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'madexcept')

# List of BDS versions to process
versions_to_process = {
    'BDS21': '21.0', # Delphi 10.4.x
    'BDS37': '37.0', # Delphi 13.x
}

# --- Main Script ---
def create_7z_archive(target_version):
    """
    Creates a password-protected 7z archive for the given version.
    """
    # Format: me<version>.d<delphi_version>.<date>
    ver_str = target_version.split('.')[0]
    date_str = datetime.now().strftime('%y%m%d')
    archive_filename = f"me{madexcept_version}.d{ver_str}.{date_str}.7z"

    print(f"  Creating archive: {archive_filename}")

    command = [
        '7z', 'a',
        archive_filename,
        repack_base_dir,
        '-psasgis',
        '-mhe=on' # Encrypt file names
    ]

    try:
        subprocess.run(command, check=True, capture_output=True, text=True)
        print(f"  Successfully created archive for version {target_version}")
    except FileNotFoundError:
        print(f"  Error: '7z' command not found. Please make sure 7-Zip is installed and added to your system's PATH.")
    except subprocess.CalledProcessError as e:
        print(f"  Error creating archive for version {target_version}:")
        print(f"  Command: {' '.join(command)}")
        print(e.stderr)


def get_target_path(source_path, target_version):
    """
    Determines the target path for a given source file.
    """
    filename = os.path.basename(source_path)
    platform = os.path.basename(os.path.dirname(source_path))  # win32 or win64

    if filename.endswith('.dcu'):
        if platform in ['win32', 'win64']:
            return os.path.join(repack_base_dir, target_version, 'lib', platform, filename)
    elif filename == 'madExceptPatch.exe':
        return os.path.join(repack_base_dir, target_version, 'bin', filename)

    return None


def main():
    if not os.path.isdir(source_dir):
        print(f"Error: Source directory '{source_dir}' not found.")
        return

    print(f"Source: {source_dir}")
    print(f"Target: {repack_base_dir}")
    print("-" * 20)

    for version_name, target_version in versions_to_process.items():
        print(f"Processing version: {version_name} -> {target_version}")

        # Clean up old directory if it exists
        if os.path.isdir(repack_base_dir):
            shutil.rmtree(repack_base_dir)

        # Process dcu files
        for component in ['madBasic', 'madDisAsm', 'madExcept', 'madSecurity']:
            for platform in ['win32', 'win64']:
                dcu_source_dir = os.path.join(source_dir, component, version_name, platform)
                if os.path.isdir(dcu_source_dir):
                    for filename in os.listdir(dcu_source_dir):
                        if filename.endswith('.dcu'):
                            source_file = os.path.join(dcu_source_dir, filename)
                            target_path = get_target_path(source_file, target_version)
                            if target_path:
                                os.makedirs(os.path.dirname(target_path), exist_ok=True)
                                shutil.copy2(source_file, target_path)

        # Process tools
        tools_dir = os.path.join(source_dir, 'madExcept', 'Tools')
        if os.path.isdir(tools_dir):
            for filename in os.listdir(tools_dir):
                if filename == 'madExceptPatch.exe':
                    source_file = os.path.join(tools_dir, filename)
                    target_path = get_target_path(source_file, target_version)
                    if target_path:
                        os.makedirs(os.path.dirname(target_path), exist_ok=True)
                        shutil.copy2(source_file, target_path)


        if os.path.isdir(repack_base_dir):
            # Create 7z archive
            create_7z_archive(target_version)
            # Clean up
            shutil.rmtree(repack_base_dir)

    print("-" * 20)
    print("Repack complete.")


if __name__ == "__main__":
    main()