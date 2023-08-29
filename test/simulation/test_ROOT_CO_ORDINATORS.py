import sys
import unittest

sys.path.append('D:/Git/DEVS-Python')
sys.path.append('D:/Git/DEVS-Python/test')

from src.MESSAGE import *
from src.ROOT_CO_ORDINATORS import ROOT_CO_ORDINATORS

from models.samples.simparc.coupbase.EF_P import EF_P

class test_ROOT_CO_ORDINATORS(unittest.TestCase):
    def setUp(self):
        self.ef_p = EF_P()
        self.root_coordinator = ROOT_CO_ORDINATORS()

    # TDD_ROOT_CO_ORDINATORS-01 | https://www.notion.so/modsim-devs/initialize-clock-base-32268a08426e4c63b44946aaef0efea5?pvs=4
    def testInitialize(self):
        self.ef_p.initialize()
        clock_base = self.ef_p.getClockBase()

        assert clock_base == 0

    
    # TDD_ROOT_CO_ORDINATORS-02 | https://www.notion.so/modsim-devs/6208a07a97d743c2a3f8dca9cd32d03c?pvs=4
    def testWhenReceiveDone(self):
        input_message = MESSAGE()
        input_message.setDone(MESSAGE_TYPE.Done, "Test", 3)
        
        clock_base = self.root_coordinator.whenReceiveDone(input_message)
        clock_base = self.root_coordinator.getClockBase()

        assert clock_base == 3