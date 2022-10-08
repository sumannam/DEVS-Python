import sys

from conf import setDevPath
setDevPath()

# from pypreprocessor import pypreprocessor
# pypreprocessor.parse()

from src.COUPLED_MODELS import COUPLED_MODELS

from projects.simparc.mbase.P import P
from projects.simparc.coupbase.EF import EF

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