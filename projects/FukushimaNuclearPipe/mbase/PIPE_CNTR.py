from src.ATOMIC_MODELS import *

class PIPE_CNTR(ATOMIC_MODELS):
    def __init__(self):
        ATOMIC_MODELS.__init__(self)
        self.setName(self.__class__.__name__)
        
        self.addInPorts("in", "x1", "x2", "x3", "x4", "x5", "x6", "x7", "x8", "x9", "x10")
        self.addOutPorts("out", "y1", "y2", "y3", "y4", "y5", "y6", "y7", "y8", "y9", "y10")
        
        self.state["sigma"]=math.inf
        self.state["phase"]="passive"
        self.addState("json_job", "")
        self.addState("pipe1_state", "passive")
        self.addState("pipe2_state", "passive")
        self.addState("pipe3_state", "passive")
        self.addState("pipe4_state", "passive")
        self.addState("pipe5_state", "passive")
        self.addState("pipe6_state", "passive")
        self.addState("pipe7_state", "passive")
        self.addState("pipe8_state", "passive")
        self.addState("pipe9_state", "passive")
        self.addState("pipe10_state", "passive")
        
        self.addState("outport", "")        

    def externalTransitionFunc(self, e, x):
        self.state["json_job"]=x.value
        
        if x.port == "in":
            if(self.state["pipe1_state"] == "passive"):
                self.state["pipe1_state"] = "busy"
                self.state["outport"] = "x1"             
            elif(self.state["pipe2_state"] == "passive"):
                self.state["pipe2_state"] = "busy"
                self.state["outport"] = "x2"
            elif(self.state["pipe3_state"] == "passive"):
                self.state["pipe3_state"] = "busy"
                self.state["outport"] = "x3"
            elif(self.state["pipe4_state"] == "passive"):
                self.state["pipe4_state"] = "busy"
                self.state["outport"] = "x4"
            elif(self.state["pipe5_state"] == "passive"):
                self.state["pipe5_state"] = "busy"
                self.state["outport"] = "x5"
            elif(self.state["pipe6_state"] == "passive"):
                self.state["pipe6_state"] = "busy"
                self.state["outport"] = "x6"
            elif(self.state["pipe7_state"] == "passive"):
                self.state["pipe7_state"] = "busy"
                self.state["outport"] = "x7"
            elif(self.state["pipe8_state"] == "passive"):
                self.state["pipe8_state"] = "busy"
                self.state["outport"] = "x8"
            elif(self.state["pipe9_state"] == "passive"):
                self.state["pipe9_state"] = "busy"
                self.state["outport"] = "x9"
            elif(self.state["pipe10_state"] == "passive"):
                self.state["pipe10_state"] = "busy"
                self.state["outport"] = "x10"
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
            self.state["outport"] = "x5"
        elif(x.port == "y5"):
            self.state["pipe5_state"] = "passive"
            self.state["outport"] = "x6"
        elif(x.port == "y6"):
            self.state["pipe6_state"] = "passive"
            self.state["outport"] = "x7"
        elif(x.port == "y7"):
            self.state["pipe7_state"] = "passive"
            self.state["outport"] = "x8"
        elif(x.port == "y8"):
            self.state["pipe8_state"] = "passive"
            self.state["outport"] = "x9"
        elif(x.port == "y9"):
            self.state["pipe9_state"] = "passive"
            self.state["outport"] = "x10"
        elif(x.port == "y10"):
            self.state["pipe10_state"] = "passive"
            self.state["outport"] = "out"
        
        self.holdIn("forwarding", 0)

    def internalTransitionFunc(self):
        if self.state["phase"] == "forwarding":
            self.passviate()

    def outputFunc(self):
        content = CONTENT()
        
        # print("CNTR's OUTPORT: ", self.state["outport"])
        # print("CNTR's JOB's Value: ", self.state["json_job"])
        
        if self.state["phase"] == "forwarding":
            if( ( self.state["outport"] == "x1") 
                        or self.state["outport"] == "x2" 
                        or self.state["outport"] == "x3" 
                        or self.state["outport"] == "x4"
                        or self.state["outport"] == "x5"
                        or self.state["outport"] == "x6"
                        or self.state["outport"] == "x7"
                        or self.state["outport"] == "x8"
                        or self.state["outport"] == "x9"
                        or self.state["outport"] == "x10"
                        or self.state["outport"] == "out"):
                outport = self.state["outport"]
                
                if outport == "out":
                    print(self.__class__.__name__, ": ", outport)
                
                content.setContent(outport, self.state["json_job"])
                
        return content