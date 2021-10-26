import sys

sys.path.append('D:/Git/DEVS-Python')
sys.path.append('D:/Git/DEVS-Python/projects/simparc')

# from pypreprocessor import pypreprocessor
# pypreprocessor.parse()

from src.COUPLED_MODELS import COUPLED_MODELS


class EF(COUPLED_MODELS):
    def __init__(self):
        COUPLED_MODELS.__init__(self, self.__class__.__name__)

        self.addInPorts("in")
        self.addOutPorts("out")

        #p = P()
        #ifdef DEBUG
        #print(self.getInports())
        #print(p.getInports())
        #endif
        
        #self.addModel(p)
        #self.addCoupling(self, "in", p, "in")


if __name__ == '__main__':
    ef = EF()