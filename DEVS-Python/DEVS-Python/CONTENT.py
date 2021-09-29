import PORT

class CONTENT(object):
    value = ""
    port = ""
    #port = PORT("")

    def __init__(self):
        pass

    def setContent(self, port, value):
        self.port = port
        self.value = value
    
    def getPort(self):
        return self.port

    def getValue(self):
        return self.value


