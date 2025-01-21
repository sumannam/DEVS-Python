from src.CO_ORDINATORS import CO_ORDINATORS
from src.MODELS import MODELS
from src.COUPLING import *

class COUPLED_MODELS(MODELS):
    def __init__(self):
        MODELS.__init__(self)
        self.child_list = []
        # PROCESSORS.__init__(self, model_name)

        self.processor = CO_ORDINATORS()
        self.setProcessor(self.processor)
        self.processor.setDevsComponent(self)
        self.priority_list = []

        # 커플맕보 �정
        self.external_output_coupling = COUPLING()
        self.external_input_coupling = COUPLING()
        self.internal_coupling = COUPLING()


    def setName(self, name):
        self.processor.setName(name)
        super().setName(name)


    def addModel(self, child):
        """! 
        @fn         addModel
        @brief      �식 모델 추�
        @details    추� �서�롰선�위 결정
        """
        self.child_list.append(child)
        child.setParent(self)
        child.getProcessor().setParent(self.getProcessor())
        self.processor.addChild(child.getProcessor())
        self.priority_list.append(child)


    def getModels(self):
        return self.child_list


    def existChildModel(self, child):
        if(child == None):
            return False
        
        if (child in self.child_list) == True:
            return True
        else:
            return False
        
    def getChildModel(self, child_name):
        for child in self.child_list:
            if child.getName() == child_name:
                return child
        return None


    def addCoupling(self, src_model, src_port, dst_model, dst_port):
        """! 
        @fn         addCoupling
        @brief      모델커플맠형 분류 �추�
        @details    커플링의 관계는 �음�같이 ��된
 			    	Coupling Type  | �용
 		    		---------------------------------
 	    			IC     		   | src_model�dst_model 모두 �식
                    EOC            | src_model말식
                    EIC            | dst_model말식

        @param from_model   �스 모델
        @param from_port    �스 모델�트
        @param to_model     목적지 모델
        @param to_port      목적지 모델�트

        @author     �수�sumannam@gmail.com)
        @date       2021.10.15        

        @todo       추�port롅력�었�� 검즄요 [�수�2021.10.26]
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


    def getPriorityList(self):
        return self.priority_list


    def initialize(self):
        processor = self.getProcessor()
        parent = processor.getParent()
        parent.initialize()


    def getClockBase(self):
        """! 
        @fn         getClockBase()
        @brief      Root-Coodinator로�clock_base �간 �기
        @details    testROOT_CO_ORDINATORS.py�서 testInitialize()륄해 �용

        @return     ��이초기 �간

        @author     �수�sumannam@gmail.com)
        @date       2021.11.16
        """
        processor = self.getProcessor()
        parent = processor.getParent()
        return parent.getClockBase()


    def restart(self):
        processor = self.getProcessor()
        parent = processor.getParent()
        parent.restart()


    def hasOutputCoupling(self, src_model, port):
        """! 
        @fn         hasOutputCoupling()
        @brief      결합 모델�서 출력곰결커플맕보가 �는지 �인
        @details    

        @return     커플�모델곬트) �보

        @author     �수�sumannam@gmail.com)
        @date       2021.11.01

        @todo       �수몘정(hasOutputCopling -> hasOutputCoupling) [�료: 22.05.31; �수� [�성: 22.05.31; �수� 
        """
        model_port_name = None
        model_port_name = self.getModelPortName(src_model, port)
        
        print(model_port_name)
        

    def getDestinationCoupling(self, src_model, port):
        """! 
        @fn         getDestinationCoupling()
        @brief      �위 �스�� �한 
        @details    

        @return     

        @author     �수�sumannam@gmail.com)
        @date       2024.04.15

        @todo       
        """
        model_port_name = self.getModelPortName(src_model, port)
        
        model_port_list = []
        
        # if model_port_name == "TRANSD.out":
        #     print(model_port_name)
        
        if self.external_output_coupling.get(model_port_name) != None:
            model_port = ''.join(self.external_output_coupling.get(model_port_name))
            model_port_list.append(model_port)
            
        if self.external_input_coupling.get(model_port_name) != None:
            model_port = ''.join(self.external_input_coupling.get(model_port_name))
            model_port_list.append(model_port)
            
        if self.internal_coupling.get(model_port_name) != None:            
            model_port = ''.join(self.internal_coupling.get(model_port_name))
            model_port_list.append(model_port)
        
        if model_port_list == None:
            print("ERROR: getDestinationCoupling")        
        
        return model_port_list        


    def translate(self, coupling_type, model, port):
        """! 
        @fn         translate()
        @brief      커플맠형(EOC, EIC, IC)�라 �력model, port� �결커플맕보 반환
        @details    

        @return     커플�모델곬트) 리스�보

        @author     �수�sumannam@gmail.com)
        @date       2021.11.01
        """
        model_port_list = []
        model_port_name = self.getModelPortName(model, port)

        if coupling_type == COUPLING_TYPE.EOC:
            model_port_list = self.external_output_coupling.get(model_port_name)
        if coupling_type == COUPLING_TYPE.EIC:
            model_port_list = self.external_input_coupling.get(model_port_name)
        if coupling_type == COUPLING_TYPE.IC:
            model_port_list = self.internal_coupling.get(model_port_name)        

        return model_port_list