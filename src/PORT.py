class PORT( object ):
    def __init__(self):
        self.name = ""

    def __eq__( self, PORT ):
        return self.name == PORT.name

    def __eq__( self, _name ):
        return self.name == _name

    def setName(self, name):
        self.name = name
    
    def getName(self):
        return self.name