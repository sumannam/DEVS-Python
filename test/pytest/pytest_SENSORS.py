import sys
import os
import pytest

# 프로젝트 루트 디렉토리를 파이썬 경로에 추가
project_root = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
sys.path.append(project_root)

from projects.coupledmodelTest.coupbase.SENSORS import SENSORS

class TestSENSORS:
    """! 
    @class      TestSENSORS
    @brief      스크립트 기반 모델 테스트를 위한 비교 대상군을 위해 제작
    @details    

    @author     남수만(sumannam@gmail.com)
    @date       2025.01.31
    """
    
    @pytest.fixture(autouse=True)
    def setup(self):
        """각 테스트 실행 전에 SENSORS 인스턴스 생성"""
        self.sensors = SENSORS()
    
    def test_add_models(self):
        """스크립트 기반 모델의 모델 추가 테스트"""
        object_list = self.sensors.getModels()
        model_list = [model.__class__.__name__ for model in object_list]
        
        assert model_list == ['SENSOR', 'SENSOR_CONTROLLER']
    
    def test_priority(self):
        """모델의 우선순위 리스트 테스트"""
        priority_list = self.sensors.getPrioriryModelNameList()
        assert priority_list == ['SENSOR', 'SENSOR_CONTROLLER']
    
    def test_add_external_input_coupling(self):
        """외부 입력 커플링 테스트"""
        coupling_list = self.sensors.external_input_coupling
        assert coupling_list.coupling_dic == {'SENSORS.in': ['SENSOR_CONTROLLER.in']}
    
    def test_add_external_output_coupling(self):
        """외부 출력 커플링 테스트"""
        coupling_list = self.sensors.external_output_coupling
        assert coupling_list.coupling_dic == {'SENSOR_CONTROLLER.out': ['SENSORS.out']}
    
    def test_add_internal_coupling(self):
        """내부 커플링 테스트"""
        coupling_list = self.sensors.internal_coupling
        assert coupling_list.coupling_dic == {
            'SENSOR_CONTROLLER.event_out': ['SENSOR.event_in'],
            'SENSOR_CONTROLLER.packet_out': ['SENSOR.packet_in'],
            'SENSOR.packet_out': ['SENSOR_CONTROLLER.packet_in'],
            'SENSOR.sensor_out': ['SENSOR_CONTROLLER.sensor_in']
        }