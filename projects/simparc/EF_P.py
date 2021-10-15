import sys

sys.path.append('D:/Git/DEVS-Python')
sys.path.append('D:/Git/DEVS-Python/projects/simparc')

# from pypreprocessor import pypreprocessor
# pypreprocessor.parse()

from src.COUPLED_MODELS import COUPLED_MODELS

from P import P

#define __DEBUG

class EF_P(COUPLED_MODELS):
    def __init__(self):
        COUPLED_MODELS.__init__(self, self.__class__.__name__)
        self.in_port = self.addInPort("in")        

        p = P()
        #ifdef DEBUG
        print(p.in_port)
        #endif
        
        self.addModel(p)
        self.addCoupling(self, self.in_port, p, p.in_port)


if __name__ == '__main__':
    ef_p = EF_P()