import sys

sys.path.append('D:/Git/DEVS-Python')

from src.PROCESSORS import PROCESSORS
from src.ROOT_CO_ORDINATORS import ROOT_CO_ORDINATORS

class CO_ORDINATORS(PROCESSORS):
    def __init__(self):
        PROCESSORS.__init__(self)
        
        self.parent=ROOT_CO_ORDINATORS()
        self.parent.setChild(self)
        self.processor_list = []
        self.processor_time = {}

        self.devs_cmponent = None

    def addChild(self, processor):
        self.processor_list.append(processor)

    def initialize(self):
        for processor in self.processor_list:
            processor.initialize()
            time = processor.getTimeOfNextEvent()
            processor_name = processor.getName()
            self.processor_time[processor_name]=time


