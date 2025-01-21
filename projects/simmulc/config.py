import os
import sys
from pathlib import Path

PROJECT_NAME = "DEVS-Python"
TBASE_FOLDER = ""

if 'win' in sys.platform:  # Windows
    currnt_path = os.getcwd()
    sys.path.append(currnt_path)
    
    if "Git" in currnt_path:
        project_path = os.path.join(currnt_path, "projects", PROJECT_NAME)
        sys.path.append(project_path)
        TBASE_FOLDER = os.path.dirname(os.path.abspath(__file__)) + "\\tbase"


def setDevPath():
    current_path = Path.cwd()
    path_str = str(current_path)

    if path_str[-11:] == PROJECT_NAME:
        sys.path.append(path_str)
        project_path = os.path.join(path_str, os.sep, "projects", os.sep, "simparc")
        sys.path.append(project_path)
    if path_str.find("projects") == -1:
        pass
        # os.walk("..")
        # current_path = Path.cwd()
        # parent_path = current_path.parent.name
        # print(parent_path)
