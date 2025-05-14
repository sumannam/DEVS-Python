import sys
import config

# from pypreprocessor import pypreprocessor
# pypreprocessor.parse()

from src.COUPLED_MODELS import COUPLED_MODELS
<<<<<<<< HEAD:projects/simps_broadcastmodel/coupbase/EF_PS.py

========
>>>>>>>> aa8271f3d8f60045a2c2a14ac9e5aa4f78198c63:projects/simps_broadcastmodel/coupbase/EF_P.py
from coupbase.PS import PS
from coupbase.EF import EF

class EF_PS(COUPLED_MODELS):
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