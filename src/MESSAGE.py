import sys

sys.path.append('D:/Git/DEVS-Python')

from src.CONTENT import CONTENT

class MESSAGE():
    STAR = '*'

    def __init__(self):
        self.type = None
        self.source = None
        self.time = -1
    
    def setStar(self, type, time):
        self.type = type
        self.time = time

