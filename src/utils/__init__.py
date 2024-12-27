
import shlex
import hcl
import os

def tfvars_to_env( fn: str ):

    with open( fn, "r" ) as fp:
        tfvars = hcl.load(fp)

    for k in tfvars:

        if isinstance( tfvars[k] , str ):
            print( f"TF_VAR_{k}={shlex.quote( tfvars[k] )}" )


def remove_recursively(path):
    """Recursively removes files from a directory, ignoring symlinks."""

    for entry in os.scandir(path):
        if entry.is_symlink():
            continue  # Skip symlinks
        elif entry.is_file():
            os.remove(entry.path)
        elif entry.is_dir():
            remove_files_recursively(entry.path)