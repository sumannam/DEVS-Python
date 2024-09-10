import sys
import config
from queue import Queue

from src.COUPLED_MODELS import COUPLED_MODELS

from projects.FukushimaNuclearPipe.coupbase.PIPES import PIPES
from projects.FukushimaNuclearPipe.coupbase.EF import EF

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
    
    # 디지털트윈(유니티)과 연결을 위한 MQTT에 메시지를 전달하는 큐 파라미터 설정[24.08.13; 남수만]
    def __init__(self, msgQueue: Queue):
        COUPLED_MODELS.__init__(self)
        self.setName(self.__class__.__name__)

        ef = EF()
        pipes = PIPES(msgQueue)        
        
        self.addModel(ef)
        self.addModel(pipes)

        self.addCoupling(ef, "out", pipes, "in")
        self.addCoupling(pipes, "out", ef, "in")
        
        # self.priority_list.extend([ef, pipes])