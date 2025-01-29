import os
import time
import psutil

import config

from projects.coupledmodelTest.coupbase.EF_P import EF_P
from projects.coupledmodelTest.coupbase.EF import EF
from projects.coupledmodelTest.coupbase.SENSORS import SENSORS
from projects.coupledmodelTest.coupbase.ACLUSTERS import ACLUSTERS
from projects.coupledmodelTest.mbase.IP import IP
from src.UNITEST_MODELS import UNITEST_MODELS

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

if __name__ == '__main__':
    ef_p = EF_P()
    ef = EF()
    acluster = ACLUSTERS()
    sensors = SENSORS()
    # ip = IP()    
    
    cpu_percent = psutil.cpu_percent()
    # cpu_count = psutil.cpu_count()
    print(f"CPU 사용량: {cpu_percent}%")
    mem_usage()
    # atomic_model_test = UNITEST_MODELS()
    coupled_model_test = UNITEST_MODELS()
    
    start = time.time() 
    
    printSystemInfo()
        
    # 파일명
    wsn_script_json = os.path.join(config.TBASE_FOLDER, 'wsn_script.json')
    # atomic_model_json = os.path.join(config.TBASE_FOLDER, 'test_script2.json')        
    
    

    rtn = coupled_model_test.runCoupledModelTest(sensors, wsn_script_json)
    # cpu_percent = psutil.cpu_percent()
    cpu_count = psutil.cpu_count()
    print(f"CPU 사용량: {cpu_percent}%")
    mem_usage()

    if rtn == 0:
        print("Success: Coupled Model Test")
    else:
        print("Fail: Coupled Model Test")        
    
    printSystemInfo()
    # atomic_model_test.runAtomicModelTest(ip, atomic_model_json)
    end = time.time()

    print(f"{end - start:.5f} sec")
    

    ## ?? ??
    # ip.modelTest(ip)