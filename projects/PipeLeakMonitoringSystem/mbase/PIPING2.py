from src.ATOMIC_MODELS import *

class PIPING2(ATOMIC_MODELS):
    def __init__(self):
        ATOMIC_MODELS.__init__(self)
        self.setName(self.__class__.__name__)
        
        self.addInPorts("in")
        self.addOutPorts("out")
        
        self.state["sigma"]=math.inf
        self.state["phase"]="passive"
        self.addState("job-id", "")
        self.addState("processing_time", 10)

    def externalTransitionFunc(self, e, x):
        if x.port == "in":
            if self.state["phase"] == "passive":
                self.state["job-id"] = x.value
                self.holdIn("busy", self.state["processing_time"])
            elif self.state["phase"] == "busy":
                self.Continue(e)

    def internalTransitionFunc(self):
        if self.state["phase"] == "busy":
            self.passviate()

    def outputFunc(self):
        if self.state["phase"] == "busy":
            content = CONTENT()
            content.setContent("out", self.state["job-id"])
            return content