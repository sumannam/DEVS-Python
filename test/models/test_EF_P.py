import unittest

from models.samples.simparc.coupbase.EF_P import EF_P


class test_EF_P(unittest.TestCase):
    def setUp(self):
        self.ef_p = EF_P()
    
    def testAddModels(self):
        class_list = self.ef_p.getModels()
        model_list = []

        for model in class_list:
            model_list.append(model.__class__.__name__)

        assert model_list == ['EF', 'P']
    
    def testAddInteralCoupling(self):
        coupling_list = self.ef_p.getInternalCoupling()
        assert coupling_list.coupling_dic == {'EF.out': ['P.in'], 'P.out': ['EF.in']}