import random

from src.ATOMIC_MODELS import ATOMIC_MODELS
from src.CONTENT import CONTENT
from src.util import convertJsonToString


class GENR(ATOMIC_MODELS):
    def __init__(self):
        ATOMIC_MODELS.__init__(self)
        self.setName(self.__class__.__name__)

        self.addInPorts("stop")
        self.addOutPorts("out")
        
        self.state["sigma"]=2
        self.state["phase"]="active"
        self.addState("inter_arrival_time", 2)
        
        self.holdIn("active", self.state["sigma"])

        self.count = 1;
        
        # seed(1) is 지진 7.5 발생
        # seed(2) is 지진 발생 없음
        # seed(3) is 지진 7.0 발생  
        random.seed(1)

    def externalTransitionFunc(self, e, x):
        if x.port == "stop":
            self.passviate()
        else:
            self.Continue(e)

    def internalTransitionFunc(self):
        if self.state["phase"] == "active":
            self.holdIn("active", self.state["inter_arrival_time"])

    def outputFunc(self):
        if self.state["phase"] == "active":
            content = CONTENT()
            content_value = self.generateJobs()
            content.setContent("out", content_value)
            return content

    def generateJobs(self):
        job_dict = {}
        job_dict["id"] = self.count
        
        random_number = random.randint(0, 999)
        
        random_number = 1
        
        if random_number < 5:
            # 지진 7.5 규모로 쓰나미 발생
            job_dict["type"] = "tsunami"
            job_dict["earthquake"] = 7.5
            # job_dict["tsunamiPoint"] = self.getTsunamiPoint()
            job_dict["tsunamiPoint"] = 1

        elif random_number < 25:
            # 지진 7.0 규모로 쓰나미 발생
            job_dict["type"] = "tsunami"
            job_dict["earthquake"] = 7.0
            job_dict["tsunamiPoint"] = self.getTsunamiPoint()
            
        elif random_number < 1000:
            job_dict["type"] = "water"
            job_dict["earthquake"] = -1
            job_dict["tsunamiPoint"] = -1
            
        else:
            print("Random number is out of range")
            
        self.count += 1        
        json_str = convertJsonToString(job_dict)
        
        return json_str
    
    def getTsunamiPoint(self):
        return random.randint(1, 10)