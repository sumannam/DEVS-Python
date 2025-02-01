import time
import os
import psutil
import unittest
from datetime import datetime

# List of Atomic Models
from models.testP import testP

# List of Coupled Models
from models.testEF_P import testEF_P
from models.testEF import testEF
from models.testACLUSTERS import testACLUSTERS
from models.testSENSORS import testSENSORS

def format_monitoring_data(start_time, test_result):
   """실행 결과를 CSV 형식의 문자열로 반환"""
   pid = os.getpid()
   process = psutil.Process(pid)
   end_time = time.time()
   execution_time = end_time - start_time

   # 시스템 정보 수집
   memory_usage = process.memory_info()[0] / 2.**20
   cpu_percent = psutil.cpu_percent()
   cpu_count = psutil.cpu_count()
   timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
   
   # CSV 형식으로 출력
   headers = "타임스탬프,메모리(MB),CPU(%),CPU코어수,실행시간(초),테스트결과"
   data = f"{timestamp},{memory_usage:.3f},{cpu_percent},{cpu_count},{execution_time:.5f},{test_result}"
   
   return f"{headers}\n{data}"

def run_test(test_function):
   """테스트 실행 및 결과 수집"""
   start_time = time.time()
   
   try:
       # 테스트 실행
       test_suite = test_function()
       result = unittest.TextTestRunner(verbosity=2, failfast=True).run(test_suite)
       
       # 테스트 결과 확인
       test_result = "성공" if result.wasSuccessful() else "실패"
       
   except Exception:
       test_result = "실패"
   
   # 결과 출력
   return format_monitoring_data(start_time, test_result)

def test_atomic_models():
   """원자 모델 테스트"""
   allTests = unittest.TestSuite()
   allTests.addTest(unittest.TestLoader().loadTestsFromTestCase(testP))
   return allTests

def test_coupled_models():
   """결합 모델 테스트"""
   allTests = unittest.TestSuite()
   allTests.addTest(unittest.TestLoader().loadTestsFromTestCase(testEF_P))
#    allTests.addTest(unittest.TestLoader().loadTestsFromTestCase(testEF))
   return allTests

def test_wsn_coupled_models():
   """WSN 결합 모델 테스트"""
   allTests = unittest.TestSuite()
   allTests.addTest(unittest.TestLoader().loadTestsFromTestCase(testACLUSTERS))
   allTests.addTest(unittest.TestLoader().loadTestsFromTestCase(testSENSORS))
   return allTests

if __name__ == '__main__':
   print("\n=== 테스트 결과 (CSV 형식) ===")
   print("아래 내용을 Excel에 붙여넣기 하세요.")
   print("-" * 50)
   
   # 원하는 테스트 실행
   # print(run_test(test_atomic_models))
   print(run_test(test_coupled_models))
#    print(run_test(test_wsn_coupled_models))
   
   print("-" * 50)