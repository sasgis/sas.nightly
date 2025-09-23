import os
import shutil
import sys

def copy_dlls(source_dir, target_dir):
    print(f"Source directory: {source_dir}")
    print(f"Target directory: {target_dir}")

    if not os.path.exists(source_dir):
        print(f"Error: Source directory not found: {source_dir}")
        return

    # Clear target directory if it exists
    if os.path.exists(target_dir):
        print(f"Clearing target directory: {target_dir}")
        try:
            shutil.rmtree(target_dir)
        except OSError as e:
            print(f"Error: Could not remove directory {target_dir} - {e}")
            sys.exit(1) # Exit if we can't clear the directory
    
    # Create target directory
    print(f"Creating target directory: {target_dir}")
    try:
        os.makedirs(target_dir)
    except OSError as e:
        print(f"Error: Could not create directory {target_dir} - {e}")
        sys.exit(1) # Exit if we can't create the directory

    # Copy DLL files
    copied_count = 0
    for item in os.listdir(source_dir):
        if item.endswith(".dll"):
            source_path = os.path.join(source_dir, item)
            target_path = os.path.join(target_dir, item)
            print(f"Copying {source_path} to {target_path}")
            try:
                shutil.copy2(source_path, target_path)
                copied_count += 1
            except IOError as e:
                print(f"Error: Could not copy file {source_path} to {target_path} - {e}")
                sys.exit(2)

    print(f"Copied {copied_count} DLLs from {source_dir} to {target_dir}")


if __name__ == "__main__":
    # Relative paths from the script location

    script_dir = os.path.dirname(os.path.abspath(__file__))

    print("Processing 32-bit libraries...")
    copy_dlls(
        source_dir=os.path.join(script_dir, "..", "..", "src", ".bin", "win32", "lib32"),
        target_dir=os.path.join(script_dir, "..", "data", "win32", "lib32")
    )

    print("\nProcessing 64-bit libraries...")
    copy_dlls(
        source_dir=os.path.join(script_dir, "..", "..", "src", ".bin", "win64", "lib64"),
        target_dir=os.path.join(script_dir, "..", "data", "win64", "lib64")
    )

    print("\nDLL copying finished.")