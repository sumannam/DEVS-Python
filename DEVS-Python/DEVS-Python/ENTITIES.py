class ENTITIES:
    name = ""

    def __init__( self, _name ):
        self.name = _name

    def getName( self ):
        return self.name

    def printName( self ):
        print( self.name )
    
    def getEntity( self ):
        return self