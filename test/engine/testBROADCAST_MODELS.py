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

class TestBroadcastModels(unittest.TestCase):
    
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
        
        # BP 컨트롤리 생성 확인
        bp_list = ps.getControlleeList()
        self.assertEqual(len(bp_list), 3)
        self.assertEqual(bp_list[0].getName(), "BP1")
        self.assertEqual(bp_list[1].getName(), "BP2")
        self.assertEqual(bp_list[2].getName(), "BP3")
        
        # 포트 확인
        in_port = PORT()
        in_port.setName("in")
        out_port = PORT()
        out_port.setName("out")
        
        # 커플링 확인 (COUPLED_MODELS 메소드 사용)
        # EIC (External Input Coupling) 확인
        self.assertTrue(ps.external_input_coupling.find("PS.in"))
        # EOC (External Output Coupling) 확인
        self.assertTrue(ps.external_output_coupling.find("BP1.out"))
        
        # 자식 모델 존재 확인
        self.assertTrue(ps.existChildModel(bp_list))
        
        # 우선순위 리스트 확인
        priority_list = ps.getPrioriryModelNameList()
        self.assertEqual(len(priority_list), 3)
        self.assertEqual(priority_list[0], "BP1")
        self.assertEqual(priority_list[1], "BP2")
        self.assertEqual(priority_list[2], "BP3")
        
        # 커플링 목적지 확인
        # @todo       BROADCAST_MODELS에서 dest_coupling = ps.getDestinationCoupling(ps, "in") 실행할 때 오류 발생 --> 'BP1.inBP2.inBP3.in' 형식으로 반환됨
        # dest_coupling = ps.getDestinationCoupling(ps, "in")
        # self.assertTrue(any("BP.in" in coupling for coupling in dest_coupling))
        
        # dest_coupling = ps.getDestinationCoupling(bp_list, "out")
        # self.assertTrue(any("PS.out" in coupling for coupling in dest_coupling))

    def test_bp_model(self):
        """BP 모델 테스트"""
        # BP 모델 생성
        bp = BP("BP1")
        
        # 포트 확인
        # 입력 포트 확인
        self.assertTrue("in" in bp.inport_list)
        # 출력 포트 확인
        self.assertTrue("out" in bp.outport_list)
        self.assertTrue("unsolved" in bp.outport_list)
        
        # 초기 상태 확인
        self.assertEqual(bp.state["phase"], "passive")
        self.assertEqual(bp.state["sigma"], math.inf)
        self.assertEqual(bp.state["job-id"], "")
        self.assertEqual(bp.state["processing_time"], 10)
        
        # 메시지 처리 테스트
        input_message = MESSAGE()
        input_message.setExt(MESSAGE_TYPE.EXT, bp, 0)
        
        content = CONTENT()
        content.setContent("in", "JOB-1")
        input_message.addContent(content)
        
        # 외부 전이 테스트
        bp.externalTransitionFunc(0, content)
        self.assertEqual(bp.state["phase"], "busy")
        self.assertEqual(bp.state["job-id"], "JOB-1")
        self.assertEqual(bp.state["sigma"], 10)
        
        # 출력 함수 테스트
        output_content = bp.outputFunc()
        self.assertEqual(output_content.getValue(), "JOB-1")
        
        # 내부 전이 테스트
        bp.internalTransitionFunc()
        self.assertEqual(bp.state["phase"], "passive")
        self.assertEqual(bp.state["sigma"], math.inf)

    def test_bp2_special_case(self):
        """BP2 모델의 특수 케이스 테스트"""
        # BP2 모델 생성
        bp2 = BP("BP2")
        
        # 포트 확인
        self.assertTrue("in" in bp2.inport_list)
        self.assertTrue("out" in bp2.outport_list)
        self.assertTrue("unsolved" in bp2.outport_list)
        
        # 메시지 처리 테스트
        input_message = MESSAGE()
        input_message.setExt(MESSAGE_TYPE.EXT, bp2, 0)
        
        content = CONTENT()
        content.setContent("in", "JOB-1")
        input_message.addContent(content)
        
        # 외부 전이 테스트
        bp2.externalTransitionFunc(0, content)
        self.assertEqual(bp2.state["phase"], "busy")
        self.assertEqual(bp2.state["job-id"], "JOB-1")
        
        # 출력 함수 테스트 (BP2는 항상 out 포트로 출력)
        output_content = bp2.outputFunc()
        self.assertEqual(output_content.getValue(), "JOB-1")

if __name__ == '__main__':
    unittest.main()
