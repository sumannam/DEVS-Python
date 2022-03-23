from fileinput import filename
import os
import shutil
import sys
import time

from conf import setDevPath
setDevPath()

THIS_FOLDER = os.path.dirname(os.path.abspath(__file__))

# from projects.simparc.P import P

# if __name__ == '__main__':
#     p = P()

#     ## 자동 테스트
#     json_file = os.path.join(THIS_FOLDER, 'p_test.json')

#     start = time.time()    
#     p.runAutoModelTest(p, json_file)
#     end = time.time()

#     print(f"{end - start:.5f} sec")


#     ## 수동 테스트
#     p.runModelTest(p)

def moveLogFile():
    file_name = 'sim_msg_log.txt'
    index = THIS_FOLDER.find("test")
    source_path = THIS_FOLDER[:index]

    if index != -1:
        source = source_path + file_name
        destin = THIS_FOLDER + "\\" + file_name
        
        while True:
            try:
                shutil.copy(source, destin)
            except PermissionError:
                continue
            break
    

# 시뮬레이션
from EF_P import EF_P
if __name__ == '__main__':
    ef_p = EF_P()
    ef_p.initialize() 
    ef_p.restart()
    
    moveLogFile()