import time
import os
import psutil
import unittest
from datetime import datetime

# 프로젝트 루트 디렉토리를 파이썬 경로에 추가
import sys
sys.path.append(os.path.dirname(os.path.dirname(os.path.dirname(__file__))))

# List of Atomic Models
from test.models.testP import testP

# List of Coupled Models
from test.models.testEF_P import testEF_P
from test.models.EF import testEF
from test.models.testACLUSTERS import testACLUSTERS
from test.models.SENSORS import testSENSORS

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
    
    # CSV 형식으로 데이터 반환
    return f"{timestamp},{memory_usage:.3f},{cpu_percent},{cpu_count},{execution_time:.5f},{test_result}"

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
    
    # 결과 반환
    return format_monitoring_data(start_time, test_result)

def run_multiple_tests(test_function, num_tests=20):
    """지정된 횟수만큼 테스트 실행"""
    # CSV 헤더
    headers = "타임스탬프,메모리(MB),CPU(%),CPU코어수,실행시간(초),테스트결과"
    results = [headers]  # 결과를 저장할 리스트
    
    # 지정된 횟수만큼 테스트 실행
    for i in range(num_tests):
        result = run_test(test_function)
        results.append(result)
        time.sleep(1)  # 각 테스트 사이에 1초 간격
    
    return results

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
    
    # 20회 테스트 실행 및 결과 출력
    results = run_multiple_tests(test_coupled_models)
    for result in results:
        print(result)
    
    print("-" * 50)