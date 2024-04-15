import os
import sys
import unittest
import shutil
import filecmp

import src.util as util

sys.path.append(os.path.dirname(os.path.abspath(os.path.dirname(__file__))))
import config

from src.MESSAGE import MESSAGE
from src.CONTENT import CONTENT
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
        모델의 whenReceiveY와 whenReceiveX 함수를 테스트합니다.

        이 함수는 초기화 후 모델의 whenReceiveY 함수를 테스트합니다.
        'Y' 메시지를 수신한 후의 다음 시간이 클록 베이스와 같은지 검사합니다.

        :작성자: 남수만(sumannam@gmail.com)
        :작성일: 2024.01.04
        """
        util.UNITEST_METHOD = 'testCoordinatorWhenReceiveY'
        
        self.genr = GENR()       
        input_message = MESSAGE()
        input_message.setExt('Y', self.genr, 0)

        input_content = CONTENT()
        input_content.setContent("out", "TEST-1")
        input_message.addContent(input_content)        

        self.ef.processor.whenReceiveY(input_message)        
        
        current_path = os.path.dirname(os.path.abspath(os.path.dirname(__file__)))
        parent_path = os.path.abspath(os.path.join(current_path, os.pardir))
        destination_folder = current_path + '\\' + 'engine'

        src_file = parent_path + '\\' + 'coordinator_y_log.txt'
        
        if not os.path.isfile(src_file):
            print(f"{src_file}는 존재하지 않는 파일입니다.")
        # destination_folder가 실제로 디렉토리인지 확인
        elif not os.path.isdir(destination_folder):
            print(f"{destination_folder}는 존재하지 않는 디렉토리입니다.")
        else:
            shutil.copy(src_file, destination_folder)
        
        
        coordinator_log_txt = destination_folder + '\\' + 'coordinator_y_log.txt'
        coordinator_std_txt = destination_folder + '\\' + 'coordinator_y_std.txt'
        
        assert filecmp.cmp(coordinator_log_txt, coordinator_std_txt)
        
    
    def testWhenReceiveDone(self):
        """
        모델의 whenReceiveDone 함수를 테스트합니다.

        이 함수는 초기화 후 모델의 whenReceiveDone 함수를 테스트합니다.
        'Done' 메시지를 수신한 후의 다음 시간이 클록 베이스와 같은지 검사합니다.

        :작성자: 남수만(sumannam@gmail.com)
        :작성일: 2024.01.10
        """
        util.UNITEST_METHOD = 'testCoordinatorWhenReceiveDone'
        
        self.ef = EF()
        time_next = 5
        output = MESSAGE()
        output.setDone('Done', self.ef, time_next)
        
        self.ef.processor.whenReceiveDone(output)
        
        current_path = os.path.dirname(os.path.abspath(os.path.dirname(__file__)))
        parent_path = os.path.abspath(os.path.join(current_path, os.pardir))
        destination_folder = current_path + '\\' + 'engine'

        src_file = parent_path + '\\' + 'coordinator_done_log.txt'
        
        if not os.path.isfile(src_file):
            print(f"{src_file}는 존재하지 않는 파일입니다.")
        # destination_folder가 실제로 디렉토리인지 확인
        elif not os.path.isdir(destination_folder):
            print(f"{destination_folder}는 존재하지 않는 디렉토리입니다.")
        else:
            shutil.copy(src_file, destination_folder)
        
        
        coordinator_log_txt = destination_folder + '\\' + 'coordinator_done_log.txt'
        coordinator_std_txt = destination_folder + '\\' + 'coordinator_done_std.txt'
        
        assert filecmp.cmp(coordinator_log_txt, coordinator_std_txt)