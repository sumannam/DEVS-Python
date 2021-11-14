import sys
import math

sys.path.append('D:/Git/DEVS-Python')

from src.PROCESSORS import PROCESSORS
from src.ROOT_CO_ORDINATORS import ROOT_CO_ORDINATORS

class SIMULATORS(PROCESSORS):
    def __init__(self):
        PROCESSORS.__init__(self)

        self.parent = ROOT_CO_ORDINATORS()
        self.parent.setChild(self)

    def initialize(self):
        super().initialize()
        self.tN=self.devs_cmponent.timeAdvancedFunc()