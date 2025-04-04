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

        # 커플링 정보 설정
        self.external_output_coupling = COUPLING()
        self.external_input_coupling = COUPLING()
        self.internal_coupling = COUPLING()


    def setName(self, name):
        self.processor.setName(name)
        super().setName(name)


    def addModel(self, child):
        """! 
        @fn         addModel
        @brief      자식 모델 추가
        @details    추가 순서대로 우선순위 결정
 			    	
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
    
    def getChildModelNameList(self):
        """! 
        @fn         getChildModelNameList
        @brief      결합 모델 테스트를 위한 자식 모델 이름 추출
        @details    
        
        @reference  https://github.com/sumannam/DEVS-Python/issues/31

        @author     남수만(sumannam@gmail.com)
        @date       2025.01.22
        """
        child_list = []
        for child in self.child_list:
            child_list.append(child.getName())
        return child_list


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


    def getPriorityList(self):
        return self.priority_list
    
    
    def getPrioriryModelNameList(self):
        """! 
        @fn         getPrioriryModelNameList
        @brief      결합 모델 테스트를 위한 우선순위 모델 이름 추출
        @details    
        
        @reference  https://github.com/sumannam/DEVS-Python/issues/31

        @author     남수만(sumannam@gmail.com)
        @date       2025.01.22
        """
        priority_list = []
        for model in self.priority_list:
            priority_list.append(model.getName())
        return priority_list


    def initialize(self):
        processor = self.getProcessor()
        parent = processor.getParent()
        parent.initialize()


    def getClockBase(self):
        """! 
        @fn         getClockBase()
        @brief      Root-Coodinator로부터 clock_base 시간 얻기
        @details    testROOT_CO_ORDINATORS.py에서 testInitialize()를 위해 사용

        @return     시뮬레이션 초기 시간

        @author     남수만(sumannam@gmail.com)
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
        @brief      한 결합 모델에서 출력과 연결된 커플링 정보가 있는지 확인
        @details    

        @return     한 커플링(모델과 포트) 정보

        @author     남수만(sumannam@gmail.com)
        @date       2021.11.01

        @todo       함수명 수정(hasOutputCopling -> hasOutputCoupling) [완료: 22.05.31; 남수만] [작성: 22.05.31; 남수만] 
        """
        model_port_name = None
        model_port_name = self.getModelPortName(src_model, port)
        
        if self.internal_coupling.find(model_port_name) == True:
            return self.internal_coupling.find(model_port_name)
        if self.external_output_coupling.find(model_port_name) == True:
            return self.external_output_coupling.find(model_port_name)

    def getDestinationCoupling(self, src_model, port):
        """! 
        @fn         getDestinationCoupling()
        @brief      단위 테스트를 위한 
        @details    

        @return     

        @author     남수만(sumannam@gmail.com)
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
        @brief      커플링 유형(EOC, EIC, IC)에 따라 입력된 model, port와 연결된 커플링 정보 반환
        @details    

        @return     커플링(모델과 포트) 리스트 정보

        @author     남수만(sumannam@gmail.com)
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