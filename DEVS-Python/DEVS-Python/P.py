import math
import importlib

from ATOMIC_MODELS import ATOMIC_MODELS
from CONTENT import CONTENT

class P(ATOMIC_MODELS):
    def __init__(self):
        ATOMIC_MODELS.__init__(self, self.__class__.__name__)
        
        self.addInPort("in")
        self.addOutPort( "out" )

        self.state["sigma"]=math.inf
        self.state["phase"]="passive"
        self.addState("job-id", "")
        self.addState("processing_time", 10)

    def externalTransitionFunc(self, s, e, x):
        if x.port == "in":
        #if x.port.__eq__("in"):
            if self.state["phase"] == "passive":
                self.state["job-id"] = x.value
                self.holdIn("busy", self.state["processing_time"])
            elif self.state["phase"] == "busy":
                self.Continue()

    def internalTransitionFunc(self, s):
        if self.state["phase"] == "passive":
            self.passviate()

    def outputFunc(self, s):
        if self.state["phase"] == "busy":
            return CONTENT("out", self.state["job-id"])


if __name__ == '__main__':
    module_name = input()
    module = __import__(module_name)
    class_ = getattr(module, module_name)

    instance = class_()
    instance.modelTest(instance)
