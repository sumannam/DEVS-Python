import sys
import unittest

sys.path.append('D:/Git/DEVS-Python')
sys.path.append('D:/Git/DEVS-Python/test/samples/simparc/coupbase')

from test.samples.simparc.coupbase.EF_P import EF_P

class test_ROOT_CO_ORDINATORS(unittest.TestCase):
    def setUp(self):
        self.ef_p = EF_P()

    # CORE-1 | https://www.notion.so/modsim-devs/initialize-clock-base-32268a08426e4c63b44946aaef0efea5?pvs=4
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