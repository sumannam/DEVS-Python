import sys
import math

sys.path.append('D:/Git/DEVS-Python')

from src.MODELS import MODELS
from src.PORT import PORT
from src.CONTENT import CONTENT

class ATOMIC_MODELS(MODELS):
    def __init__(self, model_name):
        MODELS.__init__(self, model_name)
    
        self.state = {}
        self.state["sigma"] = math.inf
        self.state["phase"] = "passive"

        self.ta = 0
        self.elapsed_time = 0        

    def addState(self, key, value):
        self.state[key] = value
        
    def holdIn(self, _phase, _sigma):
        self.state["sigma"] = _sigma
        self.state["phase"] = _phase

    def Continue(self, e):
        if self.sigma != math.inf:
            self.sigma = self.sigma - self.e
    
    def passviate(self):
        self.state["sigma"] = math.inf
        self.state["phase"] = "passive"
    
    # s: state, e: elased_time, x: content
    def externalTransitionFunc(self, s, e, x):
        pass

    def internalTransitionFunc(self, s):
        pass

    def outputFunc(self, state):
        pass

    def modelTest(self, model):
    
        while True:
            param = [x for x in input(">>> ").split()]
            type = param[2]

            if type == "inject":
                port_name = param[3]
                value = param[4]
                elased_time = param[5]

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

    def sendInject(self, port_name, value, time):
        port = PORT(port_name)
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

        #print(result)
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
