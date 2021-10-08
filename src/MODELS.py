import sys

sys.path.append('D:/Git/DEVS-Python')

from src.ENTITIES import ENTITIES
from src.PROCESSORS import PROCESSORS
from src.PORT import PORT

class MODELS(ENTITIES):
    def __init__(self, model_name):
        self.name = model_name

        self.processor = PROCESSORS()
        self.parent = None;

        self.inport_list = []
        self.outport_list = []

    def setProcessor(self, processor):
        self.processor = processor

    def getProcessor(self):
        return self.processor
    
    def addInPort(self, port_name):
        """! 
        @fn         addOutPort
        @brief      모델의 입력 port 정의
        @details    port 이름으로 port 추가

        @param port_name    port 이름

        @author     남수만(sumannam@gmail.com)
        @date       2021.10.06      
        """
        if port_name not in self.inport_list:
            self.inport_list.append(port_name)

    def addOutPort(self, port_name):
        """! 
        @fn         addOutPort
        @brief      모델의 출력 port 정의
        @details    port 이름으로 port 추가

        @param port_name    port 이름

        @author     남수만(sumannam@gmail.com)
        @date       2021.10.06      
        """
        if port_name not in self.outport_list:
            self.outport_list.append(port_name)

    def getInports(self):
        return self.inport_list

    def getOutports(self):
        return self.outport_list

    def getInport(self, port_name):
        """! 
        @fn         getInport
        @brief      모델의 입력 port 얻기
        @details    port 이름으로 입력 port 인스턴스 반환

        @param port_name    port 이름

        @return     port 인스턴스

        @author     남수만(sumannam@gmail.com)
        @date       2021.10.06      
        """
        port = PORT(port_name)
        if (port in self.inport_list) == True:
            return port in self.inport_list
        else:
            return None

    def getOutport(self, port_name):
        """! 
        @fn         getOutport
        @brief      모델의 출력 port 얻기
        @details    port 이름으로 출력 port 인스턴스 반환

        @param port_name    port 이름

        @return     port 인스턴스

        @author     남수만(sumannam@gmail.com)
        @date       2021.10.06      
        """
        port = PORT(port_name)
        if (port in self.outport_list) == True:
            return port in self.outport_list
        else:
            return None

    def setParent(self, model):
        """! 
        @fn         setParent
        @brief      부모 모델 설정
        @details    한 결합모델에서 한 자식 모델을 추가할 때 현재 결합모델을 부모 모델로 설정

        @param model    부모모델

        @author     남수만(sumannam@gmail.com)
        @date       2021.10.06      
        """
        self.parent = model

    def getParent(self):
        """! 
        @fn         getParent
        @brief      부모 모델 전달
        @details    현재 부모 모델 전달

        @return     부모모델

        @author     남수만(sumannam@gmail.com)
        @date       2021.10.08      
        """
        return self.parent