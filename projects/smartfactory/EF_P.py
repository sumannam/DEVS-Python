import sys

sys.path.append('D:/Git/DEVS-Python')
sys.path.append('D:/Git/DEVS-Python/projects/simparc')

# from pypreprocessor import pypreprocessor
# pypreprocessor.parse()

from src.COUPLED_MODELS import COUPLED_MODELS

from PLC import PLC
from EF import EF

#define __DEBUG

class EF_P(COUPLED_MODELS):
    def __init__(self):
        COUPLED_MODELS.__init__(self)
        self.setName(self.__class__.__name__)

        ef = EF()
        plc = PLC()        
        
        self.addModel(ef)
        self.addModel(plc)

        self.addCoupling(ef, "out", plc, "in")
        self.addCoupling(plc, "out", ef, "in")