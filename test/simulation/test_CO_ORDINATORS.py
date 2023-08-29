import sys
import unittest

sys.path.append('D:/Git/DEVS-Python')
sys.path.append('D:/Git/DEVS-Python/test')

from src.MESSAGE import *
from src.CO_ORDINATORS import CO_ORDINATORS

from models.samples.simparc.coupbase.EF_P import EF_P
from models.samples.simparc.coupbase.EF import EF

class test_CO_ORDINATORS(unittest.TestCase):
    def setUp(self):
        self.coordinator = CO_ORDINATORS()

    # CORE-3
    def testAddChild(self):
        self.ef_p = EF_P()
        self.ef = EF()

        self.coordinator.addChild(self.ef_p)
        self.coordinator.addChild(self.ef)

        processor_list_lenngth = len(self.coordinator.processor_list)

        assert processor_list_lenngth == 2