import os
import shutil
import hashlib
import sys
import unittest

from fileinput import filename

from models.testPModelTest import testPModelTest
from simulation.testROOT_CO_ORDINATORS import testROOT_CO_ORDINATORS


from conf import setDevPath
setDevPath()

sys.path.append('D:/Git/DEVS-Python')
PROJECT_PATH = os.path.dirname(os.path.abspath(__file__))

index = PROJECT_PATH.find("test")
THIS_PATH = PROJECT_PATH[:index] + "test\\test_simparc"

def moveLogFile():
    file_name = 'sim_msg_log.txt'
    index = THIS_PATH.find("test")
    source_path = THIS_PATH[:index]
    destin = ""

    if index != -1:
        source = source_path + file_name
        destin = THIS_PATH + "\\" + file_name
        
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


# # ��이
# from EF_P import EF_P
# if __name__ == '__main__':
#     ef_p = EF_P()
#     ef_p.initialize() 
#     ef_p.restart()
    
    destin = moveLogFile()

    sim_msg_log_orig_file = 'sim_msg_log_orig.txt'
    source = THIS_PATH + "\\" + sim_msg_log_orig_file

    comp_result = compareLogFile(source, destin)

    if comp_result == True:
        print("sim_msg_log �일 �치")

allTests = unittest.TestSuite()

def test_models():
    test_p0 = unittest.TestLoader().loadTestsFromTestCase(testPModelTest)
    test_p1 = unittest.TestLoader().loadTestsFromTestCase(testPModelTest)
    test_p2 = unittest.TestLoader().loadTestsFromTestCase(testPModelTest)
    test_p3 = unittest.TestLoader().loadTestsFromTestCase(testPModelTest)
    test_p4 = unittest.TestLoader().loadTestsFromTestCase(testPModelTest)

    allTests.addTest(test_p0)
    allTests.addTest(test_p1)
    allTests.addTest(test_p2)
    allTests.addTest(test_p3)
    allTests.addTest(test_p4)

def test_simulation():
    test_root_coordinators = unittest.TestLoader().loadTestsFromTestCase(testROOT_CO_ORDINATORS)
    allTests.addTest(test_root_coordinators)


if __name__ == '__main__':
    test_models()
    test_simulation()

    # test_p5 = unittest.TestLoader().loadTestsFromTestCase(testPModelTest)
    # test_p6 = unittest.TestLoader().loadTestsFromTestCase(testPModelTest)
    # test_p7 = unittest.TestLoader().loadTestsFromTestCase(testPModelTest)
    # test_p8 = unittest.TestLoader().loadTestsFromTestCase(testPModelTest)
    # test_p9 = unittest.TestLoader().loadTestsFromTestCase(testPModelTest)
    # test_efp = unittest.TestLoader().loadTestsFromTestCase(testEF_P)
    

    
    
    # allTests.addTest(test_p5)
    # allTests.addTest(test_p6)
    # allTests.addTest(test_p7)
    # allTests.addTest(test_p8)
    # allTests.addTest(test_p9)
    # allTests.addTest(test_efp)
    

    unittest.TextTestRunner(verbosity=2, failfast=True).run(allTests)