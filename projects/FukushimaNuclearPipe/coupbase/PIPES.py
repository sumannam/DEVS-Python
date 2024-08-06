import sys

from projects.PipeLeakMonitoringSystem.config import setDevPath
setDevPath()

# from pypreprocessor import pypreprocessor
# pypreprocessor.parse()

from src.COUPLED_MODELS import COUPLED_MODELS

from projects.PipeLeakMonitoringSystem.mbase.PIPE_CNTR import PIPE_CNTR
from projects.PipeLeakMonitoringSystem.mbase.PIPIE1 import PIPE1
from projects.PipeLeakMonitoringSystem.mbase.PIPE2 import PIPE2
from projects.PipeLeakMonitoringSystem.mbase.PIPE3 import PIPE3
from projects.PipeLeakMonitoringSystem.mbase.PIPE4 import PIPE4


class PIPES(COUPLED_MODELS):
    def __init__(self):
        COUPLED_MODELS.__init__(self)
        self.setName(self.__class__.__name__)
        
        self.addInPorts("in")
        self.addOutPorts("out")

        pipe_cntr = PIPE_CNTR()
        pipe1 = PIPE1()
        pipe2 = PIPE2()
        pipe3 = PIPE3()
        pipe4 = PIPE4()
        
        self.addModel(pipe_cntr)
        self.addModel(pipe1)
        self.addModel(pipe2)
        self.addModel(pipe3)
        self.addModel(pipe4)

        self.addCoupling(self, "in", pipe_cntr, "in")
        
        self.addCoupling(pipe_cntr, "x1", pipe1, "in")
        self.addCoupling(pipe1, "out", pipe_cntr, "y1")
        self.addCoupling(pipe_cntr, "x2", PIPE2, "in")
        self.addCoupling(pipe2, "out", pipe_cntr, "y2")
        self.addCoupling(pipe_cntr, "x3", PIPE3, "in")
        self.addCoupling(pipe3, "out", pipe_cntr, "y3")
        self.addCoupling(pipe_cntr, "x4", PIPE4, "in")
        self.addCoupling(pipe4, "out", pipe_cntr, "y4")
        
        self.addCoupling(pipe_cntr, "out", self, "out")