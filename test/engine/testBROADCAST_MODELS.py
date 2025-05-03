import os
import sys
import unittest
import logging
from pathlib import Path

# Add test directory to sys.path to access config.py
test_dir = Path(__file__).parent.parent
sys.path.append(str(test_dir))

from config import setup_paths
setup_paths()

from src.log import logInfoCoordinator, logInfoSimulator, logDebugCoordinator, logDebugSimulator, setLogLevel
from src.MODELS import MODELS
from src.PORT import PORT
from src.MESSAGE import MESSAGE
from src.CONTENT import CONTENT
from src.COUPLING import *
from src.BROADCAST_MODELS import BROADCAST_MODELS

from src.SIMULATORS import SIMULATORS
from src.CO_ORDINATORS import CO_ORDINATORS

print(sys.path)

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
        
        
        self.bp1 = BP("BP1")
        self.bp2 = BP("BP2")
        self.bp3 = BP("BP3")
        
        
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
        
    def test_broadcast_model(self):
        pass
        # Run simulation
        #self.ef_p.simulate(20)
        
        # Verify results
        #self.assertEqual(self.transd.getTotal(), 3)  # Should receive 3 messages
        #self.assertEqual(self.bp1.getTotal(), 1)     # Each BP should receive 1 message
        #self.assertEqual(self.bp2.getTotal(), 1)
        #self.assertEqual(self.bp3.getTotal(), 1)

if __name__ == '__main__':
    unittest.main()
