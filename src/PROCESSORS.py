import sys

sys.path.append('D:/Git/DEVS-Python')

from src.ENTITIES import ENTITIES

class PROCESSORS(ENTITIES):
    def __init__(self, model_name):
        self.name = model_name

        self.parent = None
        devs_cmponent = None

        print(self.name)
    
    def setParent(self, processor):
        self.praent = processor
    
    def getParent(self):
        return self.parent
