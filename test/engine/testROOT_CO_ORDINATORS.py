import os
import sys
import unittest

sys.path.append(os.path.dirname(os.path.abspath(os.path.dirname(__file__))))
import config

from src.MESSAGE import MESSAGE
from src.ROOT_CO_ORDINATORS import ROOT_CO_ORDINATORS

from projects.simparc.coupbase.EF_P import EF_P

class testROOT_CO_ORDINATORS(unittest.TestCase):
    def setUp(self):
        self.ef_p = EF_P()

    def testInitialize(self):
        """! 
        @fn         testInitialize
        @brief      모델 초기화의 최소 시간
        @details    EF-P의 최소 Sigma 시간 검사

        @author     남수만(sumannam@gmail.com)
        @date       2021.11.16      
        """
        self.ef_p.initialize()
        clock_base = self.ef_p.getClockBase()
        assert 0 == clock_base
    
    def testRestart(self):
        self.ef_p.initialize()
        self.ef_p.restart()

        clock_base = self.ef_p.getClockBase()

        assert clock_base == float('inf')

    def testWhenReceiveDone(self):
        self.ef_p.initialize()

        time_next = 15
        output = MESSAGE()
        output.setDone('Done', self.ef_p, time_next)

        self.ef_p.processor.parent.whenReceiveDone(output)
        clock_base = self.ef_p.getClockBase()

        assert clock_base == 15