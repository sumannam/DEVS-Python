import sys

from projects.PipeLeakMonitoringSystem.config import setDevPath
setDevPath()

# from pypreprocessor import pypreprocessor
# pypreprocessor.parse()

from src.COUPLED_MODELS import COUPLED_MODELS

from projects.PipeLeakMonitoringSystem.coupbase.PIPING import PIPING
from projects.PipeLeakMonitoringSystem.coupbase.EF import EF

class EF_PIPING(COUPLED_MODELS):
    def __init__(self):
        COUPLED_MODELS.__init__(self)
        self.setName(self.__class__.__name__)

        ef = EF()
        piping = PIPING()        
        
        self.addModel(ef)
        self.addModel(piping)

        self.addCoupling(ef, "out", piping, "in")
        self.addCoupling(piping, "out", ef, "in")