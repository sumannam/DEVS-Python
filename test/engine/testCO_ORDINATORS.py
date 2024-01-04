import os
import sys
import unittest

sys.path.append(os.path.dirname(os.path.abspath(os.path.dirname(__file__))))
import config

from src.MESSAGE import MESSAGE
from src.CO_ORDINATORS import CO_ORDINATORS

from projects.simparc.coupbase.EF import EF
from projects.simparc.mbase.GENR import GENR

class testCO_ORDINATORS(unittest.TestCase):
    """
    이 클래스는 ROOT_CO_ORDINATORS 클래스를 테스트합니다.
    """

    def setUp(self):
        """
        테스트 환경을 설정합니다.
        """
        self.ef = EF()
        self.ef.initialize()

    def testInitialize(self):
        """
        모델 초기화를 테스트합니다.

        이 함수는 모델 초기화의 최소 시간을 테스트합니다.
        EF-P의 최소 Sigma 시간을 검사합니다.

        :작성자: 남수만(sumannam@gmail.com)
        :작성일: 2024.01.04

        :TDD: 
        :노션: https://www.notion.so/modsim-devs/TDD-c80a15fcb34c40319b7a4e3d9b0211a7?pvs=4
        """
        time_list = list(self.ef.processor.processor_time.values())
        
        assert time_list == [0, 10]
        
    def testWhenReceiveStar(self):
        """
        모델의 whenReceiveStar 함수를 테스트합니다.

        이 함수는 초기화 후 모델의 whenReceiveStar 함수를 테스트합니다.
        'Star' 메시지를 수신한 후의 다음 시간이 클록 베이스와 같은지 검사합니다.

        :작성자: 남수만(sumannam@gmail.com)
        :작성일: 2024.01.04
        """
        
        star_msg = MESSAGE()
        star_msg.setRootStar('Star', 0)
        self.ef.processor.whenReceiveStar(star_msg)
        
        time_next = self.ef.processor.getTimeOfNextEvent()
        
        assert time_next == 3
        
    def testWhenReceiveY(self):
        """
        모델의 whenReceiveY 함수를 테스트합니다.

        이 함수는 초기화 후 모델의 whenReceiveY 함수를 테스트합니다.
        'Y' 메시지를 수신한 후의 다음 시간이 클록 베이스와 같은지 검사합니다.

        :작성자: 남수만(
        :작성일: 2024.01.04
        """
        self.genr = GENR()
        
        
        input_message = MESSAGE()
        input_message.setExt('Y', self.genr, 0)
        
        self.ef.processor.whenReceiveY(input_message)
        
        
    
    # def testRestart(self):
    #     """
    #     모델의 재시작 함수를 테스트합니다.

    #     이 함수는 초기화 후 모델의 재시작 함수를 테스트합니다.

    #     :작성자: 남수만(sumannam@gmail.com)
    #     :작성일: 2024.01.04

    #     :TDD: TDD_ROOT_CO_ORDINATORS-02
    #     :노션: https://www.notion.so/modsim-devs/TDD_ROOT_CO_ORDINATORS-02-6253f47e8d394427bdf5936573fe34e5?pvs=4
    #     """
    #     self.ef_p.initialize()
    #     self.ef_p.restart()

    #     clock_base = self.ef_p.getClockBase()

    #     assert clock_base == float('inf')

    # def testWhenReceiveDone(self):
    #     """
    #     모델의 whenReceiveDone 함수를 테스트합니다.

    #     이 함수는 초기화 후 모델의 whenReceiveDone 함수를 테스트합니다.
    #     'Done' 메시지를 수신한 후의 다음 시간이 클록 베이스와 같은지 검사합니다.

    #     :작성자: 남수만(sumannam@gmail.com)
    #     :작성일: 2024.01.04

    #     :TDD: TDD_ROOT_CO_ORDINATORS-03
    #     :노션: https://www.notion.so/modsim-devs/initialize-clock-base-32268a08426e4c63b44946aaef0efea5?pvs=4
    #     """
    #     self.ef_p.initialize()

    #     time_next = 15
    #     output = MESSAGE()
    #     output.setDone('Done', self.ef_p, time_next)

    #     self.ef_p.processor.parent.whenReceiveDone(output)
    #     clock_base = self.ef_p.getClockBase()

    #     assert clock_base == 15