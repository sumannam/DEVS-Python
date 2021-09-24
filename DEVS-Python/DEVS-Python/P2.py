import math

from ATOMIC_MODELS import ATOMIC_MODELS
from CONTENT import CONTENT


class P2(ATOMIC_MODELS):
    def __init__(self):
        ATOMIC_MODELS.__init__(self, self.__class__.__name__)
        
        self.addInPort("in")
        self.addOutPort( "out" )

        self.sigma=math.inf
        self.phase="passive"
        self.job_id=""
        self.processing_time=10

    def externalTransitionFunc(self, state, elased_time, inport):
        if inport == "in":
            if self.phase == "passive":
                self.job_id = "JOB-1"
                self.holdIn("busy", self.processing_time)
            elif self.phase == "busy":
                self.Continue()

    def internalTransitionFunc(self, state):
        if self.phase == "passive":
            self.passviate()

    def outputFunc(self, state):
        if self.phase == "busy":
            return CONTENT("out", self.job_id)

def main():
    p = P2()
    p.externalTransitionFunc(p.state, 5, "in")


if __name__ == '__main__':
    main()
