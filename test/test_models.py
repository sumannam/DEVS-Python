import time
import os
import psutil
import unittest
import psutil

from models.testEF_P import testEF_P
from models.testEF import testEF
from models.testP import testP

def printSystemInfo():
    pid = os.getpid() 
    current_process = psutil.Process(pid)
    current_process_memory_usage_as_KB = current_process.memory_info()[0] / 2.**20
    print(f"Current memory KB   : {current_process_memory_usage_as_KB: 9.3f} KB")

    cpu_percent = psutil.cpu_percent()
    cpu_count = psutil.cpu_count()
    print(f"CPU ¬ìš©ë¥ {cpu_percent}%")
    print(f"CPU ì½”ì–´  {cpu_count}")

def test_models():
    test_efp = unittest.TestLoader().loadTestsFromTestCase(testEF_P)
    test_ef = unittest.TestLoader().loadTestsFromTestCase(testEF)
    # test_p = unittest.TestLoader().loadTestsFromTestCase(testP)

    allTests = unittest.TestSuite()

    allTests.addTest(test_efp)
    allTests.addTest(test_ef)
    # allTests.addTest(test_p)

    cpu_percent = psutil.cpu_percent()
    print(f"CPU ¬ìš©ë¥ {cpu_percent}%")
    mem_usage()

    unittest.TextTestRunner(verbosity=2, failfast=True).run(allTests)

    cpu_percent = psutil.cpu_percent()
    print(f"CPU ¬ìš©ë¥ {cpu_percent}%")
    mem_usage()

start = time.time() 

printSystemInfo()

test_models()

printSystemInfo()

end = time.time()
print(f"{end - start:.5f} sec")