import sys
import os
import unittest

sys.path.append(os.path.dirname(os.path.abspath(os.path.dirname(__file__))))
import config


from mbase.EF_P import EF_P

class testEF_P(unittest.TestCase):
    def setUp(self):
        self.ef_p = EF_P()
    
    def testAddModels(self):
        class_list = self.ef_p.getModels()
        model_list = []

        for model in class_list:
            model_list.append(model.__class__.__name__)

        assert model_list == ['EF', 'P']
    
    def testAddInteralCoupling(self):
        coupling_list = self.ef_p.internal_coupling
        assert coupling_list.coupling_dic == {'EF.out': ['P.in'], 'P.out': ['EF.in']}

if __name__ == '__main__':
    unittest.main()
