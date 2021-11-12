import sys

sys.path.append('D:/Git/DEVS-Python')

# from src.CO_ORDINATORS import CO_ORDINATORS
from src.PROCESSORS import PROCESSORS

class ROOT_CO_ORDINATORS(PROCESSORS):
    def __init__(self):
        PROCESSORS.__init__(self)
        self.name=""
        self.clock_base=0
        self.child = PROCESSORS()
    
    def setName(self, name):
        self.name= "R:" + name

    def setChild(self, processor):
        self.child = processor
    
    def initialize(self):
        self.clock_base=0
        devs_component = self.child.getDevsComponent()
        self.setName(devs_component.getName())
        
        self.child.initialize()
        self.clock_base = self.child.getTimeOfNextEvent()
