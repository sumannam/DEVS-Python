import sys
from enum import Enum

from src.CONTENT import CONTENT

class MESSAGE_TYPE(Enum):
    STAR = '*'
    EXT = 'Ext'
    Done = 'Done'
    X = "X"
    Y = "Y"    

class MESSAGE():
    def __init__(self):
        self.type = None
        self.source = None
        self.time = -1
        self.content = CONTENT()
    
    def setRootStar(self, type, time):
        self.type = type
        self.time = time
    
    def setStar(self, type, model, time):
        self.type = type
        self.source = model
        self.time = time

    def setExt(self, type, model, time):
        self.type = type
        self.source = model
        self.time = time

    def setDone(self, type, model, time):
        self.type = type
        self.source = model
        self.time = time
    
    def getType(self):
        return self.type;

    def getSource(self):
        return self.source

    def getTime(self):
        return self.time
    
    def getContent(self):
        return self.content    

    def addContent(self, content):
        self.content=content
