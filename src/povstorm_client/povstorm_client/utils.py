
def remove_recursively(path):
    """Recursively removes files from a directory, ignoring symlinks."""

    for entry in os.scandir(path):
        if entry.is_symlink():
            continue  # Skip symlinks
        elif entry.is_file():
            os.remove(entry.path)
        elif entry.is_dir():
            remove_files_recursively(entry.path)