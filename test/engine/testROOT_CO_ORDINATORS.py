import os
import sys
import unittest

sys.path.append(os.path.dirname(os.path.abspath(os.path.dirname(__file__))))
import config

from src.MESSAGE import MESSAGE
from src.ROOT_CO_ORDINATORS import ROOT_CO_ORDINATORS

from projects.simparc.coupbase.EF_P import EF_P

class testROOT_CO_ORDINATORS(unittest.TestCase):
    """
    이 클래스는 ROOT_CO_ORDINATORS 클래스를 테스트합니다.
    """

    def setUp(self):
        """
        테스트 환경을 설정합니다.
        """
        self.ef_p = EF_P()

    def testInitialize(self):
        """
        모델 초기화를 테스트합니다.

        이 함수는 모델 초기화의 최소 시간을 테스트합니다.
        EF-P의 최소 Sigma 시간을 검사합니다.

        :작성자: 남수만(sumannam@gmail.com)
        :작성일: 2023.11.16

        :TDD: TDD_ROOT_CO_ORDINATORS-01
        :노션: https://www.notion.so/modsim-devs/initialize-clock-base-32268a08426e4c63b44946aaef0efea5?pvs=4
        """
        self.ef_p.initialize()
        clock_base = self.ef_p.getClockBase()
        assert 0 == clock_base
    
    def testRestart(self):
        """
        모델의 재시작 함수를 테스트합니다.

        이 함수는 초기화 후 모델의 재시작 함수를 테스트합니다.

        :작성자: 남수만(sumannam@gmail.com)
        :작성일: 2024.01.04

        :TDD: TDD_ROOT_CO_ORDINATORS-02
        :노션: https://www.notion.so/modsim-devs/TDD_ROOT_CO_ORDINATORS-02-6253f47e8d394427bdf5936573fe34e5?pvs=4
        """
        self.ef_p.initialize()
        self.ef_p.restart()

        clock_base = self.ef_p.getClockBase()

        assert clock_base == float('inf')

    def testWhenReceiveDone(self):
        """
        모델의 whenReceiveDone 함수를 테스트합니다.

        이 함수는 초기화 후 모델의 whenReceiveDone 함수를 테스트합니다.
        'Done' 메시지를 수신한 후의 다음 시간이 클록 베이스와 같은지 검사합니다.

        :작성자: 남수만(sumannam@gmail.com)
        :작성일: 2024.01.04

        :TDD: TDD_ROOT_CO_ORDINATORS-03
        :노션: https://www.notion.so/modsim-devs/initialize-clock-base-32268a08426e4c63b44946aaef0efea5?pvs=4
        """
        self.ef_p.initialize()

        time_next = 15
        output = MESSAGE()
        output.setDone('Done', self.ef_p, time_next)

        self.ef_p.processor.parent.whenReceiveDone(output)
        clock_base = self.ef_p.getClockBase()

        assert clock_base == 15