import os
import time
import psutil
import config
import csv
from datetime import datetime

from projects.coupledmodelTest.coupbase.EF_P import EF_P
from projects.coupledmodelTest.coupbase.EF import EF
from projects.coupledmodelTest.coupbase.SENSORS import SENSORS
from projects.coupledmodelTest.coupbase.ACLUSTERS import ACLUSTERS
from src.UNITEST_MODELS import UNITEST_MODELS

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

def run_test():
   """테스트 실행 및 결과 수집"""
   start_time = time.time()
   all_success = True
   
   try:
       # 모델 초기화
       ef_p = EF_P()
       ef = EF()
       sensors = SENSORS()
       aclusters = ACLUSTERS()
       coupled_model_test = UNITEST_MODELS()
       coupled_model_json = os.path.join(config.TBASE_FOLDER, 'all_script.json')

       # 모든 모델 테스트 실행
    #    models = [ef_p, ef, sensors, aclusters]
       models = [aclusters]
       for model in models:
           rtn = coupled_model_test.runCoupledModelTest(model, coupled_model_json)           
           if rtn != 0:
               all_success = False
               break
       
       # 전체 테스트 결과
       test_result = "성공" if all_success else "실패"
       
   except Exception as e:
       print(f"테스트 중 오류 발생: {str(e)}")
       test_result = "실패"
   
   # 결과 반환 - 유닛테스트와 동일한 방식으로 메모리 측정
   pid = os.getpid()
   process = psutil.Process(pid)
   end_time = time.time()
   
   # 결과 반환
   return {
       "순서": "",  # run_multiple_tests에서 설정됨
       "타임스탬프": datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
       "메모리(MB)": f"{process.memory_info()[0] / 2.**20:.3f}",
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