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
        
    #     # 내부 커플링 mock 생성 및 설정
    #     self.broadcast_model.internal_coupling = MagicMock()
        
    #     # 내부 커플링 추가
    #     self.broadcast_model.addCoupling(controllee1, controllee1.out_port1, controllee2, controllee2.in_port1)
        
    #     # 검증
    #     self.broadcast_model.internal_coupling.addCoupling.assert_called_with(
    #         controllee1, controllee1.out_port1, controllee1, controllee1.in_port1
    #     )
        
    # def test_add_coupling_external_output(self):
    #     """외부 출력 커플링(EOC) 추가 테스트"""
    #     # 컨트롤리 생성
    #     self.broadcast_model.makeControllee(TestChildModel, 2)
    #     controllee = self.broadcast_model.controllee_list[0]
        
    #     # 외부 모델 생성
    #     external_model = MODELS("ExternalModel")
    #     external_port = PORT("ext_port")
    #     external_model.addInPort(external_port)
        
    #     # 외부 출력 커플링 mock 생성 및 설정
    #     self.broadcast_model.external_output_coupling = MagicMock()
        
    #     # 외부 출력 커플링 추가
    #     self.broadcast_model.addCoupling(controllee, controllee.out_port1, external_model, external_port)
        
    #     # 검증
    #     self.broadcast_model.external_output_coupling.addCoupling.assert_called_with(
    #         controllee, controllee.out_port1, external_model, external_port
    #     )
        
    # def test_add_coupling_external_input(self):
    #     """외부 입력 커플링(EIC) 추가 테스트"""
    #     # 컨트롤리 생성
    #     self.broadcast_model.makeControllee(TestChildModel, 2)
    #     controllee = self.broadcast_model.controllee_list[0]
        
    #     # 외부 모델 생성
    #     external_model = MODELS("ExternalModel")
    #     external_port = PORT("ext_port")
    #     external_model.addOutPort(external_port)
        
    #     # 외부 입력 커플링 mock 생성 및 설정
    #     self.broadcast_model.external_input_coupling = MagicMock()
        
    #     # 외부 입력 커플링 추가
    #     self.broadcast_model.addCoupling(external_model, external_port, controllee, controllee.in_port1)
        
    #     # 검증
    #     self.broadcast_model.external_input_coupling.addCoupling.assert_called_with(
    #         external_model, external_port, controllee, controllee.in_port1
    #     )
        
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
            
    # def test_translate_external_output_coupling(self):
    #     """External Output Coupling 번역 테스트"""
    #     # 컨트롤리 생성
    #     self.broadcast_model.makeControllee(TestChildModel, 1)
    #     controllee = self.broadcast_model.controllee_list[0]
        
    #     # 테스트용 모델-포트 쌍 생성
    #     test_pairs = [("model1", "port1"), ("model2", "port2")]
        
    #     # Mocking
    #     self.broadcast_model.external_output_coupling = MagicMock()
    #     self.broadcast_model.external_output_coupling.get.return_value = test_pairs
        
    #     # 번역 실행
    #     result = self.broadcast_model.translate(COUPLING_TYPE.EOC, controllee, controllee.out_port1)
        
    #     # 검증
    #     self.assertEqual(result, test_pairs)
    #     self.broadcast_model.external_output_coupling.get.assert_called_with(
    #         f"{controllee.getName()}.{controllee.out_port1}"
    #     )
        
    # def test_translate_internal_coupling(self):
    #     """Internal Coupling 번역 테스트"""
    #     # 컨트롤리 생성
    #     self.broadcast_model.makeControllee(TestChildModel, 1)
    #     controllee = self.broadcast_model.controllee_list[0]
        
    #     # 테스트용 모델-포트 쌍 생성
    #     test_pairs = [("model1", "port1"), ("model2", "port2")]
        
    #     # Mocking
    #     self.broadcast_model.internal_coupling = MagicMock()
    #     self.broadcast_model.internal_coupling.get.return_value = test_pairs
        
    #     # 번역 실행
    #     result = self.broadcast_model.translate(COUPLING_TYPE.IC, controllee, controllee.out_port1)
        
    #     # 검증
    #     self.assertEqual(result, test_pairs)
    #     self.broadcast_model.internal_coupling.get.assert_called_with(
    #         f"{controllee.getName()}.{controllee.out_port1}"
    #     )
        
    # def test_translate_external_input_coupling(self):
    #     """External Input Coupling 번역 테스트"""
    #     # 컨트롤리 생성
    #     self.broadcast_model.makeControllee(TestChildModel, 1)
    #     controllee = self.broadcast_model.controllee_list[0]
        
    #     # 테스트용 모델-포트 쌍 생성
    #     test_pairs = [("model1", "port1"), ("model2", "port2")]
        
    #     # Mocking
    #     self.broadcast_model.external_input_coupling = MagicMock()
    #     self.broadcast_model.external_input_coupling.get.return_value = test_pairs
        
    #     # 번역 실행
    #     result = self.broadcast_model.translate(COUPLING_TYPE.EIC, controllee, controllee.in_port1)
        
    #     # 검증
    #     self.assertEqual(result, test_pairs)
    #     self.broadcast_model.external_input_coupling.get.assert_called_with(
    #         f"{controllee.getName()}.{controllee.in_port1}"
    #     )
        
    # def test_translate_none_result(self):
    #     """translate 메서드에서 None 결과 처리 테스트"""
    #     # 컨트롤리 생성
    #     self.broadcast_model.makeControllee(TestChildModel, 1)
    #     controllee = self.broadcast_model.controllee_list[0]
        
    #     # Mocking - None 반환하는 경우
    #     self.broadcast_model.internal_coupling = MagicMock()
    #     self.broadcast_model.internal_coupling.get.return_value = None
        
    #     # 번역 실행
    #     result = self.broadcast_model.translate(COUPLING_TYPE.IC, controllee, controllee.out_port1)
        
    #     # 검증 - 빈 리스트 반환
    #     self.assertEqual(result, [])
        
        
if __name__ == '__main__':
    unittest.main()
