import os
import sys
import unittest

sys.path.append(os.path.dirname(os.path.abspath(os.path.dirname(__file__))))
import config

from src.MESSAGE import MESSAGE
from src.SIMULATORS import SIMULATORS

from projects.simparc.mbase.TRANSD import TRANSD

class testSIMULATORS(unittest.TestCase):
    """
    이 클래스는 SIMULATORS 클래스를 테스트합니다.
    """

    def setUp(self):
        """
        테스트 환경을 설정합니다.
        """
        self.transd = TRANSD()

    def testInitialize(self):
        """
        모델 초기화를 테스트합니다.

        이 함수는 모델 초기화의 최소 시간을 테스트합니다.
        EF의 최소 Sigma 시간을 검사합니다.

        :작성자: 남수만(sumannam@gmail.com)
        :작성일: 2024.01.04

        :TDD: 
        :노션: https://www.notion.so/modsim-devs/TDD-c80a15fcb34c40319b7a4e3d9b0211a7?pvs=4
        """
        self.transd.processor.initialize()

        test_next = self.transd.processor.time_next
        
        assert test_next == 10