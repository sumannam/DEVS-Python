import sys

sys.path.append('D:/Git/DEVS-Python')
sys.path.append('D:/Git/DEVS-Python/test')

from src.COUPLED_MODELS import COUPLED_MODELS

from samples.simparc.mbase.P import P
from samples.simparc.coupbase.EF import EF

class EF_P(COUPLED_MODELS):
    def __init__(self):
        COUPLED_MODELS.__init__(self)
        self.setName(self.__class__.__name__)

        ef = EF()
        p = P()        
        
        self.addModel(ef)
        self.addModel(p)

        self.addCoupling(ef, "out", p, "in")
        self.addCoupling(p, "out", ef, "in")