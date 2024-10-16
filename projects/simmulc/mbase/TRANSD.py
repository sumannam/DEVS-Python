import sys
import math

from src.ATOMIC_MODELS import ATOMIC_MODELS
from src.CONTENT import CONTENT
from src.PORT import PORT

class TRANSD(ATOMIC_MODELS):
    def __init__(self):
        ATOMIC_MODELS.__init__(self)
        self.setName(self.__class__.__name__)
        
        self.addInPorts("solved", "arrived")
        self.addOutPorts("out")

        self.observation_interval = 50
        
        self.state["sigma"]=self.observation_interval
        self.state["phase"]="active"
        self.addState("arrived_list", [])
        self.addState("solved_list", [])
        self.addState("clock", 0.0)
        self.addState("total_ta", 0.0) # total turnaround time

        self.arrived_dic={}
        self.solved_dic={}

    def externalTransitionFunc(self, e, x):
        clock = self.state["clock"]
        self.state["clock"] = clock + e
        time = clock

        if x.port == "arrived":
            self.arrived_dic[x.value]=time
        if x.port == "solved":
            turn_around_time = time - self.arrived_dic[x.value]
            
            # Update total turn-around time and solved list
            total_ta = self.state["total_ta"]
            total_ta += turn_around_time
            self.state["total_ta"] = total_ta
            
            self.solved_dic[x.value]=time
        
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
                total_ta_time = self.state["total_ta"]
                avg_ta_time = total_ta_time / len(self.solved_dic)

            if(time!=0):
                throughput = (len(self.solved_dic)-1) / (time-avg_ta_time)
            
            print(avg_ta_time)
            print(throughput)

            value = avg_ta_time

            content.setContent("out", value)

            return content