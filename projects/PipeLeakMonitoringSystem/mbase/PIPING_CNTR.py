from src.ATOMIC_MODELS import *

class PIPING_CNTR(ATOMIC_MODELS):
    def __init__(self):
        ATOMIC_MODELS.__init__(self)
        self.setName(self.__class__.__name__)
        
        self.addInPorts("in", "x1", "x2", "x3", "x4")
        self.addOutPorts("out", "y1", "y2", "y3", "y4")
        
        self.state["sigma"]=math.inf
        self.state["phase"]="passive"
        self.addState("job-id", "")
        self.addState("piping1_state", "passive")
        self.addState("piping2_state", "passive")
        self.addState("piping3_state", "passive")
        self.addState("piping4_state", "passive")
        self.addState("outport", "")
        

    def externalTransitionFunc(self, e, x):
        self.state["job-id"]=x.value
        
        if x.port == "in":
            if(self.state["piping1_state"] == "passive"):
                self.state["piping1_state"] = "busy"
                self.state["outport"] = "x1"             
            elif(self.state["piping2_state"] == "passive"):
                self.state["piping2_state"] = "busy"
                self.state["outport"] = "x2"
            elif(self.state["piping3_state"] == "passive"):
                self.state["piping3_state"] = "busy"
                self.state["outport"] = "x3"
            elif(self.state["piping4_state"] == "passive"):
                self.state["piping4_state"] = "busy"
                self.state["outport"] = "x4"
        elif(x.port == "y1"):
            self.state["piping1_state"] = "passive"
            self.state["outport"] = "out"
        elif(x.port == "y2"):
            self.state["piping2_state"] = "passive"
            self.state["outport"] = "out"
        elif(x.port == "y3"):
            self.state["piping3_state"] = "passive"
            self.state["outport"] = "out"
        
        self.holdIn("busy", 0)

    def internalTransitionFunc(self):
        if self.state["phase"] == "busy":
            self.passviate()

    def outputFunc(self):
        if self.state["phase"] == "busy":
            if( ( self.state["outport"] == "x1") 
                    or self.state["outport"] == "x2" 
                    or self.state["outport"] == "x3" 
                    or self.state["outport"] == "x4" 
                    or self.state["outport"] == "out" ):
                content = CONTENT()
                
                print("Piping_CNTR: ", self.state["outport"])
                print("Piping_CNTR: ", self.state["job-id"])
                
                outport = self.state["outport"]
                content.setContent(outport, self.state["job-id"])
                return content