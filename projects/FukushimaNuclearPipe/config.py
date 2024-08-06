import os
import sys
from pathlib import Path

PROJECT_NAME = "FukushimaNuclearPipe"
TBASE_FOLDER = ""

if 'win' in sys.platform:  # Windows
    sys.path.append("D:\\Git\\DEVS-Python")
    sys.path.append("D:\\Git\\DEVS-Python\\projects\\" + PROJECT_NAME)
    TBASE_FOLDER = os.path.dirname(os.path.abspath(__file__)) + "\\tbase"
    
    print(sys.path)
else:  # Linux, Unix, MacOS
    sys.path.append('.')
    TBASE_FOLDER = os.path.dirname(os.path.abspath(__file__)) + "\\tbase"