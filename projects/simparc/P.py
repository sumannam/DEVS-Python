import sys
import math

sys.path.append('D:/Git/DEVS-Python')
sys.path.append('D:/Git/DEVS-Python/projects/simparc')

from src.ATOMIC_MODELS import ATOMIC_MODELS
from src.CONTENT import CONTENT
from src.PORT import PORT

class P(ATOMIC_MODELS):
    def __init__(self):
        ATOMIC_MODELS.__init__(self)
        self.setName(self.__class__.__name__)
        
        self.addInPorts("in")
        self.addOutPorts("out")
        
        self.state["sigma"]=math.inf
        self.state["phase"]="passive"
        self.addState("job-id", "")
        self.addState("processing_time", 10)

    def externalTransitionFunc(self, s, e, x):
        if x.port == "in":
            if s["phase"] == "passive":
                s["job-id"] = x.value
                self.holdIn("busy", s["processing_time"])
            elif s["phase"] == "busy":
                self.Continue(e)

    def internalTransitionFunc(self, s):
        if s["phase"] == "busy":
            self.passviate()

    def outputFunc(self, s):
        if s["phase"] == "busy":
            content = CONTENT()
            content.setContent("out", s["job-id"])
            return content


# if __name__ == '__main__':
#     module_name = input()
#     module = __import__(module_name)
#     _class = getattr(module, module_name)

#     instance = _class()
#     instance.modelTest(instance)