from fileinput import filename
import os
import shutil
import hashlib
import sys
import time

from conf import setDevPath
setDevPath()

PROJECT_PATH = os.path.dirname(os.path.abspath(__file__))

index = PROJECT_PATH.find("test")
THIS_PATH = PROJECT_PATH[:index] + "test\\test_simparc"

def moveLogFile():
    file_name = 'sim_msg_log.txt'
    index = THIS_PATH.find("test")
    source_path = THIS_PATH[:index]
    destin = ""

    if index != -1:
        source = source_path + file_name
        destin = THIS_PATH + "\\" + file_name
        
        while True:
            try:
                shutil.copy(source, destin)
            except PermissionError:
                continue
            break

    return destin

def compareLogFile(source, destin):
    md5_hash = hashlib.md5()

    source_file = open(source, "rb")
    destin_file = open(destin, "rb")

    source_content = source_file.read()
    destin_content = destin_file.read()

    md5_hash.update(source_content)
    md5_hash.update(destin_content)

    source_digest = md5_hash.hexdigest()
    destin_digest = md5_hash.hexdigest()

    if source_digest == destin_digest:
        return True
    else:
        return False


# 시뮬레이션
from EF_P import EF_P
if __name__ == '__main__':
    ef_p = EF_P()
    ef_p.initialize() 
    ef_p.restart()
    
    destin = moveLogFile()

    sim_msg_log_orig_file = 'sim_msg_log_orig.txt'
    source = THIS_PATH + "\\" + sim_msg_log_orig_file

    comp_result = compareLogFile(source, destin)

    if comp_result == True:
        print("sim_msg_log 파일 일치")