import os
import shutil
import uuid


PIPE_MODEL_NUM = 4
SOURCE_MODEL_FILE_NAME = "PIPE1.py"
SRC_MAC_ADDR = "04:6C:59:97:DE:1F" # 실험 노트북
# SRC_MAC_ADDR = "D0:35:7E:6A:5F:9D" # 집PC
NPP_PDES_PATH = "C:\\NPP_PDES\\Simulation"
GIT_PROJECT_PATH = "C:\\Git\\DEVS-Python\\Projects\\FukushimaNuclearPipe"

# NPP_PDES_PATH = "C:/NPP_PDES/Simulation"
# GIT_PROJECT_PATH = "C:/Git/DEVS-Python/Projects/FukushimaNuclearPipe"

current_path = os.path.dirname(os.path.abspath(__file__))
mbase_path = os.path.join(current_path, "mbase")


source_file = os.path.join(mbase_path, SOURCE_MODEL_FILE_NAME)

# 파일 복사
for i in range(PIPE_MODEL_NUM):
    destination_file = os.path.join(mbase_path, f"PIPE{i+1}.py")
    
    # PIPE1 건너뛰기
    if SOURCE_MODEL_FILE_NAME in destination_file:
        continue
    
    shutil.copyfile(source_file, destination_file)
    print(f"Copy {source_file} to {destination_file}")


# 배관 모델의 소스 코드 수정
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
    

# 실험 노트북 Git -> NP_PDES로 폴더와 파일 복사
mac=uuid.getnode()
current_mac_address=':'.join(("%012X" % mac)[i:i+2] for i in range(0, 12, 2))

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
        
        
        # if os.path.isdir(source_path):
        #     shutil.copy(source_path, destination_path)
        #     print(f"Copy {source_path} to {destination_path}")
        # else:
        #     print(f"Skip {source_path}")