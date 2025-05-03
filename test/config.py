import os
import sys
from pathlib import Path

def setup_paths():
    """
    Set up Python paths for the DEVS-Python project.
    This function adds necessary directories to sys.path based on the project structure.
    """
    # Get the project root directory (where this config.py file is located)
    project_root = Path(__file__).parent.parent.absolute()
    
    # Add main project directories to sys.path
    sys.path.append(str(project_root))
    sys.path.append(str(project_root / 'test'))
    sys.path.append(str(project_root / 'projects' / 'coupledmodelTest'))
    
    # Add any additional paths from environment variable if specified
    additional_paths = os.environ.get('DEVS_PYTHON_PATHS', '').split(os.pathsep)
    for path in additional_paths:
        if path:  # Skip empty paths
            sys.path.append(path)

# Execute path setup when this module is imported
setup_paths()