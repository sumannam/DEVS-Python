class PORT( object ):
    _name = ""

    def __init__( self, name ):
        _name = name

    def __eq__( self, PORT ):
        return self._name == PORT._name




