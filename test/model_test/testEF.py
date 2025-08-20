import sys
import os
import unittest

# Add test directory to sys.path
test_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.append(test_dir)

# Import config and setup paths
from config import setup_paths
setup_paths()

from mbase.EF import EF
from src.COUPLED_MODELS import COUPLED_MODELS

class testEF(unittest.TestCase):
    def setUp(self):
        self.ef = EF()
    
    def testAddModels(self):
        object_list = self.ef.getModels()
        model_list = []

        for model in object_list:
            model_list.append(model.__class__.__name__)

        assert model_list == ['GENR', 'TRANSD']
    
    def testAddInteralCoupling(self):
        coupling_list = self.ef.internal_coupling
        assert coupling_list.coupling_dic == {'TRANSD.out': ['GENR.stop'], 'GENR.out': ['TRANSD.arrived']}
        
    def testAddExternalInputCoupling(self):
        coupling_list = self.ef.external_input_coupling
        assert coupling_list.coupling_dic == {'EF.in': ['TRANSD.solved']}
        
    def testAddExternalOutputCoupling(self):
        coupling_list = self.ef.external_output_coupling
        assert coupling_list.coupling_dic == {'GENR.out': ['EF.out'], 'TRANSD.out': ['EF.result']}

if __name__ == '__main__':
    unittest.main()
