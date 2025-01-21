import sys
import math
from abc import abstractmethod

from devsbase.ENTITIES import ENTITIES

class PROCESSORS(ENTITIES):

    def __init__(self):
        self.parent = None # 자신의 상위 모델 클래스를 가리키는 포인터
        self.devs_component = None

        self.time_last = 0 # 최근 발생한 이벤트 시간
        self.time_next = math.inf # 다음 이벤트 발생 시간

        self.runtime = 0

    def setParent(self, processor):
        """! 
        @fn         setParent()
        @brief      부모 프로세서 주소 설정
        @details    시뮬레이션 과정에서 부모 프로세스 접근 시 사용

        @author     남수만(sumannam@gmail.com)
        @date       2021.11.16
        """
        self.parent = processor
    
    def getParent(self):
        """! 
        @fn         getParent()
        @brief      부모 프로세서 주소 전달
        @details    시뮬레이션 과정에서 부모 프로세스 접근 시 사용

        @return     부모 프로세스 전환

        @author     남수만(sumannam@gmail.com)
        @date       2021.11.16
        """
        return self.parent

    def setDevsComponent(self, model):
        """! 
        @fn         setDevsComponent()
        @brief      1:1로 매핑된 모델 요소 설정
        @details    시뮬레이션 과정에서 모델 주소 접근 시 사용

        @return     모델 요소 반환

        @author     남수만(sumannam@gmail.com)
        @date       2021.11.16
        """
        self.devs_component = model

    def getDevsComponent(self):
        """! 
        @fn         getDevsComponent()
        @brief      1:1로 매핑된 모델 요소 전달
        @details    시뮬레이션 과정에서 모델 주소 접근 시 사용

        @return     모델 요소 반환

        @author     남수만(sumannam@gmail.com)
        @date       2021.11.16
        """
        return self.devs_component
    
    def initialize(self):
        """! 
        @fn         initialize()
        @brief      시뮬레이션 시간 초기화

        @author     남수만(sumannam@gmail.com)
        @date       2021.11.16
        """
        self.time_last = 0
        self.time_next = math.inf
    
    def getTimeOfNextEvent(self):
        """! 
        @fn         getTimeOfNextEvent()
        @brief      다음 이벤트의 시뮬레이션 시간

        @return     다음 이벤트의 시간 반환

        @author     남수만(sumannam@gmail.com)
        @date       2021.11.16
        """
        return self.time_next
    
    def getTimeOfLastEvent(self):
        """! 
        @fn         getTimeOfLastEvent()
        @brief      이전 이벤트의 시뮬레이션 시간

        @return     이전 이벤트의 시간 반환

        @author     남수만(sumannam@gmail.com)
        @date       2021.11.16
        """
        return self.time_last
    
    def setName(self, name):
        """! 
        @fn         setName()
        @brief      프로세서 이름 설정
        @details    모델의 이름과 매핑

        @author     남수만(sumannam@gmail.com)
        @date       2021.11.16
        """
        self.name = name
    
    def getName(self):
        return self.name

    @abstractmethod
    def whenReceiveStar(self, input_message):
        pass
    
    @abstractmethod
    def whenReceiveY(self, input_message):
        pass