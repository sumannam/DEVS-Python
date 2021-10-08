import sys
sys.path.append('D:/Git/DEVS-Python')

# from pypreprocessor import pypreprocessor
# pypreprocessor.parse()

# #define DEBUG


from src.MODELS import MODELS
from src.CO_ORDINATORS import CO_ORDINATORS

class COUPLED_MODELS(MODELS):
    def __init__(self, model_name):
        self.children = []
        MODELS.__init__(self, model_name)
        # PROCESSORS.__init__(self, model_name)

        self.processor = CO_ORDINATORS()
        self.setProcessor(self.processor)
        self.processor.setDevsComponent(self)
    
    def addModel(self, child):
        self.children.append(child)
        child.setParent(self)
        child.getProcessor().setParent(self.getProcessor())
        


        # self.setParent(self)

        # print(self.children)
        # print(child.getParent())
        

        



        # #ifdef DEBUG
        # { print(child.setName()) }
