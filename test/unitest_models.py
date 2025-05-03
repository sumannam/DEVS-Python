import time
import os
import psutil
import unittest
import csv
from datetime import datetime

# List of Atomic Models
from models.testP import testP

# List of Coupled Models 
from models.testEF_P import testEF_P
from test.models.EF import testEF
from models.testACLUSTERS import testACLUSTERS
from test.models.SENSORS import testSENSORS

def format_monitoring_data(start_time, test_result, model_name):
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
    
    # 데이터 반환
    return {
        "모델": model_name,
        "타임스탬프": timestamp,
        "메모리(MB)": f"{memory_usage:.3f}",
        "CPU(%)": str(cpu_percent),
        "CPU코어수": str(cpu_count),
        "실행시간(초)": f"{execution_time:.6f}",
        "테스트결과": test_result
    }

def run_test():
   """4개 모델을 포함한 테스트 실행 및 결과 수집"""
   try:
       # 시작 시 메모리 측정
       process = psutil.Process(os.getpid())
       start_memory = process.memory_info()[0] / 2.**20
       start_time = time.time()

       # 테스트 스위트 생성
       all_tests = unittest.TestSuite()
       all_tests.addTest(unittest.TestLoader().loadTestsFromTestCase(testEF_P))
       all_tests.addTest(unittest.TestLoader().loadTestsFromTestCase(testEF))
       all_tests.addTest(unittest.TestLoader().loadTestsFromTestCase(testACLUSTERS))
       all_tests.addTest(unittest.TestLoader().loadTestsFromTestCase(testSENSORS))
       
       # 테스트 실행
       result = unittest.TextTestRunner(verbosity=2, failfast=True).run(all_tests)
       
       # 테스트 완료 후 메모리 측정
       end_memory = process.memory_info()[0] / 2.**20
       memory_used = end_memory - start_memory  # 실제 사용된 메모리
       
       # 테스트 결과 확인
       test_result = "성공" if result.wasSuccessful() else "실패"
       
   except Exception:
       test_result = "실패"
       memory_used = 0
   
   end_time = time.time()
   
   # 결과 반환
   return {
       "순서": "",  # run_multiple_tests에서 설정됨
       "타임스탬프": datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
       "메모리(MB)": f"{memory_used:.3f}",
       "CPU(%)": str(psutil.cpu_percent()),
       "CPU코어수": str(psutil.cpu_count()),
       "실행시간(초)": f"{(end_time - start_time):.6f}",
       "테스트결과": test_result
   }

def run_multiple_tests(num_tests=20):
   """지정된 횟수만큼 테스트를 실행하고 결과를 반환"""
   results = []
   
   # 가비지 컬렉션 설정
   import gc
   gc.enable()
   
   for i in range(num_tests):
       # 각 테스트 전에 가비지 컬렉션 실행
       gc.collect()
       
       result = run_test()
       result["순서"] = str(i + 1)
       results.append(result)
       time.sleep(1)  # 각 테스트 사이에 1초 간격
   
   return results

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
    
    # 데이터 반환
    return {
        "순서": "",  # run_multiple_tests에서 설정됨
        "타임스탬프": timestamp,
        "메모리(MB)": f"{memory_usage:.3f}",
        "CPU(%)": str(cpu_percent),
        "CPU코어수": str(cpu_count),
        "실행시간(초)": f"{execution_time:.6f}",
        "테스트결과": test_result
    }

def save_results_to_csv(results, filename="test_results.csv"):
    """테스트 결과를 CSV 파일로 저장"""
    if not results:
        return
    
    fieldnames = ["순서", "타임스탬프", "메모리(MB)", "CPU(%)", "CPU코어수", "실행시간(초)", "테스트결과"]
    with open(filename, 'w', newline='', encoding='utf-8') as f:
        writer = csv.DictWriter(f, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(results)

if __name__ == '__main__':
    print("\n=== 테스트 결과 (CSV 형식) ===")
    print("테스트를 20회 실행합니다.")
    print("-" * 50)
    
    # 20회 테스트 실행
    results = run_multiple_tests()
    
    # 결과를 화면에 출력
    headers = "순서,타임스탬프,메모리(MB),CPU(%),CPU코어수,실행시간(초),테스트결과"
    print("\n" + headers)
    for result in results:
        print(",".join([result[field] for field in headers.split(",")]))
    
    # 결과를 CSV 파일로 저장
    save_results_to_csv(results)
    print("\n테스트 결과가 test_results.csv 파일로 저장되었습니다.")
    print("-" * 50)