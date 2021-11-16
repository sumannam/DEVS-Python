import sys

sys.path.append('D:/Git/DEVS-Python')
sys.path.append('D:/Git/DEVS-Python/projects/simparc')

# from pypreprocessor import pypreprocessor
# pypreprocessor.parse()

from src.COUPLED_MODELS import COUPLED_MODELS

from P import P
from EF import EF

#define __DEBUG

class EF_P(COUPLED_MODELS):
    def __init__(self):
        COUPLED_MODELS.__init__(self, self.__class__.__name__)
        self.addInPorts("in", "in1")

        p = P()
        ef = EF()
        
        self.addModel(p)
        self.addModel(ef)

        self.addCoupling(ef, "out", p, "in")
        self.addCoupling(p, "out", ef, "in")


if __name__ == '__main__':
    ef_p = EF_P()