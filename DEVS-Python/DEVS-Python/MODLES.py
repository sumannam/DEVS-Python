import ENTITIES
import PORT

class MODELS( ENTITIES ):
    inports = set([]) 
    outports = set([])

    def addInport( self, PORT ):
        if checkPortDuplicate( PORT._name ) == true:
            inports.add( PORT )

    def addOutport( self, PORT ):
        if checkPortDuplicate( PORT._name ) == true:
            outports.add( PORT )

    def checkPortDuplicate( port_name ):
        return port_name not in inports