from src.ATOMIC_MODELS import *

class PIPE_CNTR(ATOMIC_MODELS):
    def __init__(self):
        ATOMIC_MODELS.__init__(self)
        self.setName(self.__class__.__name__)
        
        self.addInPorts("in", "x1", "x2", "x3", "x4")
        self.addOutPorts("out", "y1", "y2", "y3", "y4")
        
        self.state["sigma"]=math.inf
        self.state["phase"]="passive"
        self.addState("job-id", "")
        self.addState("pipe1_state", "passive")
        self.addState("pipe2_state", "passive")
        self.addState("pipe3_state", "passive")
        self.addState("pipe4_state", "passive")
        self.addState("outport", "")
        

    def externalTransitionFunc(self, e, x):
        self.state["job-id"]=x.value
        # print("pipe_CNTR: ", self.state["job-id"])
        
        if x.port == "in":
            if(self.state["pipe1_state"] == "passive"):
                self.state["pipe1_state"] = "busy"
                self.state["outport"] = "x1"             
        elif(x.port == "y1"):
            self.state["pipe1_state"] = "passive"
            self.state["outport"] = "x2"
        elif(x.port == "y2"):
            self.state["pipe2_state"] = "passive"
            self.state["outport"] = "x3"
        elif(x.port == "y3"):
            self.state["pipe3_state"] = "passive"
            self.state["outport"] = "x4"
        elif(x.port == "y4"):
            self.state["pipe4_state"] = "passive"
            self.state["outport"] = "out"
        
        self.holdIn("forwarding", 0)

    def internalTransitionFunc(self):
        if self.state["phase"] == "forwarding":
            self.passviate()

    def outputFunc(self):
        print("CNTR's OUTPORT: ", self.state["outport"])
        print("CNTR's JOB: ", self.state["job-id"])
        
        if self.state["phase"] == "forwarding":
            if( ( self.state["outport"] == "x1") 
                        or self.state["outport"] == "x2" 
                        or self.state["outport"] == "x3" 
                        or self.state["outport"] == "x4"
                        or self.state["outport"] == "out"):
                content = CONTENT()
                
                outport = self.state["outport"]
                content.setContent(outport, self.state["job-id"])
                return content