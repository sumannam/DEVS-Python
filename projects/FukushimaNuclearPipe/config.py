import os
import sys
from pathlib import Path

PROJECT_NAME = "FukushimaNuclearPipe"
TBASE_FOLDER = ""

if 'win' in sys.platform:  # Windows
    currnt_path = os.getcwd()
    sys.path.append(currnt_path)
    
    if "Git" in currnt_path:
        project_path = os.path.join(currnt_path, "projects", PROJECT_NAME)
        sys.path.append(project_path)
        TBASE_FOLDER = os.path.dirname(os.path.abspath(__file__)) + "\\tbase"
    

else:  # Linux, Unix, MacOS
    sys.path.append('.')
    TBASE_FOLDER = os.path.dirname(os.path.abspath(__file__)) + "\\tbase"