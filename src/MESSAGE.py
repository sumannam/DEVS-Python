import sys
sys.path.append('D:/Git/DEVS-Python')

# from src.CONTENT import CONTENT

class MESSAGE():
    STAR = '*'

    def __init__(self):
        self.type = None
        self.source = None
        self.time = -1
    
    def setRootStar(self, type, time):
        self.type = type
        self.time = time
    
    def setStar(self, type, model, time):
        self.type = type
        self.model = model
        self.time = time
    
    def getTime(self):
        return self.time