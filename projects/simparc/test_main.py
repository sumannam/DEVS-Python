import os
import time

import config

from projects.simparc.coupbase.EF_P import EF_P
from projects.simparc.coupbase.EF import EF
from projects.simparc.mbase.IP import IP
from src.UNITEST_MODELS import UNITEST_MODELS

if __name__ == '__main__':
    ef_p = EF_P()
    ef = EF()
    ip = IP()    
    
    atomic_model_test = UNITEST_MODELS()
    coupled_model_test = UNITEST_MODELS()
    
    # 자동 테스트
    coupled_model_json = os.path.join(config.TBASE_FOLDER, 'ef_p_script.json')
    atomic_model_json = os.path.join(config.TBASE_FOLDER, 'test_script2.json')    

    start = time.time() 

    rtn = coupled_model_test.runCoupledModelTest(ef, coupled_model_json)
    if rtn == 0:
        print("Success: Coupled Model Test")
    else:
        print("Fail: Coupled Model Test")
        
    
    
    # atomic_model_test.runAtomicModelTest(ip, atomic_model_json)
    end = time.time()

    print(f"{end - start:.5f} sec")

    ## 수동 테스트
    # ip.modelTest(ip)