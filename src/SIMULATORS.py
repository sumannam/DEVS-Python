import sys
import math

sys.path.append('D:/Git/DEVS-Python')

from src.PROCESSORS import PROCESSORS
from src.ROOT_CO_ORDINATORS import ROOT_CO_ORDINATORS

class SIMULATORS(PROCESSORS):
    def __init__(self):
        PROCESSORS.__init__(self)

        self.parent = ROOT_CO_ORDINATORS()
        self.parent.setChild(self)

    def initialize(self):
        """! 
        @fn         initialize
        @brief      원자 모델의 sigma 시간 얻기
        @details    시간 진행 함수를 통해 원자 모델 sigma 값 접근

        @author     남수만(sumannam@gmail.com)
        @date       2021.11.16
        """
        super().initialize()
        self.tN=self.devs_cmponent.timeAdvancedFunc()