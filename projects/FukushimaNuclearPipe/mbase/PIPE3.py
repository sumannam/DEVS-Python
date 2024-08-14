from src.ATOMIC_MODELS import *
from src.util import *

from queue import Queue
from mqttMsg import MqttMsg


class PIPE3(ATOMIC_MODELS):
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

    # 디지털트윈(유니티)과 연결을 위한 MQTT에 메시지를 전달하는 큐 파라미터 설정[24.08.13; 남수만]
    def __init__(self, msgQueue: Queue):
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
        
        self.unity_model_name = "PIPE114_6000_3"
        self.msgQueue = msgQueue
    
    def externalTransitionFunc(self, e, x):
        if  self.state["phase"] == "passive":
            if x.port == "in":
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
                damage_rate = self.state["damage_rate"]
                damage_rate += 2
                self.state["damage_rate"] = damage_rate
                
            elif type == "tsunami":
                pass
            
            else:
                print("Error: job type is out of range")
            
            self.setCalculatingToNextPhase()

        elif ( self.state["phase"] == "normal" 
                or self.state["phase"] == "warning"
                or self.state["phase"] == "danger" ) :
            self.passviate()
            
        else:
            pass

    def outputFunc(self):
        content = CONTENT()
        
        # TODO: warning and danger phase should be modified
        if ( self.state["phase"] == "normal"
            or self.state["phase"] == "warning"
            or self.state["phase"] == "danger" ) :
            value = convertJsonToString(self.state["job_json"])
            content.setContent("out", value)
        
        return content
        
    def setCalculatingToNextPhase(self):
        damage_rate = self.state["damage_rate"]
        
        if damage_rate < 50:
            self.holdIn("normal", 0)
        elif damage_rate >= 50 and damage_rate <= 70:
            # print(self.job_json)
            # print(self.__class__.__name__, " Warning: Damage rate is between 50 and 70%")
            self.holdIn("warning", 0)
        elif damage_rate > 70:
            id = self.job_json.get("id")
            if id == 50:
                json_payload = json.dumps({"name": self.unity_model_name, "damage": damage_rate})
                self.msgQueue.put(MqttMsg(topic="sim/result/PIPE01", payload=json_payload))
            # print(self.__class__.__name__, " Danger: Damage rate is over 70%")            
            
            self.holdIn("danger", 0)
        else:
            print("Error: Damage rate is out of range")