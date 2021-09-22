from ATOMIC_MODELS import ATOMIC_MODELS
from PORT import PORT

class P( ATOMIC_MODELS ):
    job_id = ""
    processing_time = 0
    
    def __init__( self ):
        self.setName( "P" )
        in_port = PORT( "in" )
        out_port = PORT( "out" )

        self.addInport( in_port )
        self.addOutport( out_port )

        self.sigma = inf.math
        self.phase = "passive"
        self.job_id = ""
        self.processing_time = 10

    def externalTransitionFunc( e, x ):
        #if in_port == 여기부터 작성
        print( "externalTransitionFunc" )
