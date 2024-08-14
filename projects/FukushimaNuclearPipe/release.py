import os
import shutil
import uuid


### 0. 변수 설정 ###
"""
    초기 변수를 설정
"""

# 원자 모델의 수
PIPE_MODEL_NUM = 4

# 복제할 원자 모델 소스 파일 이름
SOURCE_MODEL_FILE_NAME = "PIPE1.py"

# 작업하는 PC의 경로가 달라, 맥 주소로 초기 값 설정
mac=uuid.getnode()
current_mac_address=':'.join(("%012X" % mac)[i:i+2] for i in range(0, 12, 2))

# 집PC 설정
if current_mac_address == "D0:35:7E:6A:5F:9D":
    SRC_MAC_ADDR = "D0:35:7E:6A:5F:9D" 
    NPP_PDES_PATH = "D:\\NPP_PDES\\Simulation"
    GIT_PROJECT_PATH = "D:\\Git\\DEVS-Python\\Projects\\FukushimaNuclearPipe"

# 실험 노트북
elif current_mac_address == "04:6C:59:97:DE:1F":    
    SRC_MAC_ADDR = "04:6C:59:97:DE:1F"
    NPP_PDES_PATH = "C:\\NPP_PDES\\Simulation"
    GIT_PROJECT_PATH = "C:\\Git\\DEVS-Python\\Projects\\FukushimaNuclearPipe"

# 복제할 대상 경로(예: C:\\NPP_PDES\\Simulation\\coupbase)
NPP_PDES_COUPBASE_PATH = os.path.join(NPP_PDES_PATH, "coupbase")
NPP_PDES_MBASE_PATH = os.path.join(NPP_PDES_PATH, "mbase")

current_path = os.path.dirname(os.path.abspath(__file__))
mbase_path = os.path.join(current_path, "mbase")

source_file = os.path.join(mbase_path, SOURCE_MODEL_FILE_NAME)



### 1. 파일 복사 ###
# 주어진 파이프 모델 수(PIPE_MODEL_NUM)만큼 반복하여, 각각의 PIPE{i+1}.py 파일을 생성합니다.
for i in range(PIPE_MODEL_NUM):
    destination_file = os.path.join(mbase_path, f"PIPE{i+1}.py")
    
    # SOURCE_MODEL_FILE_NAME을 포함한 파일명(즉, PIPE1)은 복사하지 않고 건너뜁니다.
    if SOURCE_MODEL_FILE_NAME in destination_file:
        continue
    
    # source_file을 destination_file로 복사합니다.
    shutil.copyfile(source_file, destination_file)
    print(f"Copy {source_file} to {destination_file}")


### 2. 배관 모델의 소스 코드 수정 ###
# 각 파이프 모델 파일(PIPE{i+1}.py)을 열어 특정 내용을 수정합니다.
for i in range(PIPE_MODEL_NUM):
    destination_file = os.path.join(mbase_path, f"PIPE{i+1}.py")
    
    # SOURCE_MODEL_FILE_NAME을 포함한 파일명(즉, PIPE1)은 복사하지 않고 건너뜁니다.
    if SOURCE_MODEL_FILE_NAME in destination_file:
        continue
    
    # 기존 파일을 읽어옵니다.
    with open(destination_file, "r", encoding='utf-8') as file:
        lines = file.readlines()
    
    # 파일을 새로 작성하면서 특정 문자열을 수정합니다.
    with open(destination_file, "w", encoding='utf-8') as file:
        for line in lines:
            if "class PIPE1(ATOMIC_MODELS)" in line:
                file.write(f"class PIPE{i+1}(ATOMIC_MODELS)"+":\n")
            elif "self.unity_model_name = \"PIPE114_6000_1\"" in line:
                file.write(f"        self.unity_model_name = \"PIPE114_6000_{i+1}\"\n")
            else:
                file.write(line)
    
    print(f"Modify {destination_file}")
    

# 3. 실험 노트북 Git -> NP_PDES로 폴더와 파일 복사
# 현재 컴퓨터의 MAC 주소가 SRC_MAC_ADDR와 일치하는 경우, 파일과 폴더를 복사합니다.
if current_mac_address == SRC_MAC_ADDR:
    
    # NPP_PDES_PATH 디렉토리와 파일이 존재하는 경우, 삭제합니다.
    if os.path.exists(NPP_PDES_PATH):
        if os.path.isdir(NPP_PDES_PATH):
            shutil.rmtree(NPP_PDES_PATH) # 디렉토리 전체를 삭제
            print(f"Delete {NPP_PDES_PATH}")
        else:
            os.remove(NPP_PDES_PATH) # 단일 파일을 삭제
            print(f"Delete {NPP_PDES_PATH}")
    
    # C:/NPP_PDES/Simulation 폴더를 생성합니다. 이미 존재하면 생략합니다.
    os.makedirs(NPP_PDES_PATH, exist_ok=True)
    
    # 폴더와 폴더 안에 모든 파일 복사
    for file in os.listdir(GIT_PROJECT_PATH):
        source_path = os.path.join(GIT_PROJECT_PATH, file)
        destination_path = os.path.join(NPP_PDES_PATH, file)
        
        try:
            # 디렉토리를 재귀적으로 복사합니다.
            if os.path.isdir(source_path):
                shutil.copytree(source_path, destination_path)
                print(f"디렉터리 '{source_path}'가 '{destination_path}'로 복사되었습니다.")
            elif os.path.isfile(source_path):
                # 단일 파일을 복사합니다.
                shutil.copy2(source_path, destination_path)
                print(f"파일 '{source_path}'가 '{destination_path}'로 복사되었습니다.")
        except PermissionError as e:
            print(f"권한 오류: {e}")
        except Exception as e:
            print(f"오류 발생: {e}")

            
    # 4. 결합 모델의 소스 코드 수정
    # NPP_PDES_COUPBASE_PATH 내의 각 파일을 열어 특정 임포트 경로를 수정합니다.
    for coupbase_file in os.listdir(NPP_PDES_COUPBASE_PATH):
        coupbase_file_path = os.path.join(NPP_PDES_COUPBASE_PATH, coupbase_file)
        
        if os.path.isfile(coupbase_file_path):
            with open(coupbase_file_path, "r", encoding='utf-8') as file:
                lines = file.readlines()
    
            with open(coupbase_file_path, "w", encoding='utf-8') as file:
                for line in lines:
                    if "from src.COUPLED_MODELS import COUPLED_MODELS" in line:
                        file.write(f"from devsbase.COUPLED_MODELS import COUPLED_MODELS\n")
                    elif "from projects.FukushimaNuclearPipe.coupbase.PIPES import PIPES" in line:
                        file.write(f"from coupbase.PIPES import PIPES\n")
                    elif "from projects.FukushimaNuclearPipe.coupbase.EF import EF" in line:
                        file.write(f"from coupbase.EF import EF\n")
                    else:
                        file.write(line)
        
    # 5. 원자 모델의 소스 코드 수정
    # NPP_PDES_MBASE_PATH 내의 각 파일을 열어 특정 임포트 경로를 수정합니다.
    # 'C:\\NPP_PDES\\Simulation\devsbase'에 DEVS 엔진 파일을 가지고 있어, 거기에 맞춰 임포트 경로 변경
    for mbase_file in os.listdir(NPP_PDES_MBASE_PATH):
        mbase_file_path = os.path.join(NPP_PDES_MBASE_PATH, mbase_file)
        
        if os.path.isfile(mbase_file_path):
            with open(mbase_file_path, "r", encoding='utf-8') as file:
                lines = file.readlines()
    
            with open(mbase_file_path, "w", encoding='utf-8') as file:
                for line in lines:
                    if "from src.ATOMIC_MODELS import *" in line:
                        file.write(f"from devsbase.ATOMIC_MODELS import *\n")
                    elif "from src.util import *" in line:
                        file.write(f"from devsbase.util import *\n")
                    elif "from src.ATOMIC_MODELS import ATOMIC_MODELS" in line:
                        file.write(f"from devsbase.ATOMIC_MODELS import ATOMIC_MODELS\n")
                    elif "from src.CONTENT import CONTENT" in line:
                        file.write(f"from devsbase.CONTENT import CONTENT\n")
                    elif "from src.util import convertJsonToString" in line:
                        file.write(f"from devsbase.util import convertJsonToString\n")
                    elif "from src.PORT import PORT" in line:
                        file.write(f"from devsbase.PORT import PORT\n")
                    else:
                        file.write(line)