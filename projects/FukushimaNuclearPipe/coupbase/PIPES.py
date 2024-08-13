import sys
import config
from queue import Queue

from src.COUPLED_MODELS import COUPLED_MODELS


from mbase.PIPE_CNTR import PIPE_CNTR
from mbase.PIPE1 import PIPE1
from mbase.PIPE2 import PIPE2
from mbase.PIPE3 import PIPE3
from mbase.PIPE4 import PIPE4


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
        self.addCoupling(pipe_cntr, "x2", pipe2, "in")
        self.addCoupling(pipe2, "out", pipe_cntr, "y2")
        self.addCoupling(pipe_cntr, "x3", pipe3, "in")
        self.addCoupling(pipe3, "out", pipe_cntr, "y3")
        self.addCoupling(pipe_cntr, "x4", pipe4, "in")
        self.addCoupling(pipe4, "out", pipe_cntr, "y4")
        
        self.addCoupling(pipe_cntr, "out", self, "out")
    
    # 디지털트윈(유니티)과 연결을 위한 MQTT에 메시지를 전달하는 큐 파라미터 설정[24.08.13; 남수만]
    def __init__(self, msgQueue: Queue):
        COUPLED_MODELS.__init__(self)
        self.setName(self.__class__.__name__)
        
        self.addInPorts("in")
        self.addOutPorts("out")

        pipe_cntr = PIPE_CNTR()
        pipe1 = PIPE1(msgQueue)
        pipe2 = PIPE2(msgQueue)
        pipe3 = PIPE3(msgQueue)
        pipe4 = PIPE4(msgQueue)
        
        self.addModel(pipe_cntr)
        self.addModel(pipe1)
        self.addModel(pipe2)
        self.addModel(pipe3)
        self.addModel(pipe4)

        self.addCoupling(self, "in", pipe_cntr, "in")
        
        self.addCoupling(pipe_cntr, "x1", pipe1, "in")
        self.addCoupling(pipe1, "out", pipe_cntr, "y1")
        self.addCoupling(pipe_cntr, "x2", pipe2, "in")
        self.addCoupling(pipe2, "out", pipe_cntr, "y2")
        self.addCoupling(pipe_cntr, "x3", pipe3, "in")
        self.addCoupling(pipe3, "out", pipe_cntr, "y3")
        self.addCoupling(pipe_cntr, "x4", pipe4, "in")
        self.addCoupling(pipe4, "out", pipe_cntr, "y4")
        
        self.addCoupling(pipe_cntr, "out", self, "out")