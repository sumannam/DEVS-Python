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

        self.observation_interval = 30
        
        self.state["sigma"]=self.observation_interval
        self.state["phase"]="active"
        self.addState("arrived_list", {})
        self.addState("solved_list", {})
        self.addState("clock", 0.0)
        self.addState("total_ta", 0.0)

    def externalTransitionFunc(self, e, x):
        clock = self.state["clock"]
        self.state["clock"] = clock + e
        time = clock

        if x.port == "arrived":
            self.state["arrived_list"][x.value] = time
        if x.port == "solved":
            prob_arrival_time = self.get_arrival_time(x.value)
            turn_around_time = time - prob_arrival_time

            if(prob_arrival_time >= 0):
                self.state["total_ta"] = self.state["total_ta"] + turn_around_time
                self.state["solved_list"][x.value] = time                

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
            if(len(self.state["solved_list"])!=0):
                avg_ta_time = self.state["total_ta"] / len(self.state["solved_list"])

            if(time!=0):
                throughput = (len(self.state["solved_list"])-1) / (time-avg_ta_time)
            
            print("avg_ta_time", avg_ta_time)
            print("throughput", throughput)

            content.setContent("out", avg_ta_time)
            return content
        
    def get_arrival_time(self, job_id):
        arrival_time = self.state["arrived_list"][job_id]

        if(arrival_time >= 0):
            return arrival_time
        else:
            return -1