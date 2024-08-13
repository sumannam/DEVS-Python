import os
import shutil

PIPE_MODEL_NUM = 4
SOURCE_MODEL_FILE_NAME = "PIPE1.py"

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