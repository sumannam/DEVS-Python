class ENTITIES:
    _name = ""

    def __init__(self, name):
        self._name = name

    def getName(self):
        return self._name

    def printName(self):
        print(self._name)
    
    def getEntity(self):
        return self


