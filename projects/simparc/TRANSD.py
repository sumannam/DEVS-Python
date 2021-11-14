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

    def externalTransitionFunc(self, s, e, x):
        if x.port == "arrived":
            self.arrived_dic[x.value]=s["clock"]
        if x.port == "solved":
            self.arrived_dic[x.value]=s["clock"]
        else:
            self.Continue(e)

    def internalTransitionFunc(self, s):
        if s["phase"] == "active":
            clock = s["clock"]
            sigma = s["sigma"]
            s["clock"] = clock + sigma
            self.passviate()

    def outputFunc(self, s):
        avg_ta_time = 0
        throughput = 0.0
        time = s["clock"]


        if s["phase"] == "active":
            content = CONTENT()    
            job_id = "JOB-" + str(self.count)
            self.count+=1

            if(len(self.solved_dic)!=0):
                avg_ta_time = s["total_ta"] / len(self.solved_dic)

            if(time!=0):
                throughput = (len(self.solved_dic)-1) / (time-avg_ta_time)
            
            print(avg_ta_time)
            print(throughput)

            value = avg_ta_time

            content.setContent("out", avg_ta_time)

            return content