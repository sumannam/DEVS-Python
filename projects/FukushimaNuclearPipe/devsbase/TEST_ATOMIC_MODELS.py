import sys
import json
import difflib
from loguru import logger   # pip install loguru

# sys.path.append('D:/Git/DEVS-Python')

from devsbase.ATOMIC_MODELS import ATOMIC_MODELS
from devsbase.CONTENT import CONTENT

class TEST_ATOMIC_MODELS():

    def __init__(self):
        # pass 
        # ATOMIC_MODELS.__init__(self)
        self.atomic_model = ATOMIC_MODELS()

    def runAutoModelTest(self, model, json_file):
        """! 
        @fn         runAutoModelTest
        @brief      원자 모델 테스트
        @details    원자 모델의 함수들(외부상태전이, 내부상태전이, 출력)을 검증(논문 작성용)

        @param  model       원자 모델의 인스턴스
        @param  json_file   json 파일 경로와 파일이름

        @author     남수만(sumannam@gmail.com)
        @date       2022.01.31

        @remarks    수정된 test_script1.json 버전으로 로직 변경[2022.06.19; 남수만]
                    결과들의 문자열 비교문 추가[2022.06.19; 남수만]
        """
        test_script = open(json_file)
        json_dic = json.load(test_script)

        model_name = model.getName()

        for i in range(1, len(json_dic)):
            atom_seq = str(i)
            atom_content = json_dic.get(atom_seq)

            input_script = self.makeCommand(model_name, atom_content)
            print(input_script)

            param = [x for x in input_script.split(' ')]

            func_type = atom_content['func']
            
            if func_type == "delta_ext":
                port_name = param[3]
                value = param[4]
                elased_time = self.atomic_model.decideNumberType(param[5])

                model.sendInject(port_name, value, elased_time)
                model_result = model.getInjectResult(func_type)

            if func_type == "lambda_out":
                output = CONTENT()
                output = model.outputFunc()
                model_result = model.getOutputResult(output)                
            
            if func_type == "delta_int":
                model.internalTransitionFunc()
                model_result = model.getIntTransitionResult()
            
            print(self.diffStrings(model_result, atom_content['assert']))
            # logger.opt(raw=True, colors=True).info(self.diffStrings(model_result, atom_content['assert'], use_loguru_colors=True))
            print("\n")

    def makeCommand(self, model_name, atom_content):
        """! 
        @fn         makeCommand
        @brief      원자 모델의 테스트 결과(A)와 스크립트의 결과(B)를 비교
        @details    비교 결과 0이면 A==B, 1이면 B에 추가된 문자열 발견, -1이면 B에 삭제된 문자열 발견

        @param  model_name      원자 모델의 이름
        @param  atom_content    테스트 스크립트 문자열

        @author     남수만(sumannam@gmail.com)
        @date       2022.06.19
        """
        command = ""
        func_type = atom_content['func']
        
        if func_type == "delta_ext":
            command = "send " + model_name
            command += " inject "  + atom_content['inject']
        
        if func_type == "lambda_out":
            command = "send " + model_name + " output?"

        if func_type == "delta_int":
            command = "send " + model_name + " int-transition"            

        return command
    

    def diffStrings(self, a: str, b: str, *, use_loguru_colors: bool = False) -> str:
        """! 
        @fn         diffStrings
        @brief      문자열 비교
        @details    원자 모델 테스트를 위한 문자열 비교(추가 글자: 녹색, 삭제 글자: 빨강)

        @param  a    원자 모델 테스트 결과
        @param  b    JSON의 assert

        @author     남수만(sumannam@gmail.com)
        @date       2022.06.20
        """
        output = []
        matcher = difflib.SequenceMatcher(None, a, b)
        if use_loguru_colors:
            green = '<GREEN><black>'
            red = '<RED><black>'
            endgreen = '</black></GREEN>'
            endred = '</black></RED>'
        else:
            green = '\x1b[38;5;16;48;5;2m'
            red = '\x1b[38;5;16;48;5;1m'
            endgreen = '\x1b[0m'
            endred = '\x1b[0m'

        for opcode, a0, a1, b0, b1 in matcher.get_opcodes():
            if opcode == 'equal':
                output.append(a[a0:a1])
            elif opcode == 'insert':
                output.append(f'{green}{b[b0:b1]}{endgreen}')
            elif opcode == 'delete':
                output.append(f'{red}{a[a0:a1]}{endred}')
            elif opcode == 'replace':
                output.append(f'{green}{b[b0:b1]}{endgreen}')
                output.append(f'{red}{a[a0:a1]}{endred}')

        return ''.join(output)