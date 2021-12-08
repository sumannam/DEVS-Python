import sys
#from abc import abstractmethod

sys.path.append('D:/Git/DEVS-Python')

from src.MODELS import MODELS
from src.PROCESSORS import PROCESSORS
from src.MESSAGE import MESSAGE
from src.ROOT_CO_ORDINATORS import ROOT_CO_ORDINATORS
# from src.COUPLED_MODELS import COUPLED_MODELS

class CO_ORDINATORS(PROCESSORS):
    def __init__(self):
        PROCESSORS.__init__(self)
        
        self.parent=ROOT_CO_ORDINATORS()
        self.parent.setChild(self)
        self.processor_list = []
        self.processor_time = {}

        self.devs_component = None
        self.star_child = []
        self.wait_list = []

    def addChild(self, processor):
        """! 
        @fn         initialize()
        @brief      자식 모델 저장
        @details    자식 모델을 접근하기 위해 리스트 형태로 저장

        @param  processor   프로세스

        @author     남수만(sumannam@gmail.com)
        @date       2021.11.16
        """
        self.processor_list.append(processor)

    def initialize(self):
        """! 
        @fn         initialize()
        @brief      모든 Coordiantor와 Simulator을 접근하여 최소 시간 탐색
        @details    결합 모델일 경우 CO_ORDINATORS.initialize() 호출
                    원자 모델일 경우 SIMULATORS.initialize() 호출
		
		@remarks	whenReceiveStar에서 자식들에게 바로 접근하기 위해 모델 문자에서 인스턴스로 변경 'self.processor_time[processor_name]=time' -> 'self.processor_time[processor]=time' [21.12.04; 남수만]
        @author     남수만(sumannam@gmail.com)
        @date       2021.11.16
        """
        for processor in self.processor_list:
            processor.initialize()
            time = processor.getTimeOfNextEvent()
            # processor_name = processor.getName()
            self.processor_time[processor]=time
        
        self.setTimeOfNextEvent()

    def setTimeOfNextEvent(self):
        """! 
        @fn         setTimeOfNextEvent()
        @brief      self.processor_time에서 가장 작은 시간 설정
        @details    시뮬레이션의 초기 시간 결정을 위해 사용

        @author     남수만(sumannam@gmail.com)
        @date       2021.11.16
        """
        time_min = min(self.processor_time.values())
        self.tN = time_min
    
    # overriding abstract method
    def whenReceiveStar(self, input_message):
        msg_time = input_message.getTime()

        if( msg_time == self.tN ):
            self.tL = msg_time
            output = MESSAGE()
            output.setStar(MESSAGE.STAR, self.devs_component, msg_time)

            self.setStarChild()

            for child in self.star_child:
                self.wait_list.append(child)
                child.whenReceiveStar(output)

            self.star_child.clear()
    
    #### self.devs_component.getPriorityList() 개발 중
    def setStarChild(self):
        self.star_child.clear()
        priority_list = self.devs_component.priority_list
        count = self.countSameTimeInChildren(self.tN)    

        if len(priority_list) == 0 or count == 1:
            for key in self.processor_time.keys():
                if self.processor_time[key] == self.tN:
                    self.star_child.append(key)
        ## TODO: 다중 조건문 추가 필요
        
        
    
    def countSameTimeInChildren(self, time):
        count = 0
        for value in self.processor_time.values():
            if value == time:
                count=count+1

        return count