from src.ATOMIC_MODELS import *

class IP(ATOMIC_MODELS):
    def __init__(self):
        ATOMIC_MODELS.__init__(self)
        self.setName(self.__class__.__name__)
        
        self.addInPorts("in")
        self.addInPorts("urgent")
        self.addOutPorts("out")
        self.addOutPorts("message")
        
        self.state["sigma"]=math.inf
        self.state["phase"]="passive"
        self.addState("job-id", "")
        self.addState("temp", "")
        self.addState("processing_time", 10)
        self.addState("time_remaining", 0)
        self.addState("interrupthandling_time", 0.1)

    def externalTransitionFunc(self, e, x):
        if x.port == "in":
            if self.state["phase"] == "passive":
                self.state["job-id"] = x.value
                self.state["time_remaining"] = self.state["processing_time"]
                self.holdIn("busy", self.state["processing_time"])
            elif self.state["phase"] == "busy":
                self.state["time_remaining"] = self.state["time_remaining"] - e
                self.state["temp"] = x.value
                self.holdIn("interrupted", self.state["interrupthandling_time"])
            elif self.state["phase"] == "interrupted":
                self.Continue(e)
        elif x.port == "urgent":
            if self.state["phase"] == "passive":
                self.state["job-id"] = x.value
                self.state["time_remaining"] = self.state["processing_time"]
                self.holdIn("busy", self.state["processing_time"])
            else:
                self.Continue(e)


    def internalTransitionFunc(self):
        if self.state["phase"] == "busy":
            self.passviate()
        elif self.state["phase"] == "interrupted":
            self.holdIn("busy", self.state["time_remaining"])
        else:
            self.passviate()

    def outputFunc(self):
        content = CONTENT()

        if self.state["phase"] == "busy":    
            content.setContent("out", self.state["job-id"])
        elif self.state["phase"] == "interrupted":
            id = "interrupted by " + self.state["temp"]
            content.setContent("message", id)

        return content