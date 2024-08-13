import os
import shutil
import uuid


PIPE_MODEL_NUM = 4
SOURCE_MODEL_FILE_NAME = "PIPE1.py"

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

NPP_PDES_COUPBASE_PATH = os.path.join(NPP_PDES_PATH, "coupbase")
NPP_PDES_MBASE_PATH = os.path.join(NPP_PDES_PATH, "mbase")

current_path = os.path.dirname(os.path.abspath(__file__))
mbase_path = os.path.join(current_path, "mbase")


source_file = os.path.join(mbase_path, SOURCE_MODEL_FILE_NAME)

# 1. 파일 복사
for i in range(PIPE_MODEL_NUM):
    destination_file = os.path.join(mbase_path, f"PIPE{i+1}.py")
    
    # PIPE1 건너뛰기
    if SOURCE_MODEL_FILE_NAME in destination_file:
        continue
    
    shutil.copyfile(source_file, destination_file)
    print(f"Copy {source_file} to {destination_file}")


# 2. 배관 모델의 소스 코드 수정
for i in range(PIPE_MODEL_NUM):
    destination_file = os.path.join(mbase_path, f"PIPE{i+1}.py")
    
    # PIPE1 건너뛰기
    if SOURCE_MODEL_FILE_NAME in destination_file:
        continue
    
    with open(destination_file, "r", encoding='utf-8') as file:
        lines = file.readlines()
    
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
if current_mac_address == SRC_MAC_ADDR:
    
    # NPP_PDES_PATH 디렉토리와 파일 삭제
    if os.path.exists(NPP_PDES_PATH):
        if os.path.isdir(NPP_PDES_PATH):
            shutil.rmtree(NPP_PDES_PATH)
            print(f"Delete {NPP_PDES_PATH}")
        else:
            os.remove(NPP_PDES_PATH)
            print(f"Delete {NPP_PDES_PATH}")
    
    # C:/NPP_PDES/Simulation 폴더 생성
    os.makedirs(NPP_PDES_PATH, exist_ok=True)
    
    # 폴더와 폴더 안에 모든 파일 복사
    for file in os.listdir(GIT_PROJECT_PATH):
        source_path = os.path.join(GIT_PROJECT_PATH, file)
        destination_path = os.path.join(NPP_PDES_PATH, file)
        
        try:
            if os.path.isdir(source_path):
                # 디렉토리 복사
                shutil.copytree(source_path, destination_path)
                print(f"디렉터리 '{source_path}'가 '{destination_path}'로 복사되었습니다.")
            elif os.path.isfile(source_path):
                # 파일 복사
                shutil.copy2(source_path, destination_path)
                print(f"파일 '{source_path}'가 '{destination_path}'로 복사되었습니다.")
        except PermissionError as e:
            print(f"권한 오류: {e}")
        except Exception as e:
            print(f"오류 발생: {e}")

            
    # 4. 결합 모델의 소스 코드 수정
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
                        
