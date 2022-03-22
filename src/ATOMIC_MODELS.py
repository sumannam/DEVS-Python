import math
from abc import abstractmethod

from src.MODELS import MODELS
from src.SIMULATORS import SIMULATORS
from src.CONTENT import CONTENT

class ATOMIC_MODELS(MODELS):
    """! ATOMIC_MODELS class.
    모델링 시 원자 모델들에서 사용할 수 있는 함수들 정의
    """

    def __init__(self):
        MODELS.__init__(self)
        self.processor = SIMULATORS()
        self.setProcessor(self.processor)
        self.processor.setDevsComponent(self)
    
        self.state = {}
        self.state["sigma"] = math.inf
        self.state["phase"] = "passive"

        self.ta = 0
        self.elapsed_time = 0        
    
    def setName(self, name):
        self.processor.setName(name)
        super().setName(name)

    def addState(self, key, value):
        self.state[key] = value
        
    def holdIn(self, phase, sigma):
        self.state["sigma"] = sigma
        self.state["phase"] = phase

    def Continue(self, e):
        """! 
        @fn         Continue
        @brief      외부상태전이함수에서 원자 모델이 실행 중인데 입력이 들어왔을 때 현재 시그마를 계산하는 함수
        @details    현재 시그마 = 이전 시그마 - 경과시간

        @param e    elapsed_time(경과 시간)

        @author     남수만(sumannam@gmail.com)
        @date       2021.05.09        

        @remarks    sigma가 정수인지 실수 계산에 따라 결과 통일(정수일 때는 '.0'이하 제외)[2021.10.20; 남수만]
                    이전 소스 'self.state["sigma"] = self.state["sigma"] - e'로 계산하였으나 "AttributeError: 'P' object has no attribute 'e'"가 발생하여 임시 변수로 계산로 전달[2021.10.03; 남수만]
        
        """
        if self.state["sigma"] != math.inf:
            self.elapsed_time = e
            previous_sigma = self.decideNumberType(self.state["sigma"])
            current_sigma = previous_sigma - self.elapsed_time

            self.state["sigma"] = current_sigma
    
    def passviate(self):
        self.state["sigma"] = math.inf
        self.state["phase"] = "passive"
    
    def timeAdvancedFunc(self):
        self.ta = self.state["sigma"]
        return self.ta

    def modelTest(self, model):
        while True:
            param = [x for x in input(">>> ").split()]
            type = param[2]

            if type == "inject":
                port_name = param[3]
                value = param[4]
                elased_time = self.decideNumberType(param[5])

                self.sendInject(port_name, value, elased_time)
                send_result = self.getInjectResult(type)
            
            if type == "output?":
                output = CONTENT()
                output = self.outputFunc(self.state)
                send_result = self.getOutputResult(output)

            if type == "int-transition":
                self.internalTransitionFunc(self.state)
                send_result = self.getIntTransitionResult()

            if type == "quit":
                break

            print(send_result)

    def decideNumberType(self, time):
        """! 
        @fn         decideNumberType
        @brief      상태변수의 sigma가 정수인지 실수인지 결정
                    (sigma가 정수와 실수의 입력을 모두 허용할 경우 출력의 일관성이 없음)
        @details    실수 값에서 정수 값을 빼서 0이면 정수, 0이 아니면 실수

        @param time    sigma

        @author     남수만(sumannam@gmail.com)
        @date       2021.10.21
        """
        float_time = float(time)
        
        if float_time - int(float_time) == 0:
            return int(time)
        elif float_time - int(float_time) != 0:
            return float(time)
        else:
            return False

    def sendInject(self, port_name, value, time):
        content = CONTENT()
        content.setContent(port_name, value)

        self.externalTransitionFunc(self.state, time, content)

    def getInjectResult(self, type):
        state_list = []
        result = ""

        for s in self.state.values():
            temp_str = str(s)

            state_list.append(temp_str)

        state_str = ' '.join(state_list)

        if type == "inject":
            result = "state s = (" + state_str + ")"

        return result
        
    def getOutputResult(self, content):
        result = "y = " + content.port + " " + content.value
        return result;

    def getIntTransitionResult(self):
        state_list = []
        result = ""

        for s in self.state.values():
            temp_str = str(s)

            state_list.append(temp_str)

        state_str = ' '.join(state_list)
        result = "state s = (" + state_str + ")"

        return result

    # s: state, e: elased_time, x: content
    @abstractmethod
    def externalTransitionFunc(self, e, x):
        pass

    @abstractmethod
    def internalTransitionFunc(self):
        pass

    @abstractmethod
    def outputFunc(self):
        pass