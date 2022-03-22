import sys
import math

sys.path.append('D:/Git/DEVS-Python')
sys.path.append('D:/Git/DEVS-Python/projects/smartfactory')

from src.ATOMIC_MODELS import ATOMIC_MODELS
from src.CONTENT import CONTENT

class GENR(ATOMIC_MODELS):
    def __init__(self):
        ATOMIC_MODELS.__init__(self)
        self.setName(self.__class__.__name__)

        self.addInPorts("stop")
        self.addOutPorts("out")
        
        self.state["sigma"]=0
        self.state["phase"]="active"
        self.addState("inter_arrival_time", 3)
        
        self.holdIn("active", self.state["sigma"])

        self.count = 1;

    def externalTransitionFunc(self, e, x):
        if x.port == "stop":
            self.passviate()
        else:
            self.Continue(e)

    def internalTransitionFunc(self):
        if self.state["phase"] == "active":
            self.holdIn("active", self.state["inter_arrival_time"])

    def outputFunc(self):
        if self.state["phase"] == "active":
            content = CONTENT()    
            job_id = "JOB-" + str(self.count)
            self.count+=1
            content.setContent("out", job_id)
            return content