import PORT

class CONTENT(object):
    _value = ""
    port = PORT("")
    
    def __init__(self, port, value):
        self.port = port
        self._value = value

    def setContent(self, port, value):
        self.port = port
        self._value = value

    def getPort(self):
        return self._port

    def getValue(self):
        return self._value


