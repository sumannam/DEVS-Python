import sys

sys.path.append('D:/Git/DEVS-Python')

from src.MODELS import MODELS
from src.PROCESSORS import PROCESSORS

class COUPLED_MODELS(MODELS):
    children = []

    def __init__(self, model_name):
        MODELS.__init__(self, model_name)
        PROCESSORS.__init__(self, model_name)
    
    def addModel(self, child):
        self.children.append(child)
        # child.setParent(self)
