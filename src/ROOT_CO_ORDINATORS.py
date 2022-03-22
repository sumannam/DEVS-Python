from src.PROCESSORS import PROCESSORS
from src.MESSAGE import *

import src.util

class ROOT_CO_ORDINATORS(PROCESSORS):
    def __init__(self):
        PROCESSORS.__init__(self)
        self.name=""
        self.clock_base=0
        self.child = PROCESSORS()
    
    def setName(self, name):
        """! 
        @fn         setName
        @brief      Root Coordinator의 이름 설정
        @details    기본적으로 'R: + 최상의 모델 이름'으로 설정

        @author     남수만(sumannam@gmail.com)
        @date       2021.11.16
        """
        self.name= "R:" + name

    def setChild(self, processor):
        self.child = processor

    def getClockBase(self):
        """! 
        @fn         getClockBase
        @brief      clock_base 전달
        @details    testROOT_CO_ORDINATORS에서 시뮬레이션 초기화 후 시간 검사를 위해 clock_base 전달

        @return     시뮬레이션 다음 시간

        @author     남수만(sumannam@gmail.com)
        @date       2021.11.16
        """
        return self.clock_base
    
    def initialize(self):
        """! 
        @fn         initialize
        @brief      시뮬레이션의 최초 시간 결정
        @details    초기화 메시지(i)를 통해 원자 모델들의 최초 시간을 획득하여 clock_base 저장

        @author     남수만(sumannam@gmail.com)
        @date       2021.11.16
        """
        self.clock_base=0
        devs_component = self.child.getDevsComponent()
        self.setName(devs_component.getName())
        
        self.child.initialize()
        self.clock_base = self.child.getTimeOfNextEvent()
    
    def restart(self):
        while( self.clock_base >= 0 and self.clock_base < src.util.INFINITY):
            print("***********************************************************")
            star_msg = MESSAGE()
            star_msg.setRootStar(MESSAGE_TYPE.STAR, self.clock_base)

            self.child.whenReceiveStar(star_msg)

            if( self.clock_base == src.util.INFINITY):
                break;
    
    def whenReceiveDone(self, input_message):
        self.clock_base = input_message.getTime()
        self.runtime = self.clock_base