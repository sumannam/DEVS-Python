import sys

from src.COUPLED_MODELS import COUPLED_MODELS

from mbase.GENR import GENR
from mbase.TRANSD import TRANSD


class EF(COUPLED_MODELS):
    def __init__(self):
        COUPLED_MODELS.__init__(self)
        self.setName(self.__class__.__name__)

        self.addInPorts("in")
        self.addOutPorts("out", "result")
   
        genr = GENR()
        transd = TRANSD()
        
        self.addModel(genr)
        self.addModel(transd)

        self.addCoupling(self, "in", transd, "solved")
        self.addCoupling(genr, "out", self, "out")
        self.addCoupling(transd, "out", self, "result")
        self.addCoupling(transd, "out", genr, "stop")
        self.addCoupling(genr, "out", transd, "arrived")
        
        # self.priority_list.extend([genr, transd])