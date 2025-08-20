import time
import os
import unittest

# List of Atomic Models
from model_test.testP import testP
from model_test.testTRANSD import testTRANSD
from model_test.testGENR import testGENR

# List of Coupled Models 
from model_test.testEF_P import testEF_P
from model_test.testEF import testEF
from model_test.testACLUSTERS import testACLUSTERS
from model_test.testSENSORS import testSENSORS

def run_test():
   """5개 모델을 포함한 테스트 실행 및 결과 수집"""
   try:
       # 테스트 스위트 생성
       all_tests = unittest.TestSuite()
       all_tests.addTest(unittest.TestLoader().loadTestsFromTestCase(testEF_P))
       all_tests.addTest(unittest.TestLoader().loadTestsFromTestCase(testEF))
       all_tests.addTest(unittest.TestLoader().loadTestsFromTestCase(testACLUSTERS))
       all_tests.addTest(unittest.TestLoader().loadTestsFromTestCase(testSENSORS))
       all_tests.addTest(unittest.TestLoader().loadTestsFromTestCase(testTRANSD))
       all_tests.addTest(unittest.TestLoader().loadTestsFromTestCase(testGENR))

       # 테스트 실행
       result = unittest.TextTestRunner(verbosity=2, failfast=True).run(all_tests)
       
       # 테스트 결과 확인
       test_result = "성공" if result.wasSuccessful() else "실패"
       
   except Exception:
       test_result = "실패"

run_test()