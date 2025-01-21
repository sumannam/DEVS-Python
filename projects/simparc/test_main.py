import os
import time
import psutil

import config

from projects.simparc.coupbase.EF_P import EF_P
from projects.simparc.coupbase.EF import EF
from projects.simparc.mbase.IP import IP
from src.UNITEST_MODELS import UNITEST_MODELS

def printSystemInfo():
    pid = os.getpid() 
    current_process = psutil.Process(pid)
    current_process_memory_usage_as_KB = current_process.memory_info()[0] / 2.**20
    print(f"Current memory KB   : {current_process_memory_usage_as_KB: 9.3f} KB")

    cpu_percent = psutil.cpu_percent()
    cpu_count = psutil.cpu_count()
    print(f"CPU ¬ì?ë¥ {cpu_percent}%")
    print(f"CPU ì½??  {cpu_count}")

if __name__ == '__main__':
    ef_p = EF_P()
    ef = EF()
    # ip = IP()    
    
    cpu_percent = psutil.cpu_percent()
    # cpu_count = psutil.cpu_count()
    print(f"CPU ¬ì?ë¥ {cpu_percent}%")
    # print(f"CPU ì½??  {cpu_count}")
    mem_usage()
    # atomic_model_test = UNITEST_MODELS()
    coupled_model_test = UNITEST_MODELS()
    
    start = time.time() 
    
    printSystemInfo()
        
    # ?? ??
    coupled_model_json = os.path.join(config.TBASE_FOLDER, 'ef_p_script.json')
    atomic_model_json = os.path.join(config.TBASE_FOLDER, 'test_script2.json')        
    
    

    rtn = coupled_model_test.runCoupledModelTest(ef, coupled_model_json)
    # cpu_percent = psutil.cpu_percent()
    cpu_count = psutil.cpu_count()
    print(f"CPU ¬ì?ë¥ {cpu_percent}%")
    # print(f"CPU ì½??  {cpu_count}")
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