import os
import sys
from pathlib import Path

PROJECT_NAME = "DEVS-Python"
TBASE_FOLDER = ""

if 'win' in sys.platform:  # Windows
    sys.path.append('D:/Git/DEVS-Python')
    sys.path.append('D:/Git/DEVS-Python/projects/simparc')
    TBASE_FOLDER = os.path.dirname(os.path.abspath(__file__)) + "\\tbase"
else:  # Linux, Unix, MacOS
    sys.path.append('.')
    TBASE_FOLDER = os.path.dirname(os.path.abspath(__file__)) + "/tbase"


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
