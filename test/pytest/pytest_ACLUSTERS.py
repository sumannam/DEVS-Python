import sys
import os
import pytest

sys.path.append(os.path.dirname(os.path.abspath(os.path.dirname(__file__))))

from projects.coupledmodelTest.coupbase.ACLUSTERS import ACLUSTERS

class TestACLUSTERS:
   """! 
   @class      TestACLUSTERS
   @brief      스크립트 기반 모델 테스트를 위한 비교 대상군을 위해 제작
   @details    

   @author     남수만(sumannam@gmail.com)
   @date       2025.01.31
   """
   
   @pytest.fixture(autouse=True)
   def setup(self):
       """각 테스트 실행 전에 ACLUSTERS 인스턴스 생성"""
       self.aclusters = ACLUSTERS()
   
   def test_add_models(self):
       """스크립트 기반 모델의 모델 추가 테스트"""
       object_list = self.aclusters.getModels()
       model_list = [model.__class__.__name__ for model in object_list]
       
       assert model_list == ['CLUSTER', 'CONTROLLER']
   
   def test_priority(self):
       """모델의 우선순위 리스트 테스트"""
       priority_list = self.aclusters.getPrioriryModelNameList()
       assert priority_list == ['CLUSTER', 'CONTROLLER']
   
   def test_add_external_input_coupling(self):
       """외부 입력 커플링 테스트"""
       coupling_list = self.aclusters.external_input_coupling
       assert coupling_list.coupling_dic == {'ACLUSTERS.in': ['CONTROLLER.in']}
   
   def test_add_external_output_coupling(self):
       """외부 출력 커플링 테스트"""
       coupling_list = self.aclusters.external_output_coupling
       assert coupling_list.coupling_dic == {'CONTROLLER.out': ['ACLUSTERS.out']}
   
   def test_add_internal_coupling(self):
       """내부 커플링 테스트"""
       coupling_list = self.aclusters.internal_coupling
       assert coupling_list.coupling_dic == {
           'CONTROLLER.event_out': ['CLUSTER.event_in'],
           'CONTROLLER.packet_ach_out': ['CLUSTER.packet_ach_in'],
           'CONTROLLER.packet_amb_out': ['CLUSTER.packet_amb_in'],
           'CONTROLLER.knowledge_out': ['CLUSTER.knowledge_in'],
           'CLUSTER.knowledge_out': ['CONTROLLER.knowledge_in'],
           'CLUSTER.result_out': ['CONTROLLER.result_in']
       }