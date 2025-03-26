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
        
        
    def runCoupledModelTest(self, target_model, json_file):
        """! 
        @fn         runCoupledModelTest
        @brief      결합 모델 테스트
        @details    Figma 순서도 : https://www.figma.com/board/HSxCbkqkyyEQFaKFjmcJqN/Coupled-Model-Test?node-id=0-1&t=xBPKIzNqFDd5kIB2-1
        
        @reference  https://github.com/sumannam/DEVS-Python/issues/27

        @param  model       결합 모델의 인스턴스
        @param  json_file   json 파일 경로와 파일이름

        @author     남수만(sumannam@gmail.com)
        @date       2024.04.15        

        @remarks    4) test_main.py에서 성공과 실패 시 return 반환 처리를 위해 try-except 구문 추가[2025.02.01; 남수만]
                    3) 자식 모델 비교, 우선순위 정보 리스트, 커플링 정보 비교 별 메소드 생성[2025.01.22; 남수만]
                    2) (Jira-DEVS-49) 소스 모델과 포트에서 다수의 목적 모델과 포트가 나올 수 있어, 이를 위한 처리[2024.04.16; 남수만]
                        예를 들어, TRANSD.out -> GENR.stop / TRANSD.out -> EF.result
                    1) 커플링 정보에서 소스 모델이 자기 자신일 때가 있어 조건문 추가[2024.04.16; 남수만]
        """
        try:
            test_script = open(json_file)
            json_dic = json.load(test_script)
            
            model_name = target_model.getName()        
            cm_info_list = json_dic.get(model_name)
            
            if cm_info_list is None:
                logger.error(f"JSON에서 모델 정보를 찾을 수 없음: {model_name}")
                return -1       
            
            self.diffChildModel(target_model, cm_info_list[0])
            self.diffPriorityModel(target_model, cm_info_list[1])
            self.diffCoupling(target_model, cm_info_list[2:]) 
            
        except Exception as e:
            logger.error(f"결합 모델 테스트 실패: {str(e)}")
            return -1

        return 0
    
    
    def diffChildModel(self, target_model, json_child_list):
        """! 
        @fn         diffChildModel
        @brief      타겟 결합 모델의 하위 모델 비교
        @details    
        
        @reference  https://github.com/sumannam/DEVS-Python/issues/31
        
        @param  target_model        결합 모델 인스턴스 
        @param  json_child_list     json 파일의 하위 모델 리스트

        @author     남수만(sumannam@gmail.com)
        @date       2025.01.22
        
        @remarks    1) DEBUG 레벨에서만 출력[2025.02.01; 남수만]
        """
        child_list = target_model.getChildModelNameList()
        
        # 리스트를 스트링으로 변환
        child_list_str = ', '.join(child_list)
        json_list_str = json_child_list.get('child_models')
        
        # DEBUG 레벨에서만 출력
        # logger.debug("=== Child Model ===")
        # logger.debug(f"\t child_models : {child_list_str}")
        # logger.debug(f"\t {self.diffStrings(child_list_str, json_list_str)}")
        # logger.debug("\n")
        
    
    def diffPriorityModel(self, target_model, json_priority_list):
        """! 
        @fn         diffPriorityModel
        @brief      타겟 결합 모델의 우선순위 모델 비교
        @details    
        
        @reference  https://github.com/sumannam/DEVS-Python/issues/31
        
        @param  target_model        결합 모델 인스턴스
        @param  json_priority_list  json 파일의 우선순위 모델 리스트

        @author     남수만(sumannam@gmail.com)
        @date       2025.01.22
        
        @remarks    1) DEBUG 레벨에서만 출력[2025.02.01; 남수만]
        """
        priority_list = target_model.getPrioriryModelNameList()
        
        # 리스트를 스트링으로 변환
        priority_list_str = ', '.join(priority_list)
        json_list_str = json_priority_list.get('priority')
        
        # DEBUG 레벨에서만 출력
        # logger.debug("=== priority ===")
        # logger.debug(f"\t priority : {priority_list_str}")
        # logger.debug("\t", self.diffStrings(priority_list_str, json_list_str))
        # logger.debug("\n")
        
    
    def diffCoupling(self, target_model, coupling_list):
        """! 
        @fn         diffCoupling
        @brief      타겟 결합 모델의 커플링 정보 비교
        @details    
        
        @reference  https://github.com/sumannam/DEVS-Python/issues/27
        
        @param  target_model           결합 모델 인스턴스
        @param  coupling_list   커플링 정보 리스트

        @author     남수만(sumannam@gmail.com)
        @date       2025.01.22
        
        @remarks    3) DEBUG 레벨에서만 출력[2025.02.01; 남수만]
                    2) (Jira-DEVS-49) 소스 모델과 포트에서 다수의 목적 모델과 포트가 나올 수 있어, 이를 위한 처리[2024.04.16; 남수만]
                        예를 들어, TRANSD.out -> GENR.stop / TRANSD.out -> EF.result
                    1) 커플링 정보에서 소스 모델이 자기 자신일 때가 있어 조건문 추가[2024.04.16; 남수만]
        """
        model_name = target_model.getName()
        
        for coupling in coupling_list:
            for key in coupling.keys():
                
                # dictionary에 model, select 키가 포함될 경우를 대비해서 continue 실행
                if key in 'model' 'select':
                    continue
                
                src_model_port = key.split('.')
                
                if model_name == src_model_port[0]:
                    src_model = target_model
                else:
                    src_model = target_model.getChildModel(src_model_port[0])
                
                dst_model_port_list = target_model.getDestinationCoupling(src_model, src_model_port[1])
                
                # remarks 2) 이슈 처리
                if coupling.get(key) in dst_model_port_list:
                    continue
                else:                    
                    json_coupling = key + " -> " + coupling[key]
                    
                    # remarks 2) 이슈 처리
                    for dst_model_port in dst_model_port_list:
                        model_coupling = src_model_port[0] + "." + src_model_port[1] + " -> " + dst_model_port
                        
                        # DEBUG 레벨에서만 출력
                        logger.debug(f"\t json_file : {json_coupling}")
                        logger.debug(f"\t model_coulping : {model_coupling}")
                        logger.debug("\t", self.diffStrings(json_coupling, model_coupling))
                        logger.debug("\n")
                    
                    return -1
        return 0
    
    
    def runAtomicModelTest(self, model, json_file):
        """! 
        @fn         runAtomicModelTest
        @brief      원자 모델 테스트
        @details    원자 모델의 함수들(외부상태전이, 내부상태전이, 출력)을 검증(논문 작성용)

        @param  model       원자 모델의 인스턴스
        @param  json_file   json 파일 경로와 파일이름

        @author     남수만(sumannam@gmail.com)
        @date       2022.01.31

        @remarks    결합 모델 추가로, 함수명(runAutoModelTest -> runAtomicModelTest) 변경[2024.04.15; 남수만]
                    수정된 test_script1.json 버전으로 로직 변경[2022.06.19; 남수만]
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