import math

from ATOMIC_MODELS import ATOMIC_MODELS
from CONTENT import CONTENT


class P(ATOMIC_MODELS):
    def __init__(self):
        ATOMIC_MODELS.__init__(self, self.__class__.__name__)
        
        self.addInPort("in")
        self.addOutPort( "out" )

        self.state["sigma"]=math.inf
        self.state["phase"]="passive"
        self.addState("job-id", "")
        self.addState("processing_time", 10)

    def externalTransitionFunc(self, state, elased_time, inport):
        if inport == "in":
            if self.state["phase"] == "passive":
                self.state["job-id"] = "JOB-1"
                self.holdIn("busy", state["processing_time"])
            elif self.state["phase"] == "busy":
                self.Continue()

    def internalTransitionFunc(self, state):
        if self.state["phase"] == "passive":
            self.passviate()

    def outputFunc(self, state):
        if self.state["phase"] == "busy":
            return CONTENT("out", self.state["job-id"])

def main():
    p = P()
    p.externalTransitionFunc(p.state, 5, "in")


if __name__ == '__main__':
    main()
