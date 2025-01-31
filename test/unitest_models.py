import time
import os
import psutil
import unittest
import psutil

# List of Atomic Models
from models.testP import testP

# List of Coupled Models
from models.testEF_P import testEF_P
from models.testEF import testEF
from models.testACLUSTERS import testACLUSTERS
from models.testSENSORS import testSENSORS


def printSystemInfo():
    pid = os.getpid() 
    current_process = psutil.Process(pid)
    current_process_memory_usage_as_KB = current_process.memory_info()[0] / 2.**20
    print(f"Current memory KB   : {current_process_memory_usage_as_KB: 9.3f} KB")

    cpu_percent = psutil.cpu_percent()
    cpu_count = psutil.cpu_count()
    print(f"CPU 사용률 {cpu_percent}%")
    print(f"CPU 코어  {cpu_count}")
    

def test_atomic_models():
    """! 
        @fn         test_atomic_models
        @brief      원자 모델 테스트
        @details    
        
        @reference  

        @author     남수만(sumannam@gmail.com)
        @date       2025.01.31
        
        @remarks    1) test_coupled_models에서 소스 코드 단순화를 위해 원자 모델 테스트 방법 분리[2025.01.31; 남수만]
    """
    print("--- test_atomic_models ---")
    test_p = unittest.TestLoader().loadTestsFromTestCase(testP)
    
    allTests = unittest.TestSuite()
    
    allTests.addTest(test_p)
    
    cpu_percent = psutil.cpu_percent()
    print(f"CPU 사용률 {cpu_percent}%")
    
    unittest.TextTestRunner(verbosity=2, failfast=True).run(allTests)
    
    cpu_percent = psutil.cpu_percent()
    print(f"CPU 사용률 {cpu_percent}%")


def test_coupled_models():
    """! 
        @fn         test_coupled_models
        @brief      결합합 모델 테스트
        @details    
        
        @reference  

        @author     남수만(sumannam@gmail.com)
        @date       2025.01.31
        
        @remarks    1) 기존 test_models에서 소스 코드 단순화를 위해 원자 모델 테스트 방법 분리[2025.01.31; 남수만]
    """
    print("--- test_coupled_models ---")
    test_efp = unittest.TestLoader().loadTestsFromTestCase(testEF_P)
    test_ef = unittest.TestLoader().loadTestsFromTestCase(testEF)    

    allTests = unittest.TestSuite()

    allTests.addTest(test_efp)
    allTests.addTest(test_ef)
    

    cpu_percent = psutil.cpu_percent()
    print(f"CPU 사용률 {cpu_percent}%")

    unittest.TextTestRunner(verbosity=2, failfast=True).run(allTests)

    cpu_percent = psutil.cpu_percent()
    print(f"CPU 사용률 {cpu_percent}%")


def test_wsn_coupled_models(): 
    """! 
        @fn         test_wsn_coupled_models
        @brief      WSN 결합 모델들 테스트
        @details    
        
        @reference  

        @author     남수만(sumannam@gmail.com)
        @date       2025.01.31
    """
    print("--- test_wsn_coupled_models ---")
    test_aclusters = unittest.TestLoader().loadTestsFromTestCase(testACLUSTERS)
    test_sensors = unittest.TestLoader().loadTestsFromTestCase(testSENSORS)
    
    allTests = unittest.TestSuite()
    
    allTests.addTest(test_aclusters)
    allTests.addTest(test_sensors)
    
    cpu_percent = psutil.cpu_percent()
    print(f"CPU 사용률 {cpu_percent}%")
    
    unittest.TextTestRunner(verbosity=2, failfast=True).run(allTests)
    
    cpu_percent = psutil.cpu_percent()
    print(f"CPU 사용률 {cpu_percent}%")


start = time.time() 

printSystemInfo()

# test_atomic_models()
# test_coupled_models()
test_wsn_coupled_models()

printSystemInfo()

end = time.time()
print(f"{end - start:.5f} sec")