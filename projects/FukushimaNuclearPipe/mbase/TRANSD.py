import sys
import math

from src.ATOMIC_MODELS import ATOMIC_MODELS
from src.CONTENT import CONTENT
from src.PORT import PORT

from src.util import *
from src.log import *

class TRANSD(ATOMIC_MODELS):
    def __init__(self):
        ATOMIC_MODELS.__init__(self)
        self.setName(self.__class__.__name__)
        
        self.addInPorts("solved", "arrived")
        self.addOutPorts("out")

        self.observation_interval = 100
        
        self.state["sigma"]=self.observation_interval
        self.state["phase"]="active"
        self.addState("arrived_list", [])
        self.addState("solved_list", [])
        self.addState("clock", 0.0)
        self.addState("total_ta", 0.0)

        self.arrived_dic={}
        self.solved_dic={}
        
        self.job_json = {}

    def externalTransitionFunc(self, e, x):
        clock = self.state["clock"]
        self.state["clock"] = clock + e
        time = clock
        
        if x.port == "arrived":
            self.arrived_dic[x.value]=time
        # TODO : solved 포트가 실행되지 않는다. 왜 그럴까? [남수만; 24.08.19]
        # 결합 모델들(EF-PIPE, EF) 커플링 정보도 이상이 없어 보인다.
        elif x.port == "solved":
            self.job_json = convertStringToJson(x.value)
            self.arrived_dic[x.value]=time
        
        self.Continue(e)
        

    def internalTransitionFunc(self):
        if self.state["phase"] == "active":
            clock = self.state["clock"]
            sigma = self.state["sigma"]
            self.state["clock"] = clock + sigma
            self.passviate()


    def outputFunc(self):
        content = CONTENT()    

        avg_ta_time = 0
        throughput = 0.0
        time = self.state["clock"]

        if self.state["phase"] == "active":
            if(len(self.solved_dic)!=0):
                avg_ta_time = self.state["total_ta"] / len(self.solved_dic)

            if(time!=0):
                throughput = (len(self.solved_dic)-1) / (time-avg_ta_time)
            
            # print(avg_ta_time)
            # print(throughput)

            value = avg_ta_time

            content.setContent("out", value)

            return content