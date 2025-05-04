import os
import sys
import unittest
import logging
from pathlib import Path

# Add the project root directory to the Python path
project_root = str(Path(__file__).parent.parent.parent)
sys.path.append(project_root)

from src.log import logInfoCoordinator, logInfoSimulator, logDebugCoordinator, logDebugSimulator, setLogLevel
from src.CO_ORDINATORS import CO_ORDINATORS
from src.MESSAGE import MESSAGE, MESSAGE_TYPE
from src.COUPLED_MODELS import COUPLED_MODELS

class testCO_ORDINATORS(unittest.TestCase):
    def setUp(self):
        """테스트 전 설정"""
        # Set log level to DEBUG for detailed logging
        setLogLevel(logging.DEBUG)
        
        # Create coordinator
        self.coordinator = CO_ORDINATORS()
        
        # Create coupled models for testing
        self.model1 = COUPLED_MODELS()
        self.model1.setName("Model1")
        
        self.model2 = COUPLED_MODELS()
        self.model2.setName("Model2")
        
        # Add children to coordinator
        self.coordinator.addChild(self.model1.processor)
        self.coordinator.addChild(self.model2.processor)
        
    def test_child_management(self):
        """자식 프로세서 관리 테스트"""
        # 자식 프로세서 목록 확인
        self.assertEqual(len(self.coordinator.processor_list), 2)
        self.assertEqual(self.coordinator.processor_list[0].getName(), "Model1")
        self.assertEqual(self.coordinator.processor_list[1].getName(), "Model2")
        
        # 새로운 자식 프로세서 추가
        new_model = COUPLED_MODELS()
        new_model.setName("Model3")
        self.coordinator.addChild(new_model.processor)
        
        # 자식 프로세서 목록 업데이트 확인
        self.assertEqual(len(self.coordinator.processor_list), 3)
        self.assertEqual(self.coordinator.processor_list[2].getName(), "Model3")
        
    def test_wait_list_management(self):
        """대기 목록 관리 테스트"""
        # 대기 목록 초기 상태 확인
        self.assertEqual(len(self.coordinator.wait_list), 0)
        
        # 대기 목록에 프로세서 추가
        self.coordinator.wait_list.append(self.model1.processor)
        self.assertEqual(len(self.coordinator.wait_list), 1)
        
        # 대기 목록에서 프로세서 제거
        self.coordinator.removeWaitList(self.model1.processor)
        self.assertEqual(len(self.coordinator.wait_list), 0)
        
    def test_star_child_management(self):
        """Star 자식 관리 테스트"""
        # Star 자식 초기 상태 확인
        self.assertEqual(len(self.coordinator.star_child), 0)
        
        # Star 자식 설정
        self.coordinator.star_child.append(self.model1.processor)
        self.assertEqual(len(self.coordinator.star_child), 1)
        
        # Star 자식 초기화
        self.coordinator.star_child.clear()
        self.assertEqual(len(self.coordinator.star_child), 0)
        

if __name__ == '__main__':
    unittest.main()