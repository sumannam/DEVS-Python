import sys
import math

sys.path.append('D:/Git/DEVS-Python')

from src.ENTITIES import ENTITIES

class PROCESSORS(ENTITIES):
    def __init__(self):
        self.parent = None
        self.devs_cmponent = None

        self.tL = 0
        self.tN = math.inf
    
    def setParent(self, processor):
        self.praent = processor
    
    def getParent(self):
        return self.parent

    def setDevsComponent(self, model):
        self.devs_cmponent = model
        #print(self.devs_cmponent)

    def getDevsComponent(self):
        return self.devs_cmponent
    
    def initialize(self):
        self.tL = 0
        self.tN = math.inf
    
    def getTimeOfNextEvent(self):
        return self.tN
    
    def getTimeOfLastEvent(self):
        return self.tL