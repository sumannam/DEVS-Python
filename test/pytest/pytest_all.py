import os
import time
import psutil
import pytest


def printSystemInfo():
    pid = os.getpid() 
    current_process = psutil.Process(pid)
    current_process_memory_usage_as_KB = current_process.memory_info()[0] / 2.**20
    print(f"Current memory KB   : {current_process_memory_usage_as_KB: 9.3f} KB")

    cpu_percent = psutil.cpu_percent()
    cpu_count = psutil.cpu_count()
    print(f"CPU 사용량: {cpu_percent}%")
    print(f"CPU 코어수:  {cpu_count}")

def mem_usage():
    process = psutil.Process(os.getpid())
    print(f'mem usage : {process.memory_info().rss/2**20}MB')


cpu_percent = psutil.cpu_percent()
print(f"CPU 사용량: {cpu_percent}%")
mem_usage()
start = time.time() 

# 테스트 실행
pytest_result = pytest.main(["--rootdir=d:/Git/DEVS-Python"
                             , "d:/Git/DEVS-Python/test/pytest/pytest_EF_P.py"
                            #  , "d:/Git/DEVS-Python/test/pytest/pytest_EF.py"
                            #  , "d:/Git/DEVS-Python/test/pytest/pytest_ACLUSTERS.py"
                            #  , "d:/Git/DEVS-Python/test/pytest/pytest_SENSORS.py"
                             ])
end = time.time()

mem_usage()
printSystemInfo()
print(f"{end - start:.5f} sec")


if pytest_result == 0:
    print("테스트가 모두 성공했습니다!")
else:
    print("테스트에 실패했습니다!")




