class PORT( object ):
    def __init__( self, _name ):
        self.name = _name

    def __eq__( self, PORT ):
        return self.name == PORT.name

    def __eq__( self, _name ):
        return self.name == _name