import math

from MODELS import MODELS

class ATOMIC_MODELS( MODELS ):
    def __init__( self, model_name ):
        MODELS.__init__(self, model_name)
    
        #self.state = {}
        #self.state["sigma"]=math.inf
        #self.state["phase"]="passive"

        self.sigma=math.inf
        self.phase="passive"

        self.ta = 0
        self.elapsed_time = 0        

    def addState(self, key, value):
        self.state[key]=value
        
    def holdIn( self, _sigma, _phase ):
        # processing_time = processing_time
        self.sigma = _sigma
        self.phase = _phase

    def Continue( self, e ):
        if self.sigma != math.inf:
            self.sigma = self.sigma - self.e
    
    def passviate(self):
        #self.state["sigma"]=math.inf
        #self.state["phase"]="passive"
        self.sigma=math.inf
        self.phase="passive"
    
    # s: state, e: elased_time, x: inport
    def externalTransitionFunc(self, state, elased_time, inport):
        print( self.__class__.__name__ + " : " + self.externalTransitionFunc.__name__)

    def internalTransitionFunc(self, state):
        print( self.__class__.__name__ + " : " + self.internalTransitionFunc.__name__)

    def outputFunc(self, state):
        print( self.__class__.__name__ + " : " + self.outputFunc.__name__)


        



