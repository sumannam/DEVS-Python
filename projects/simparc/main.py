import os
import sys
import time

sys.path.append('D:/Git/DEVS-Python')
sys.path.append('D:/Git/DEVS-Python/projects/simparc')

TBASE_FOLDER = os.path.dirname(os.path.abspath(__file__)) + "\\tbase"

from projects.simparc.mbase.IP import IP
from TEST_ATOMIC_MODELS import TEST_ATOMIC_MODELS

if __name__ == '__main__':
    ip = IP()
    model_test = TEST_ATOMIC_MODELS()
    
    ## 자동 테스트
    # json_file = os.path.join(TBASE_FOLDER, 'ip_test_script.json')

    # start = time.time() 

    # model_test.runAutoModelTest(ip, json_file)
    # end = time.time()

    # print(f"{end - start:.5f} sec")

    ## 수동 테스트
    ip.modelTest(ip)


# 시뮬레이션
# from projects.simparc.EF_P import EF_P
# if __name__ == '__main__':
#     ef_p = EF_P()
#     ef_p.initialize() 
#     ef_p.restart()
    