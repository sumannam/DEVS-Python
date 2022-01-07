import sys
import unittest

sys.path.append('D:/Git/DEVS-Python')
sys.path.append('D:/Git/DEVS-Python/projects/simparc')

from projects.simparc.EF_P import EF_P

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