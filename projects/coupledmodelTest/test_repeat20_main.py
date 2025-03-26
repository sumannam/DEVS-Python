import os
import time
import psutil
import config
from datetime import datetime

from projects.simparc.coupbase.EF_P import EF_P
from projects.simparc.coupbase.EF import EF
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
    
    # CSV 형식으로 데이터 반환
    return f"{timestamp},{memory_usage:.3f},{cpu_percent},{cpu_count},{execution_time:.5f},{test_result}"

def run_test():
    """테스트 실행 및 결과 수집"""
    start_time = time.time()
    
    try:
        # 모델 초기화 및 테스트 실행
        ef_p = EF_P()
        ef = EF()
        coupled_model_test = UNITEST_MODELS()

        # 테스트 실행
        coupled_model_json = os.path.join(config.TBASE_FOLDER, 'ef_p_script.json')
        rtn = coupled_model_test.runCoupledModelTest(ef, coupled_model_json)
        
        # 테스트 결과 확인
        test_result = "성공" if rtn == 0 else "실패"
        
    except Exception:
        test_result = "실패"
    
    # 결과 반환
    return format_monitoring_data(start_time, test_result)

def run_multiple_tests(num_tests=20):
    """지정된 횟수만큼 테스트 실행"""
    # CSV 헤더
    headers = "타임스탬프,메모리(MB),CPU(%),CPU코어수,실행시간(초),테스트결과"
    results = [headers]  # 결과를 저장할 리스트
    
    # 지정된 횟수만큼 테스트 실행
    for i in range(num_tests):
        result = run_test()
        results.append(result)
        time.sleep(1)  # 각 테스트 사이에 1초 간격
    
    return results

if __name__ == '__main__':
    # 20회 테스트 실행 및 결과 출력
    print("\n=== 테스트 결과 (CSV 형식) ===")
    print("아래 내용을 Excel에 붙여넣기 하세요.")
    print("-" * 50)
    
    results = run_multiple_tests()
    for result in results:
        print(result)
    
    print("-" * 50)