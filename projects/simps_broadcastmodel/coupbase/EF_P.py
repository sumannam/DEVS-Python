import sys
import config

# from pypreprocessor import pypreprocessor
# pypreprocessor.parse()

from src.COUPLED_MODELS import COUPLED_MODELS
from coupbase.PS import PS
from coupbase.EF import EF

class EF_P(COUPLED_MODELS):
    def __init__(self):
        COUPLED_MODELS.__init__(self)
        self.setName(self.__class__.__name__)

        ef = EF()
        ps = PS()      
        
        self.addModel(ef)
        self.addModel(ps)

        self.addCoupling(ef, "out", ps, "in")
        self.addCoupling(ps, "out", ef, "in")
        
        # self.priority_list.extend([ef, p])