import time
import os
import unittest

# List of Atomic Models
from models.testP import testP
from models.testTRANSD import testTRANSD
from models.testGENR import testGENR

# List of Coupled Models 
from models.testEF_P import testEF_P
from models.testEF import testEF
from models.testACLUSTERS import testACLUSTERS
from models.testSENSORS import testSENSORS

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