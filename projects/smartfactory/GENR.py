import sys
import random
import math

sys.path.append('D:/Git/DEVS-Python')
sys.path.append('D:/Git/DEVS-Python/projects/smartfactory')

from src.ATOMIC_MODELS import ATOMIC_MODELS
from src.CONTENT import CONTENT

class GENR(ATOMIC_MODELS):
    def __init__(self):
        ATOMIC_MODELS.__init__(self)
        self.setName(self.__class__.__name__)

        self.addInPorts("stop")
        self.addOutPorts("out")
        
        self.state["sigma"]=0
        self.state["phase"]="active"
        self.addState("inter_arrival_time", 3)
        
        self.holdIn("active", self.state["sigma"])

        self.count = 1;

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

            job_id = self.generateJobs()
           
            self.count+=1
            content.setContent("out", job_id)
            return content
    

    def generateJobs(self):
        """! 
        @fn         generateJobs
        @brief      확률적으로 JOB 또는 ATT 생성
        @details    랜덤 값이 1이면 공격 수행

        @author     남수만(sumannam@gmail.com)
        @date       2022.03.22        
        """
        # 확률적 공격 실행
        random_attack = random.randrange(1, 11)
        if random_attack == 1:
            job_id = "ATT-" + str(self.count)
        else:
            job_id = "JOB-" + str(self.count)
        
        return job_id