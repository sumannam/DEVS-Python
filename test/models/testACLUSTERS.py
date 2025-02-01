import sys
import os
import unittest

sys.path.append(os.path.dirname(os.path.abspath(os.path.dirname(__file__))))
import config

from projects.coupledmodelTest.coupbase.ACLUSTERS import ACLUSTERS

class testACLUSTERS(unittest.TestCase):
    """! 
        @class      testACLUSTERS
        @brief      스크립트 기반 모델 테스트를 위한 비교 대상군을 위해 제작
        @details    

        @author     남수만(sumannam@gmail.com)
        @date       2025.01.31
	"""
    def setUp(self):
        self.aclusters = ACLUSTERS()
    
    def testAddModels(self):
        object_list = self.aclusters.getModels()
        model_list = []        

        for model in object_list:
            model_list.append(model.__class__.__name__)

        assert model_list == ['CLUSTER', 'CONTROLLER']
        
    def testPriority(self):
        priority_list = self.aclusters.getPrioriryModelNameList()
        assert priority_list == ['CLUSTER', 'CONTROLLER']
    
    def testAddExternalInputCoupling(self):
        coupling_list = self.aclusters.external_input_coupling
        assert coupling_list.coupling_dic == {'ACLUSTERS.in': ['CONTROLLER.in']}
        
    def testAddExternalOutputCoupling(self):
        coupling_list = self.aclusters.external_output_coupling
        assert coupling_list.coupling_dic == {'CONTROLLER.out': ['ACLUSTERS.out']}
        
    def testAddInteralCoupling(self):
        coupling_list = self.aclusters.internal_coupling
        assert coupling_list.coupling_dic == {'CONTROLLER.event_out': ['CLUSTER.event_in']
                                        , 'CONTROLLER.packet_ach_out': ['CLUSTER.packet_ach_in']
                                        , 'CONTROLLER.packet_amb_out': ['CLUSTER.packet_amb_in']
                                        , 'CONTROLLER.knowledge_out': ['CLUSTER.knowledge_in']
                                        , 'CLUSTER.knowledge_out': ['CONTROLLER.knowledge_in']    
                                        , 'CLUSTER.result_out': ['CONTROLLER.result_in']    }