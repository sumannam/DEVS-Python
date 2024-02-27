import sys

from projects.PipeLeakMonitoringSystem.config import setDevPath
setDevPath()

# from pypreprocessor import pypreprocessor
# pypreprocessor.parse()

from src.COUPLED_MODELS import COUPLED_MODELS

from projects.PipeLeakMonitoringSystem.mbase.PIPING_CNTR import PIPING_CNTR
from projects.PipeLeakMonitoringSystem.mbase.PIPING1 import PIPING1
from projects.PipeLeakMonitoringSystem.mbase.PIPING2 import PIPING2
from projects.PipeLeakMonitoringSystem.mbase.PIPING3 import PIPING3
from projects.PipeLeakMonitoringSystem.mbase.PIPING4 import PIPING4


class PIPING(COUPLED_MODELS):
    def __init__(self):
        COUPLED_MODELS.__init__(self)
        self.setName(self.__class__.__name__)
        
        self.addInPorts("in")
        self.addOutPorts("out")

        piping_cntr = PIPING_CNTR()
        piping1 = PIPING1()
        piping2 = PIPING2()
        piping3 = PIPING3()
        piping4 = PIPING4()
        
        self.addModel(piping_cntr)
        self.addModel(piping1)
        self.addModel(piping2)
        self.addModel(piping3)
        self.addModel(piping4)

        self.addCoupling(self, "in", piping_cntr, "in")
        self.addCoupling(piping_cntr, "y1", piping1, "in")
        self.addCoupling(piping1, "out", piping_cntr, "in")
        self.addCoupling(piping_cntr, "out", self, "out")