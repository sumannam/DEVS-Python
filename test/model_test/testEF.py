import sys
import os
import unittest

# Add test directory to sys.path
test_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.append(test_dir)

# Import config and setup paths
from config import setup_paths
setup_paths()

from src.COUPLED_MODELS import COUPLED_MODELS
from models.testGENR import testGENR
from test.model_test.testTRANSD import testTRANSD

class testEF(unittest.TestCase):
    def setUp(self):
        self.ef = testEF()
    
    def testAddModels(self):
        object_list = self.ef.getModels()
        model_list = []

        for model in object_list:
            model_list.append(model.__class__.__name__)

        assert model_list == ['testGENR', 'testTRANSD']
    
    def testAddInteralCoupling(self):
        coupling_list = self.ef.internal_coupling
        assert coupling_list.coupling_dic == {'testTRANSD.out': ['testGENR.stop'], 'testGENR.out': ['testTRANSD.arrived']}
        
    def testAddExternalInputCoupling(self):
        coupling_list = self.ef.external_input_coupling
        assert coupling_list.coupling_dic == {'EF.in': ['testTRANSD.solved']}
        
    def testAddExternalOutputCoupling(self):
        coupling_list = self.ef.external_output_coupling
        assert coupling_list.coupling_dic == {'testGENR.out': ['EF.out'], 'testTRANSD.out': ['EF.result']}