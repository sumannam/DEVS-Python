import os
import sys
import unittest
import logging
from pathlib import Path
import math

# Add test directory to sys.path to access config.py
test_dir = Path(__file__).parent.parent
sys.path.append(str(test_dir))

from config import setup_paths
setup_paths()

from src.log import logInfoCoordinator, logInfoSimulator, logDebugCoordinator, logDebugSimulator, setLogLevel
from src.MODELS import MODELS
from src.PORT import PORT
from src.MESSAGE import MESSAGE, MESSAGE_TYPE
from src.CONTENT import CONTENT
from src.COUPLING import *
from src.BROADCAST_MODELS import BROADCAST_MODELS

from src.SIMULATORS import SIMULATORS
from src.CO_ORDINATORS import CO_ORDINATORS

# Import models from test_models folder
from mbase.EF_P import EF_P
from mbase.EF import EF
from mbase.PS import PS
from mbase.GENR import GENR
from mbase.TRANSD import TRANSD
from mbase.BP import BP

class TestChildModel(MODELS):
    """Test child model class for testing BROADCAST_MODELS"""
    def __init__(self, name="TestChildModel"):
        super().__init__()
        self.setName(name)
        
        self.addInPorts("in_port1", "in_port2")
        self.addOutPorts("out_port2", "out_port2")

class testBroadcastModels(unittest.TestCase):
    def setUp(self):
        """테스트 전 설정"""
        self.broadcast_model = BROADCAST_MODELS("TestBroadcast")
        
        # Set log level to DEBUG for detailed logging
        setLogLevel(logging.DEBUG)
        
        # Create components
        self.ef_p = EF_P()
        self.ef = EF()
        self.ps = PS()        
        
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

    def test_ps_model(self):
        """PS 모델 테스트"""
        # PS 모델 생성
        ps = PS()
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
        
        # BP 컨트롤리 생성 확인
        bp_list = ps.getControlleeList()
        self.assertEqual(len(bp_list), 3)
        self.assertEqual(bp_list[0].getName(), "BP1")
        self.assertEqual(bp_list[1].getName(), "BP2")
        self.assertEqual(bp_list[2].getName(), "BP3")
        
    # def test_translate_with_couplings(self):
    #     """커플링이 있는 경우의 translate 메서드 테스트"""
        in_port.setName("in")
    #     self.broadcast_model.makeControllee(TestChildModel, 2)
    #     controllee1 = self.broadcast_model.controllee_list[0]
    #     controllee2 = self.broadcast_model.controllee_list[1]
        self.assertTrue(ps.external_input_coupling.find("PS.in"))
        # EOC (External Output Coupling) 확인
        self.assertTrue(ps.external_output_coupling.find("BP1.out"))
        
    #     # 커플링 추가
    #     self.broadcast_model.addCoupling(controllee1, controllee1.out_port1, controllee2, controllee2.in_port1)
        self.assertEqual(len(priority_list), 3)
        self.assertEqual(priority_list[0], "BP1")
        self.assertEqual(priority_list[1], "BP2")
        self.assertEqual(priority_list[2], "BP3")
        
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
        # BP 모델 생성
        bp = BP("BP1")
        
    #     # 내부 커플링 테스트
    #     ic_result = self.broadcast_model.translate(COUPLING_TYPE.IC, controllee1, controllee1.out_port1)
    #     self.assertTrue(len(ic_result) > 0)
        # 출력 포트 확인
        self.assertTrue("out" in bp.outport_list)
        self.assertTrue("unsolved" in bp.outport_list)
        
    #     # 외부 출력 커플링 테스트
    #     eoc_result = self.broadcast_model.translate(COUPLING_TYPE.EOC, controllee1, controllee1.out_port2)
    #     self.assertTrue(len(eoc_result) > 0)
        self.assertEqual(bp.state["job-id"], "")
        self.assertEqual(bp.state["processing_time"], 10)
        
    #     # 외부 입력 커플링 테스트
    #     eic_result = self.broadcast_model.translate(COUPLING_TYPE.EIC, external_model, external_out_port)
    #     self.assertTrue(len(eic_result) > 0)
        
    # def test_translate_without_couplings(self):
    #     """커플링이 없는 경우의 translate 메서드 테스트"""
        input_message.addContent(content)
        
    #     # 커플링 없이 호출 - 빈 리스트 반환 예상
    #     out_port1 = PORT("out_port1")
    #     ic_result = self.broadcast_model.translate(COUPLING_TYPE.IC, controllee, out_port1)
    #     self.assertEqual(ic_result, [])
        self.assertEqual(bp.state["sigma"], 10)
        self.assertEqual(bp.state["phase"], "passive")
        self.assertEqual(bp.state["sigma"], math.inf)
        
    #     eoc_result = self.broadcast_model.translate(COUPLING_TYPE.EOC, controllee, out_port1)
    #     self.assertEqual(eoc_result, [])
        
    #     # 외부 모델 생성
    #     external_model = MODELS("ExternalModel")
    #     external_port = PORT("ext_port")
    #     external_model.addOutPort(external_port)
        
    #     eic_result = self.broadcast_model.translate(COUPLING_TYPE.EIC, external_model, external_port)
    #     self.assertEqual(eic_result, [])
        input_message.addContent(content)

        self.assertEqual(bp2.state["phase"], "busy")
        self.assertEqual(bp2.state["job-id"], "JOB-1")
        
        # 출력 함수 테스트 (BP2는 항상 out 포트로 출력)
        output_content = bp2.outputFunc()
        self.assertEqual(output_content.getValue(), "JOB-1")

if __name__ == '__main__':
    unittest.main()
