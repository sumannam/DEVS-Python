import sys
import os
import unittest

sys.path.append(os.path.dirname(os.path.abspath(os.path.dirname(__file__))))
import config

from projects.coupledmodelTest.coupbase.SENSORS import SENSORS

class testSENSORS(unittest.TestCase):
    """! 
        @class      testSENSORS
        @brief      스크립트 기반 모델 테스트를 위한 비교 대상군을 위해 제작
        @details    

        @author     남수만(sumannam@gmail.com)
        @date       2025.01.31
	"""
    def setUp(self):
        self.sensors = SENSORS()
    
    def testAddModels(self):
        object_list = self.sensors.getModels()
        model_list = []        

        for model in object_list:
            model_list.append(model.__class__.__name__)

        assert model_list == ['SENSOR', 'SENSOR_CONTROLLER']
        
    def testPriority(self):
        priority_list = self.sensors.getPrioriryModelNameList()
        assert priority_list == ['SENSOR', 'SENSOR_CONTROLLER']
    
    def testAddExternalInputCoupling(self):
        coupling_list = self.sensors.external_input_coupling
        assert coupling_list.coupling_dic == {'SENSORS.in': ['SENSOR_CONTROLLER.in']}
        
    def testAddExternalOutputCoupling(self):
        coupling_list = self.sensors.external_output_coupling
        assert coupling_list.coupling_dic == {'SENSOR_CONTROLLER.out': ['SENSORS.out']}
        
    def testAddInteralCoupling(self):
        coupling_list = self.sensors.internal_coupling
        assert coupling_list.coupling_dic == {'SENSOR_CONTROLLER.event_out': ['SENSOR.event_in']
                                        , 'SENSOR_CONTROLLER.packet_out': ['SENSOR.packet_in']
                                        , 'SENSOR.packet_out': ['SENSOR_CONTROLLER.packet_in']
                                        , 'SENSOR.sensor_out': ['SENSOR_CONTROLLER.sensor_in']
                                        }