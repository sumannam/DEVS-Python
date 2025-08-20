import sys

# from src.COUPLED_MODELS import COUPLED_MODELS
from src.BROADCAST_MODELS import BROADCAST_MODELS
from .BP import BP

class PS(BROADCAST_MODELS):
    def __init__(self):
        BROADCAST_MODELS.__init__(self)
        self.setName(self.__class__.__name__)

        self.addInPorts("in")
        self.addOutPorts("out")

        self.makeControllee(BP, 3)
        bp_list = self.getControlleeList()
        
        self.addCoupling(self, "in", bp_list, "in")
        self.addCoupling(bp_list, "out", self, "out")
        # self.addCoupling(bp_list, "unsolved", bp_list, "in")