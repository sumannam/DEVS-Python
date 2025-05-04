import os
import sys
import unittest
import logging
from pathlib import Path

# Add the project root directory to the Python path
project_root = str(Path(__file__).parent.parent.parent)
sys.path.append(project_root)

from src.log import logInfoCoordinator, logInfoSimulator, logDebugCoordinator, logDebugSimulator, setLogLevel
from src.ROOT_CO_ORDINATORS import ROOT_CO_ORDINATORS
from src.CO_ORDINATORS import CO_ORDINATORS
from src.MESSAGE import MESSAGE, MESSAGE_TYPE
from src.COUPLED_MODELS import COUPLED_MODELS

class testROOT_CO_ORDINATORS(unittest.TestCase):
    def setUp(self):
        """테스트 전 설정"""
        # Set log level to DEBUG for detailed logging
        setLogLevel(logging.DEBUG)
        
        # Create root_coordinator
        self.root = ROOT_CO_ORDINATORS()
        
        # Create a coupled model for testing
        self.coupled_model = COUPLED_MODELS()
        self.coupled_model.setName("TestModel")
        
        # Set child to root
        self.root.setChild(self.coupled_model.processor)
        
    def test_name_setting(self):
        """이름 설정 테스트"""
        # 이름 설정
        self.root.setName("TestRoot")
        
        # 이름 확인
        self.assertEqual(self.root.getName(), "R:TestRoot") 
        
    def test_child_management(self):
        """자식 프로세서 관리 테스트"""
        # 자식 프로세서 설정 확인
        self.assertEqual(self.root.child.getName(), "TestModel")
        
        # 새로운 자식 프로세서 설정
        new_model = COUPLED_MODELS()
        new_model.setName("NewTestModel")
        self.root.setChild(new_model.processor)
        
        # 자식 프로세서 변경 확인
        self.assertEqual(self.root.child.getName(), "NewTestModel")

if __name__ == '__main__':
    unittest.main()