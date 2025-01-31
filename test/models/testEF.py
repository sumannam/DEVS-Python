import sys
import os
import unittest

sys.path.append(os.path.dirname(os.path.abspath(os.path.dirname(__file__))))
import config

from projects.simparc.coupbase.EF import EF

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