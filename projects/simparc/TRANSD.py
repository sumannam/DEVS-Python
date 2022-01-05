import sys
import math

sys.path.append('D:/Git/DEVS-Python')
sys.path.append('D:/Git/DEVS-Python/projects/simparc')

from src.ATOMIC_MODELS import ATOMIC_MODELS
from src.CONTENT import CONTENT
from src.PORT import PORT

class TRANSD(ATOMIC_MODELS):
    def __init__(self):
        ATOMIC_MODELS.__init__(self)
        self.setName(self.__class__.__name__)
        
        self.addInPorts("solved", "arrived")
        self.addOutPorts("out")

        self.observation_interval = 11
        
        self.state["sigma"]=self.observation_interval
        self.state["phase"]="active"
        self.addState("arrived_list", [])
        self.addState("solved_list", [])
        self.addState("clock", 0.0)
        self.addState("total_ta", 0.0)

        self.arrived_dic={}
        self.solved_dic={}

    def externalTransitionFunc(self, e, x):
        time = self.state["clock"] + e

        if x.port == "arrived":
            self.arrived_dic[x.value]=time
        if x.port == "solved":
            self.arrived_dic[x.value]=time
        else:
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
            
            print(avg_ta_time)
            print(throughput)

            value = avg_ta_time

            content.setContent("out", value)

            return content