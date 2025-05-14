import os
import sys
import unittest
import shutil
import filecmp


sys.path.append(os.path.dirname(os.path.abspath(os.path.dirname(__file__))))
import config

import src.util as util
from src.MODELS import MODELS
from src.PORT import PORT
from src.MESSAGE import MESSAGE
from src.CONTENT import CONTENT
from src.COUPLING import *
from src.BROADCAST_MODELS import BROADCAST_MODELS

class TestChildModel(MODELS):
    """Test child model class for testing BROADCAST_MODELS"""
    def __init__(self, name="TestChildModel"):
        super().__init__()
        self.setName(name)
        
        self.addInPorts("in_port1", "in_port2")
        self.addOutPorts("out_port2", "out_port2")

class TestBroadcastModels(unittest.TestCase):
    
    def setUp(self):
        """테스트 전 설정"""
        self.broadcast_model = BROADCAST_MODELS("TestBroadcast")
        
    def test_init(self):
        """생성자 테스트"""
        self.assertEqual(self.broadcast_model.getName(), "TestBroadcast")
        self.assertIsNone(self.broadcast_model.controllee)
        self.assertEqual(len(self.broadcast_model.controllee_list), 0)
        
    def test_make_controllee(self):
        """makeControllee 메서드 테스트"""
        # 컨트롤리 생성 (3개)
        self.broadcast_model.makeControllee(TestChildModel, 3)
        
        # 검증
        self.assertEqual(len(self.broadcast_model.controllee_list), 3)
        self.assertEqual(self.broadcast_model.controllee.getName(), "TestChildModel3")
        
        # 이름 검증
        self.assertEqual(self.broadcast_model.controllee_list[0].getName(), "TestChildModel1")
        self.assertEqual(self.broadcast_model.controllee_list[1].getName(), "TestChildModel2")
        self.assertEqual(self.broadcast_model.controllee_list[2].getName(), "TestChildModel3")
        
        # 모델이 추가되었는지 확인
        self.assertTrue(self.broadcast_model.existChildModel(self.broadcast_model.controllee_list[0]))
        self.assertTrue(self.broadcast_model.existChildModel(self.broadcast_model.controllee_list[1]))
        self.assertTrue(self.broadcast_model.existChildModel(self.broadcast_model.controllee_list[2]))
        
    def test_get_controllee_list(self):
        """getControlleeList 메서드 테스트"""
        # 컨트롤리 생성
        self.broadcast_model.makeControllee(TestChildModel, 2)
        
        # 리스트 가져오기
        controllee_list = self.broadcast_model.getControlleeList()
        
        # 검증
        self.assertEqual(len(controllee_list), 2)
        self.assertEqual(controllee_list[0].getName(), "TestChildModel1")
        self.assertEqual(controllee_list[1].getName(), "TestChildModel2")
        
    # def test_add_coupling_internal(self):
    #     """내부 커플링(IC) 추가 테스트"""
    #     # 컨트롤리 생성
    #     self.broadcast_model.makeControllee(TestChildModel, 2)
    #     controllee1 = self.broadcast_model.controllee_list[0]
    #     controllee2 = self.broadcast_model.controllee_list[1]
        
    #     # 내부 커플링 추가
    #     self.broadcast_model.addCoupling(controllee1, controllee1.out_port1, controllee2, controllee2.in_port1)
        
    #     # 검증: translate 메서드를 사용하여 커플링이 올바르게 추가되었는지 확인
    #     result = self.broadcast_model.translate(COUPLING_TYPE.IC, controllee1, controllee1.out_port1)
    #     self.assertTrue(len(result) > 0, "커플링 결과가 비어 있습니다")
        
    #     # 모든 컨트롤리에 대한 커플링이 올바르게 생성되었는지 확인
    #     found_coupling = False
    #     for model_port in result:
    #         if model_port[0] == controllee2 and model_port[1] == controllee2.in_port1:
    #             found_coupling = True
    #             break
    #     self.assertTrue(found_coupling, "적절한 내부 커플링을 찾지 못했습니다")
        
    # def test_add_coupling_external_output(self):
    #     """외부 출력 커플링(EOC) 추가 테스트"""
    #     # 컨트롤리 생성
    #     self.broadcast_model.makeControllee(TestChildModel, 2)
    #     controllee = self.broadcast_model.controllee_list[0]
        
    #     # 외부 모델 생성
    #     external_model = MODELS("ExternalModel")
    #     external_port = PORT("ext_port")
    #     external_model.addInPort(external_port)
        
    #     # 외부 출력 커플링 추가
    #     self.broadcast_model.addCoupling(controllee, controllee.out_port1, external_model, external_port)
        
    #     # 검증: translate 메서드를 사용하여 커플링이 올바르게 추가되었는지 확인
    #     result = self.broadcast_model.translate(COUPLING_TYPE.EOC, controllee, controllee.out_port1)
    #     self.assertTrue(len(result) > 0, "커플링 결과가 비어 있습니다")
        
    #     # 외부 모델에 대한 커플링이 올바르게 생성되었는지 확인
    #     found_coupling = False
    #     for model_port in result:
    #         if model_port[0] == external_model and model_port[1] == external_port:
    #             found_coupling = True
    #             break
    #     self.assertTrue(found_coupling, "적절한 외부 출력 커플링을 찾지 못했습니다")
        
    # def test_add_coupling_external_input(self):
    #     """외부 입력 커플링(EIC) 추가 테스트"""
    #     # 컨트롤리 생성
    #     self.broadcast_model.makeControllee(TestChildModel, 2)
    #     controllee = self.broadcast_model.controllee_list[0]
        
    #     # 외부 모델 생성
    #     external_model = MODELS("ExternalModel")
    #     external_port = PORT("ext_port")
    #     external_model.addOutPort(external_port)
        
    #     # 외부 입력 커플링 추가
    #     self.broadcast_model.addCoupling(external_model, external_port, controllee, controllee.in_port1)
        
    #     # 검증: translate 메서드를 사용하여 커플링이 올바르게 추가되었는지 확인
    #     result = self.broadcast_model.translate(COUPLING_TYPE.EIC, external_model, external_port)
    #     self.assertTrue(len(result) > 0, "커플링 결과가 비어 있습니다")
        
    #     # 모든 컨트롤리에 대한 커플링이 올바르게 생성되었는지 확인
    #     found_coupling = False
    #     for model_port in result:
    #         if model_port[0] == controllee and model_port[1] == controllee.in_port1:
    #             found_coupling = True
    #             break
    #     self.assertTrue(found_coupling, "적절한 외부 입력 커플링을 찾지 못했습니다")
        
    # def test_add_coupling_error(self):
    #     """커플링 추가 오류 케이스 테스트"""
    #     # 외부 모델 생성
    #     external_model1 = MODELS("ExternalModel1")
    #     external_port1 = PORT("ext_port1")
    #     external_model1.addOutPort(external_port1)
        
    #     external_model2 = MODELS("ExternalModel2")
    #     external_port2 = PORT("ext_port2")
    #     external_model2.addInPort(external_port2)
        
    #     # 출력 리다이렉션 (print 문 캡처)
    #     with patch('builtins.print') as mock_print:
    #         self.broadcast_model.addCoupling(external_model1, external_port1, external_model2, external_port2)
    #         # 오류 메시지 검증
    #         mock_print.assert_called_once()
            
    # def test_translate_with_couplings(self):
    #     """커플링이 있는 경우의 translate 메서드 테스트"""
    #     # 컨트롤리 생성
    #     self.broadcast_model.makeControllee(TestChildModel, 2)
    #     controllee1 = self.broadcast_model.controllee_list[0]
    #     controllee2 = self.broadcast_model.controllee_list[1]
        
    #     # 커플링 추가
    #     self.broadcast_model.addCoupling(controllee1, controllee1.out_port1, controllee2, controllee2.in_port1)
        
    #     # 외부 모델 생성 및 커플링 추가
    #     external_model = MODELS("ExternalModel")
    #     external_in_port = PORT("ext_in_port")
    #     external_out_port = PORT("ext_out_port")
    #     external_model.addInPort(external_in_port)
    #     external_model.addOutPort(external_out_port)
        
    #     # EOC 커플링 추가
    #     self.broadcast_model.addCoupling(controllee1, controllee1.out_port2, external_model, external_in_port)
        
    #     # EIC 커플링 추가
    #     self.broadcast_model.addCoupling(external_model, external_out_port, controllee2, controllee2.in_port2)
        
    #     # 내부 커플링 테스트
    #     ic_result = self.broadcast_model.translate(COUPLING_TYPE.IC, controllee1, controllee1.out_port1)
    #     self.assertTrue(len(ic_result) > 0)
        
    #     # 외부 출력 커플링 테스트
    #     eoc_result = self.broadcast_model.translate(COUPLING_TYPE.EOC, controllee1, controllee1.out_port2)
    #     self.assertTrue(len(eoc_result) > 0)
        
    #     # 외부 입력 커플링 테스트
    #     eic_result = self.broadcast_model.translate(COUPLING_TYPE.EIC, external_model, external_out_port)
    #     self.assertTrue(len(eic_result) > 0)
        
    # def test_translate_without_couplings(self):
    #     """커플링이 없는 경우의 translate 메서드 테스트"""
    #     # 컨트롤리 생성
    #     self.broadcast_model.makeControllee(TestChildModel, 1)
    #     controllee = self.broadcast_model.controllee_list[0]
        
    #     # 커플링 없이 호출 - 빈 리스트 반환 예상
    #     out_port1 = PORT("out_port1")
    #     ic_result = self.broadcast_model.translate(COUPLING_TYPE.IC, controllee, out_port1)
    #     self.assertEqual(ic_result, [])
        
    #     eoc_result = self.broadcast_model.translate(COUPLING_TYPE.EOC, controllee, out_port1)
    #     self.assertEqual(eoc_result, [])
        
    #     # 외부 모델 생성
    #     external_model = MODELS("ExternalModel")
    #     external_port = PORT("ext_port")
    #     external_model.addOutPort(external_port)
        
    #     eic_result = self.broadcast_model.translate(COUPLING_TYPE.EIC, external_model, external_port)
    #     self.assertEqual(eic_result, [])

        
        
if __name__ == '__main__':
    unittest.main()
