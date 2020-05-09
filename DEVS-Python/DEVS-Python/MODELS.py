from ENTITIES import ENTITIES
from PORT import PORT

class MODELS( ENTITIES ):
    inports = list([]) 
    outports = list([])

    def __init__(self):
        inports.clear()
        outports.clear()

    def addInport( self, PORT ):
        if checkPortDuplicate( PORT._name ) == true:
            inports.add( PORT )

    def addOutport( self, PORT ):
        if checkPortDuplicate( PORT._name ) == true:
            outports.add( PORT )

    def checkPortDuplicate( port_name ):
        return port_name not in inports

    def getInports():
        return inports

    def getOutports():
        return outports

    def getInport(port_name):
        port = PORT(port_name)
        if ( port in inports ) == true:
            return port in inports
        else:
            return None

    def getOutport(port_name):
        port = PORT(port_name)
        if ( port in ouports ) == true:
            return port in ouports
        else:
            return None