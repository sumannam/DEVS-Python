import re
import inspect

from src.ATOMIC_MODELS import *
from src.util import *

from queue import Queue
from mqttMsg import MqttMsg


class PIPE10(ATOMIC_MODELS):
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
        
        self.unity_model_name = "PIPE114_6000_10"
        self.msgQueue = msgQueue
    
    def externalTransitionFunc(self, e, x):
        # damage_rate가 100이 넘으면 배관이 파손되었다고 판단
        damage_rate = self.state["damage_rate"]
        if damage_rate >= 100:
            self.Continue(e)
        
        if  self.state["phase"] == "passive":
            if x.port == "in":
                self.job_json = convertStringToJson(x.value)
                self.state["job_json"] = self.job_json               
                self.holdIn("calculating", self.state["processing_time"])            
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
                self.getTsunami()
            
            else:
                print(f"파일명: {__file__} / ", f"소스 라인: {inspect.currentframe().f_lineno}")
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
                self.msgQueue.put(MqttMsg(topic="sim/result/PIPE10", payload=json_payload))
                # print(self.__class__.__name__, " Danger: Damage rate is over ", damage_rate, "%")
            
            self.holdIn("danger", 0)
        else:
            print(f"파일명: {__file__} / ", f"소스 라인: {inspect.currentframe().f_lineno}")
            print("Error: Damage rate is out of range")
    
    def getTsunami(self):
        tsunami_point = int(self.job_json.get("tsunamiPoint"))
        model_id = re.sub(r'\D', '', self.unity_model_name.replace("PIPE114_6000_", ""))
        
        if model_id.isdigit():
            model_id = int(model_id)
            damage_rate = self.state["damage_rate"]
            
            # A급 피해 : 쓰나미 직접 피해
            if model_id == tsunami_point:
                damage_rate = self.addDamageRate(damage_rate, 50)
            
            # B급 피해 : 쓰나미 초간접 피해
            elif model_id == tsunami_point-2:
                damage_rate = self.addDamageRate(damage_rate, 30)
            elif model_id == tsunami_point-1:
                damage_rate = self.addDamageRate(damage_rate, 30)
            elif model_id == tsunami_point+1:
                damage_rate = self.addDamageRate(damage_rate, 30)
            elif model_id == tsunami_point+2:
                damage_rate = self.addDamageRate(damage_rate, 30)
            
            # C급 피해 : 쓰나미 간접 피해    
            elif model_id in range(1, 11): # 1~10
                damage_rate = self.addDamageRate(damage_rate, 10)
            
            else:
                print(f"파일명: {__file__} / ", f"라인: {inspect.currentframe().f_lineno}")
                print("Tsunami Point is out of range")
                
            self.state["damage_rate"] = damage_rate
    
    def addDamageRate(self, current_damage, add_damage):
        current_damage += add_damage
        
        if current_damage > 100:
            current_damage = 100
        
        return current_damage        