import sys
import json
import difflib
from loguru import logger   # pip install loguru

sys.path.append('D:/Git/DEVS-Python')

from src.ATOMIC_MODELS import ATOMIC_MODELS
from src.COUPLED_MODELS import COUPLED_MODELS
from src.CONTENT import CONTENT

class UNITEST_MODELS():

    def __init__(self):
        # pass 
        # ATOMIC_MODELS.__init__(self)
        self.atomic_model = ATOMIC_MODELS()
        self.coupled_model = COUPLED_MODELS()
        
    def runCoupledModelTest(self, model, json_file):
        """! 
        @fn         runCoupledModelTest
        @brief      결합 모델 �스
        @details    
        @details    Figma �서: https://www.figma.com/board/HSxCbkqkyyEQFaKFjmcJqN/Coupled-Model-Test?node-id=0-1&t=xBPKIzNqFDd5kIB2-1
        
        @reference  https://github.com/sumannam/DEVS-Python/issues/27

        @param  model       결합 모델�스�스
        @param  json_file   json �일 경로� �일�름

        @author     �수�sumannam@gmail.com)
        @date       2024.04.15        

        @remarks    3) �식 모델 비교, �선�위 �보 리스 커플맕보 비교 �메소�성[2025.01.22; �수�
                    2) (Jira-DEVS-49) �스 모델곬트�서 �수목적 모델곬트가 �올 �어, �� �한 처리[2024.04.16; �수�
                        �� �어, TRANSD.out -> GENR.stop / TRANSD.out -> EF.result
                    1) 커플맕보�서 �스 모델�기 �신�� �어 조건�추�[2024.04.16; �수�
        """
        test_script = open(json_file)
        json_dic = json.load(test_script)

        model_name = model.getName()        
        cm_info_list = json_dic.get(model_name)
    
        self.diffChildModel(model, cm_info_list[0])
        self.diffPriorityModel(model, cm_info_list[1])
        self.diffCoupling(model, cm_info_list[2:])      
    
    
    def diffChildModel(self, target_model, json_child_list):
        """! 
        @fn         diffChildModel
        @brief      ��결합 모델�위 모델 비교
        @details    
        
        @reference  https://github.com/sumannam/DEVS-Python/issues/31
        
        @param  target_model        결합 모델 �스�스 
        @param  json_child_list     json �일�위 모델 리스

        @author     �수�sumannam@gmail.com)
        @date       2025.01.22
        """
        child_list = target_model.getChildModelNameList()
        
        # 리스�� �트링으�변
        child_list_str = ', '.join(child_list)
        json_list_str = json_child_list.get('child_models')
        
        # 비교 결과 출력
        print("=== Child Model ===")
        print(f"\t child_models : {child_list_str}")
        print("\t", self.diffStrings(child_list_str, json_list_str))
        print("\n")
        
    
    def diffPriorityModel(self, target_model, json_priority_list):
        """! 
        @fn         diffPriorityModel
        @brief      ��결합 모델�선�위 모델 비교
        @details    
        
        @reference  https://github.com/sumannam/DEVS-Python/issues/31
        
        @param  target_model        결합 모델 �스�스
        @param  json_priority_list  json �일�선�위 모델 리스

        @author     �수�sumannam@gmail.com)
        @date       2025.01.22
        """
        priority_list = target_model.getPrioriryModelNameList()
        
        # 리스�� �트링으�변
        priority_list_str = ', '.join(priority_list)
        json_list_str = json_priority_list.get('priority')
        
        # 비교 결과 출력
        print("=== priority ===")
        print(f"\t priority : {priority_list_str}")
        print("\t", self.diffStrings(priority_list_str, json_list_str))
        print("\n")
        
    
    def diffCoupling(self, target_model, coupling_list):
        """! 
        @fn         diffCoupling
        @brief      ��결합 모델커플맕보 비교
        @details    
        
        @reference  https://github.com/sumannam/DEVS-Python/issues/27
        
        @param  target_model           결합 모델 �스�스
        @param  coupling_list   커플맕보 리스

        @author     �수�sumannam@gmail.com)
        @date       2025.01.22
        
        @remarks    2) (Jira-DEVS-49) �스 모델곬트�서 �수목적 모델곬트가 �올 �어, �� �한 처리[2024.04.16; �수�
                        �� �어, TRANSD.out -> GENR.stop / TRANSD.out -> EF.result
                    1) 커플맕보�서 �스 모델�기 �신�� �어 조건�추�[2024.04.16; �수�
        """
        model_name = target_model.getName()
        
        for coupling in coupling_list:
            for key in coupling.keys():
                
                if key in 'model' 'select':
                    continue
                
                src_model_port = key.split('.')
                
                if model_name == src_model_port[0]:
                    src_model = target_model
                else:
                    src_model = target_model.getChildModel(src_model_port[0])
                
                dst_model_port_list = target_model.getDestinationCoupling(src_model, src_model_port[1])
                
                # remarks 2) �슈 처리
                if coupling.get(key) in dst_model_port_list:
                    continue
                else:                    
                    json_coupling = key + " -> " + coupling[key]
                    
                    # remarks 2) �슈 처리
                    for dst_model_port in dst_model_port_list:
                        model_coupling = src_model_port[0] + "." + src_model_port[1] + " -> " + dst_model_port
                        
                        print(f"\t json_file : {json_coupling}")
                        print(f"\t model_coulping : {model_coupling}")
                        print("\t", self.diffStrings(json_coupling, model_coupling))
                        print("\n")
                    
                    return -1
        return 0
    
    def runAtomicModelTest(self, model, json_file):
        """! 
        @fn         runAtomicModelTest
        @brief      �자 모델 �스
        @details    �자 모델�수��태�이, ��태�이, 출력)검즼문 �성

        @param  model       �자 모델�스�스
        @param  json_file   json �일 경로� �일�름

        @author     �수�sumannam@gmail.com)
        @date       2022.01.31

        @remarks    결합 모델 추�� �수�runAutoModelTest -> runAtomicModelTest) 변�2024.04.15; �수�
                    �정test_script1.json 버전�로 로직 변�2022.06.19; �수�
                    결과�의 문자비교�추�[2022.06.19; �수�
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
        @brief      �자 모델�스결과(A)� �크립트결과(B)�비교
        @details    비교 결과 0�면 A==B, 1�면 B추�문자발견, -1�면 B��문자발견

        @param  model_name      �자 모델�름
        @param  atom_content    �스�크립트 문자

        @author     �수�sumannam@gmail.com)
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
        @brief      문자비교
        @details    �자 모델 �스�� �한 문자비교(추� 글 �색, �� 글 빨강)

        @param  a    �자 모델 �스결과
        @param  b    JSONassert

        @author     �수�sumannam@gmail.com)
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