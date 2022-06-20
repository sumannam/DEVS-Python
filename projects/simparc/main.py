import os
import sys
import time

sys.path.append('D:/Git/DEVS-Python')
sys.path.append('D:/Git/DEVS-Python/projects/simparc')

THIS_FOLDER = os.path.dirname(os.path.abspath(__file__))

from projects.simparc.P import P
from TEST_ATOMIC_MODELS import TEST_ATOMIC_MODELS

if __name__ == '__main__':
    p = P()
    model_test = TEST_ATOMIC_MODELS()
    
    ## 자동 테스트
    json_file = os.path.join(THIS_FOLDER, 'p_test.json')

    start = time.time() 

    model_test.runAutoModelTest(p, json_file)
    end = time.time()

    print(f"{end - start:.5f} sec")

    ## 수동 테스트
    # p.runModelTest(p)


# 시뮬레이션
# from projects.simparc.EF_P import EF_P
# if __name__ == '__main__':
#     ef_p = EF_P()
#     ef_p.initialize() 
#     ef_p.restart()
    