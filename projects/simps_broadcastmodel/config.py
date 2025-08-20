import os
import sys
from pathlib import Path

PROJECT_NAME = "DEVS-Python"

def get_project_root():
    """Find the project root directory by searching for the project name in the path."""
    current_path = Path.cwd()
    
    # Search up the directory tree until we find the project root
    while current_path.name != PROJECT_NAME and current_path.parent != current_path:
        current_path = current_path.parent
    
    if current_path.name == PROJECT_NAME:
        return current_path
    else:
        raise RuntimeError(f"Could not find {PROJECT_NAME} project root directory")

def setup_paths():
    """Setup all necessary paths for the project."""
    try:
        project_root = get_project_root()
        project_root_str = str(project_root)
        
        # Add project root to Python path if not already there
        if project_root_str not in sys.path:
            sys.path.append(project_root_str)
        
        # Add project's models directory to Python path
        models_path = str(project_root / "projects" / "simps_broadcastmodel")
        if models_path not in sys.path:
            sys.path.append(models_path)
        
        # Set TBASE folder path
        tbase_path = Path(__file__).parent / "tbase"
        return str(tbase_path)
    except RuntimeError as e:
        print(f"Error: {e}")
        sys.exit(1)

# Initialize paths
TBASE_FOLDER = setup_paths()

# Clean up the namespace
del get_project_root, setup_paths
