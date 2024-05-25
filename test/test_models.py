import sys
import os
import psutil
import unittest

import config

from models.testEF_P import testEF_P
from models.testEF import testEF
from models.testP import testP

def mem_usage():
    process = psutil.Process(os.getpid())
    print(f'mem usage : {process.memory_info().rss/2**20}MB')

def test_models():
    test_efp = unittest.TestLoader().loadTestsFromTestCase(testEF_P)
    test_ef = unittest.TestLoader().loadTestsFromTestCase(testEF)
    # test_p = unittest.TestLoader().loadTestsFromTestCase(testP)

    allTests = unittest.TestSuite()

    allTests.addTest(test_efp)
    allTests.addTest(test_ef)
    # allTests.addTest(test_p)

    cpu_percent = psutil.cpu_percent()
    print(f"CPU 사용률: {cpu_percent}%")
    mem_usage()

    unittest.TextTestRunner(verbosity=2, failfast=True).run(allTests)

    cpu_percent = psutil.cpu_percent()
    print(f"CPU 사용률: {cpu_percent}%")
    mem_usage()
    
test_models()