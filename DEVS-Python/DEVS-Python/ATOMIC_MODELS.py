import math

from MODELS import MODELS
from PORT import PORT
from CONTENT import CONTENT

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
        
    def holdIn(self, _sigma, _phase):
        self.sigma = _sigma
        self.phase = _phase

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
        param = [x for x in input(">>> ").split()]

        type = param[2]

        if type == "inject":
            port_name = param[3]
            value = param[4]
            elased_time = param[5]

            self.send(port_name, value, elased_time)
            print_str = self.sendPrint(type)

        return print_str

    def send(self, port_name, value, time):
        port = PORT(port_name)
        content = CONTENT(port, value)

        self.externalTransitionFunc(self.state, time, content)
        


    def sendPrint(self, type):
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
        
