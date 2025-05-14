from src.ATOMIC_MODELS import *

class BP(ATOMIC_MODELS):
    def __init__(self, bp_name):
        ATOMIC_MODELS.__init__(self)
        self.model_name = bp_name
        self.setName(self.model_name)
        
        self.addInPorts("in")
        self.addOutPorts("out")
        self.addOutPorts("unsolved")
        
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
        content = CONTENT()
        
        print("self.model_name", self.model_name)
        print("self.state['job-id']", self.state["job-id"])

        
        if self.model_name == "BP3":
            content.setContent("out", self.state["job-id"])
        elif self.state["phase"] == "busy":
            content.setContent("unsolved", self.state["job-id"])
            
        return content