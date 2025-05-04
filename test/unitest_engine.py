import os
import sys
import unittest

import config

from engine.testROOT_CO_ORDINATORS import testROOT_CO_ORDINATORS
from engine.testCO_ORDINATORS import testCO_ORDINATORS
from engine.testSIMULATORS import testSIMULATORS

def test_engine():
    test_root_coordinators = unittest.TestLoader().loadTestsFromTestCase(testROOT_CO_ORDINATORS)
    test_coordinators = unittest.TestLoader().loadTestsFromTestCase(testCO_ORDINATORS)
    test_simulators = unittest.TestLoader().loadTestsFromTestCase(testSIMULATORS)

    allTests = unittest.TestSuite()
    
    allTests.addTest(test_root_coordinators)
    # allTests.addTest(test_coordinators)
    allTests.addTest(test_simulators)

    unittest.TextTestRunner(verbosity=2, failfast=True).run(allTests)


def delete_log():
    try:
        current_path = os.path.dirname(os.path.abspath(os.path.dirname(__file__)))
        print(current_path)
        
        coordinator_y_log_file = current_path + "\\" + "coordinator_y_log.txt"
        coordinator_done_log_file = current_path + "\\" + "coordinator_done_log.txt"
        
        
        if os.path.isfile(coordinator_y_log_file):
            os.remove(coordinator_y_log_file)
            
        if os.path.isfile(coordinator_done_log_file):
            os.remove(coordinator_done_log_file)
        
        # sim_msg_log_file = current_path + "\\" + "sim_msg_log.txt"    
        # 예외가 발생했습니다: [WinError 32] 다른 프로세스가 파일을 사용 중이기 때문에 프로세스가 액세스 할 수 없습니다: 'D:\\Git\\DEVS-Python\\sim_msg_log.txt'
        # if os.path.isfile(sim_msg_log_file):
        #     os.remove(current_path + "\\" + "sim_msg_log.txt")
        
    except Exception as e:
        print(f"예외가 발생했습니다: {e}")

delete_log()
test_engine()
