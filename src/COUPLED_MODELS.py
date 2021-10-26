import sys
sys.path.append('D:/Git/DEVS-Python')

from src.CO_ORDINATORS import CO_ORDINATORS
from src.MODELS import MODELS
from src.COUPLING import COUPLING

# from pypreprocessor import pypreprocessor
# pypreprocessor.parse()


class COUPLED_MODELS(MODELS):
    def __init__(self, model_name):
        self.child_list = []
        MODELS.__init__(self, model_name)
        # PROCESSORS.__init__(self, model_name)

        self.processor = CO_ORDINATORS()
        self.setProcessor(self.processor)
        self.processor.setDevsComponent(self)

        # 커플링 정보 설정
        self.external_output_coupling = COUPLING()
        self.external_input_coupling = COUPLING()
        self.internal_coupling = COUPLING()

    def addModel(self, child):
        self.child_list.append(child)
        child.setParent(self)
        child.getProcessor().setParent(self.getProcessor())

    def getModels(self):
        return self.child_list

    def existChildModel(self, child):
        if(child == None):
            return False
        
        if (child in self.child_list) == True:
            return True
        else:
            return False

    def addCoupling(self, src_model, src_port, dst_model, dst_port):
        """! 
        @fn         addCoupling
        @brief      모델의 커플링 유형 분류 및 추가
        @details    커플링의 관계는 다음과 같이 저장된다.
 			    	Coupling Type  | 내용
 		    		---------------------------------
 	    			IC     		   | src_model과 dst_model 모두 자식일 때
                    EOC            | src_model만 자식일 때
                    EIC            | dst_model만 자식일 때

        @param from_model   소스 모델
        @param from_port    소스 모델의 포트
        @param to_model     목적지 모델
        @param to_port      목적지 모델의 포트

        @author     남수만(sumannam@gmail.com)
        @date       2021.10.15        

        @todo       추가된 port로 입력이 되었는지 검증 필요 [남수만;2021.10.26]
        """
        if(src_model == dst_model):
            print("Source Model and Destination Model of Addcoupling are the same.")
            return False
        if(src_model != self and self.existChildModel(src_model) == False):
            print("Source Model of Addcoupling does not exist in the coupled model.")
            return False
        if(dst_model != self and self.existChildModel(dst_model) == False):
            print("Destination Model of Addcoupling does not exist in the coupled model.")
            return False

        if(self.existChildModel(src_model)==True and self.existChildModel(dst_model)==True):
            # (IC) Internal Coupling
            self.internal_coupling.addCoupling(src_model, src_port, dst_model, dst_port)
        elif(self.existChildModel(src_model)==True and self.existChildModel(dst_model)==False):
            # (EOC) External Output Coupling
            self.external_output_coupling.addCoupling(src_model, src_port, dst_model, dst_port)
        elif(self.existChildModel(src_model)==False and self.existChildModel(dst_model)==True):
            # (EIC) External Input Coupling
            self.external_input_coupling.addCoupling(src_model, src_port, dst_model, dst_port)
        else:
            print("ERROR: Coupling Addition")
            return False

    def getInternalCoupling(self):
        return self.internal_coupling