import sys

import src.PORT

class CONTENT(object):
    def __init__(self):
        self.value = ""
        self.port = ""
        pass

    def setContent(self, port, value):
        self.port = port
        self.value = value
    
    def getPort(self):
        return self.port

    def getValue(self):
        return self.value


