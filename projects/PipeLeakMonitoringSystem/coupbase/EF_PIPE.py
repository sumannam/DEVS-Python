import sys

from projects.PipeLeakMonitoringSystem.config import setDevPath
setDevPath()

# from pypreprocessor import pypreprocessor
# pypreprocessor.parse()

from src.COUPLED_MODELS import COUPLED_MODELS

from projects.PipeLeakMonitoringSystem.coupbase.PIPES import PIPES
from projects.PipeLeakMonitoringSystem.coupbase.EF import EF

class EF_PIPE(COUPLED_MODELS):
    def __init__(self):
        COUPLED_MODELS.__init__(self)
        self.setName(self.__class__.__name__)

        ef = EF()
        pipes = PIPES()        
        
        self.addModel(ef)
        self.addModel(pipes)

        self.addCoupling(ef, "out", pipes, "in")
        self.addCoupling(pipes, "out", ef, "in")