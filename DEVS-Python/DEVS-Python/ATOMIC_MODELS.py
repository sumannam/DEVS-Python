import math

from MODELS import MODELS

class ATOMIC_MODELS( MODELS ):
    sigma = 0
    phase = ""

    ta = 0
    e = 0

    def __init__( self ):
        self.sigma = math.inf
        self.phase = ""

    def setName( seft, _name ):
        self.name = _name

    def holdIn( self, _sigma, _phase ):
        # processing_time = processing_time
        self.sigma = _sigma
        self.phase = _phase

    def Continue( self, e ):
        if self.sigma != math.inf:
            self.sigma = self.sigma - e
    
    def passviate():
        self.sigma = math.inf
        self.phase = "passive"

    def externalTransitionFunc():
        printf( "ATOMIC_MODELS: externalTransitionFunc() ")





        



