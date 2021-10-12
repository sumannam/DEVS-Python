import sys
sys.path.append('D:/Git/DEVS-Python')

# from pypreprocessor import pypreprocessor
# pypreprocessor.parse()

# #define DEBUG


from src.MODELS import MODELS
from src.CO_ORDINATORS import CO_ORDINATORS

class COUPLED_MODELS(MODELS):
    def __init__(self, model_name):
        self.child_list = []
        MODELS.__init__(self, model_name)
        # PROCESSORS.__init__(self, model_name)

        self.processor = CO_ORDINATORS()
        self.setProcessor(self.processor)
        self.processor.setDevsComponent(self)
    
    def addModel(self, child):
        self.child_list.append(child)
        child.setParent(self)
        child.getProcessor().setParent(self.getProcessor())
        
    def existChildModel(self, child):
        if(child==None):
            return False
    
    def addCoupling(self, src_model, src_port, dst_model, dst_port):
        if(src_model==dst_model):
            print("Source Model and Destination Model of Addcoupling are the same.")
            return False
        
        if(src_model!=self & self.existChildModel(src_model)==False):
            print("Source Model of Addcoupling does not exist in the coupled model.")
        
        if(dst_model!=self & self.existChildModel(dst_model)==False):
            print("Destination Model of Addcoupling does not exist in the coupled model.")

        if(self.existChildModel(src_model) & self.existChildModel(dst_model)):

            # RELATION 클래스 생성





        # self.setParent(self)

        # print(self.children)
        # print(child.getParent())
        

        



        # #ifdef DEBUG
        # { print(child.setName()) }
