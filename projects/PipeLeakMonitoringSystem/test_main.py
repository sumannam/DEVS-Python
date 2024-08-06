import os
import time

import config

from projects.simparc.mbase.IP import IP
from TEST_ATOMIC_MODELS import TEST_ATOMIC_MODELS

if __name__ == '__main__':
    ip = IP()
    model_test = TEST_ATOMIC_MODELS()
    
    # 자동 테스트
    json_file = os.path.join(config.TBASE_FOLDER, 'ip_test_script.json')

    start = time.time() 

    model_test.runAutoModelTest(ip, json_file)
    end = time.time()

    print(f"{end - start:.5f} sec")

    ## 수동 테스트
    # ip.modelTest(ip)