import sys

sys.path.append('D:/Git/DEVS-Python')

from src.CONTENT import CONTENT
from enum import Enum

# class Type(Enum):
#     STAR = 1
#     X = 2
#     Y = 3
#     DONE = 4

Type = Enum(star=1, x=2)

class MESSAGE():
    def __init__(self):
        self.type = None
        self.source = None
        self.time = -9999
    
    def __init__(self, type, time):
        self.type = type
        self.source = None
        self.time = time        
    
    def __init__(self, type, source, time):
        self.type = type
        self.source = source
        self.time = time
