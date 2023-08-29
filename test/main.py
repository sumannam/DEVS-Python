import os
import shutil
import hashlib
import sys

import unittest

sys.path.append('D:/Git/DEVS-Python')
sys.path.append('D:/Git/DEVS-Python/test')

from fileinput import filename

from models.test_EF_P import test_EF_P
from models.samples.simparc.coupbase.EF_P import EF_P  


from simulation.test_ROOT_CO_ORDINATORS import test_ROOT_CO_ORDINATORS
from simulation.test_CO_ORDINATORS import test_CO_ORDINATORS
from simulation.test_ATOMIC_MODELS_TEST import test_ATOMIC_MODELS_TEST


sys.path.append('D:/Git/DEVS-Python')

allTests = unittest.TestSuite()

DEVS_PYTHON_TEST_PATH = os.path.dirname(os.path.abspath(__file__))
THIS_PATH = DEVS_PYTHON_TEST_PATH + "\\models\\samples\\simparc\\"

def moveLogFile():
    file_name = 'sim_msg_log.txt'
    index = THIS_PATH.find("test")
    source_path = THIS_PATH[:index]
    destin = ""

    if index != -1:
        source = source_path + file_name
        destin = THIS_PATH + file_name
        
        while True:
            try:
                shutil.copy(source, destin)
            except PermissionError:
                continue
            break

    return destin

def compareLogFile(source, destin):
    md5_hash = hashlib.md5()

    source_file = open(source, "rb")
    destin_file = open(destin, "rb")

    source_content = source_file.read()
    destin_content = destin_file.read()

    md5_hash.update(source_content)
    md5_hash.update(destin_content)

    source_digest = md5_hash.hexdigest()
    destin_digest = md5_hash.hexdigest()

    if source_digest == destin_digest:
        return True
    else:
        return False


def test_models():
    # [EF-P Coupled-Model]
    test_ef_p = unittest.TestLoader().loadTestsFromTestCase(test_EF_P)
    allTests.addTest(test_ef_p)

def test_simulation():
    

    # [ROOT_CO_ORDINATORS]
    test_root_coordinators = unittest.TestLoader().loadTestsFromTestCase(test_ROOT_CO_ORDINATORS)
    allTests.addTest(test_root_coordinators)

    # [CO_ORDINATORS]
    test_coordinators = unittest.TestLoader().loadTestsFromTestCase(test_CO_ORDINATORS)
    allTests.addTest(test_coordinators)

    # [ATOMIC_MODELS_TEST]
    test_p = unittest.TestLoader().loadTestsFromTestCase(test_ATOMIC_MODELS_TEST)
    allTests.addTest(test_p)


if __name__ == '__main__':
    test_models()
    test_simulation()

    unittest.TextTestRunner(verbosity=2, failfast=True).run(allTests)


    # [DEVS-Core 출력 메시지 확인]
    ef_p = EF_P()
    ef_p.initialize() 
    ef_p.restart()
    
    destin = moveLogFile()

    sim_msg_log_orig_file = 'sim_msg_log_orig.txt'
    source = THIS_PATH + sim_msg_log_orig_file

    comp_result = compareLogFile(source, destin)

    if comp_result == True:
        print("sim_msg_log_orig correspond with sim_msg_log")