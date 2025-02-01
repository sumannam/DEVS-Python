import os
import time
import psutil
import pytest
from datetime import datetime

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

def run_pytest():
   """pytest 실행 및 결과 수집"""
   start_time = time.time()
   
   try:
       # pytest 실행
       pytest_result = pytest.main(["--rootdir=d:/Git/DEVS-Python",
                                  "d:/Git/DEVS-Python/test/pytest/pytest_EF_P.py"
                                  # "d:/Git/DEVS-Python/test/pytest/pytest_EF.py",
                                  # "d:/Git/DEVS-Python/test/pytest/pytest_ACLUSTERS.py",
                                  # "d:/Git/DEVS-Python/test/pytest/pytest_SENSORS.py"
                                ])
       
       # 테스트 결과 확인
       test_result = "성공" if pytest_result == 0 else "실패"
       
   except Exception:
       test_result = "실패"
   
   # 결과 출력
   return format_monitoring_data(start_time, test_result)

if __name__ == '__main__':
   print("\n=== 테스트 결과 (CSV 형식) ===")
   print("아래 내용을 Excel에 붙여넣기 하세요.")
   print("-" * 50)
   print(run_pytest())
   print("-" * 50)