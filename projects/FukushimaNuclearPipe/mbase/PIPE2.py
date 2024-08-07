from src.ATOMIC_MODELS import *
from src.util import *

class PIPE2(ATOMIC_MODELS):
    def __init__(self):
        ATOMIC_MODELS.__init__(self)
        self.setName(self.__class__.__name__)
        
        self.addInPorts("in", "tsunami_in")
        self.addOutPorts("out", "tsunami_out")
        
        self.state["sigma"]=math.inf
        self.state["phase"]="passive"
        self.addState("job_json", "")
        self.addState("damage_rate", 0)
        self.addState("processing_time", 0.1)
        
        self.job_json = {}

    def externalTransitionFunc(self, e, x):
        if  self.state["phase"] == "passive":
            if x.port == "in":
                print(x.value)
                self.job_json = convertStringToJson(x.value)
                self.state["job_json"] = self.job_json               
                self.holdIn("calculating", self.state["processing_time"])
                
            elif x.port == "tsunami_in":
                pass
            
        else:
            self.Continue(e)

    def internalTransitionFunc(self):
        if self.state["phase"] == "calculating":
            type = self.job_json.get("type")
            
            if type == "water":
                damage_rate = 0
                damage_rate += 2
                self.state["damage_rate"] = damage_rate
                
            elif type == "tsunami":
                pass
            
            else:
                print("Error: job type is out of range")
            
            self.setCalculatingToNextPhase()

        elif self.state["phase"] == "normal":
            self.passviate()
            
        else:
            pass

    def outputFunc(self):
        content = CONTENT()
        
        if self.state["phase"] == "normal":
            value = convertJsonToString(self.state["job_json"])
            content.setContent("out", value)
        
        return content
        
    def setCalculatingToNextPhase(self):
        damage_rate = self.state["damage_rate"]
        
        if damage_rate < 30:
            self.holdIn("normal", 0)
        elif damage_rate < 50:
            self.holdIn("warning", 0)
        elif damage_rate < 70:
            self.holdIn("danger", 0)
        else:
            print("Error: Damage rate is out of range")