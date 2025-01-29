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
        @brief      ê²°í•© ëª¨ë¸ ŒìŠ¤
        @details    
        @details    Figma œì„œ: https://www.figma.com/board/HSxCbkqkyyEQFaKFjmcJqN/Coupled-Model-Test?node-id=0-1&t=xBPKIzNqFDd5kIB2-1
        
        @reference  https://github.com/sumannam/DEVS-Python/issues/27

        @param  model       ê²°í•© ëª¨ë¸¸ìŠ¤´ìŠ¤
        @param  json_file   json Œì¼ ê²½ë¡œ€ Œì¼´ë¦„

        @author     ¨ìˆ˜ë§sumannam@gmail.com)
        @date       2024.04.15        

        @remarks    3) ì‹ ëª¨ë¸ ë¹„êµ, °ì„ œìœ„ •ë³´ ë¦¬ìŠ¤ ì»¤í”Œë§•ë³´ ë¹„êµ ë³ë©”ì†Œì„±[2025.01.22; ¨ìˆ˜ë§
                    2) (Jira-DEVS-49) ŒìŠ¤ ëª¨ë¸ê³¬íŠ¸ì„œ ¤ìˆ˜ëª©ì  ëª¨ë¸ê³¬íŠ¸ê°€ ˜ì˜¬ ˆì–´, ´ë „í•œ ì²˜ë¦¬[2024.04.16; ¨ìˆ˜ë§
                        ˆë ¤ì–´, TRANSD.out -> GENR.stop / TRANSD.out -> EF.result
                    1) ì»¤í”Œë§•ë³´ì„œ ŒìŠ¤ ëª¨ë¸ê¸° ì‹ Œê ˆì–´ ì¡°ê±´ë¬ì¶”ê[2024.04.16; ¨ìˆ˜ë§
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
        @brief      €ê²ê²°í•© ëª¨ë¸˜ìœ„ ëª¨ë¸ ë¹„êµ
        @details    
        
        @reference  https://github.com/sumannam/DEVS-Python/issues/31
        
        @param  target_model        ê²°í•© ëª¨ë¸ ¸ìŠ¤´ìŠ¤ 
        @param  json_child_list     json Œì¼˜ìœ„ ëª¨ë¸ ë¦¬ìŠ¤

        @author     ¨ìˆ˜ë§sumannam@gmail.com)
        @date       2025.01.22
        """
        child_list = target_model.getChildModelNameList()
        
        # ë¦¬ìŠ¤¸ë ¤íŠ¸ë§ìœ¼ë¡ë³€
        child_list_str = ', '.join(child_list)
        json_list_str = json_child_list.get('child_models')
        
        # ë¹„êµ ê²°ê³¼ ì¶œë ¥
        print("=== Child Model ===")
        print(f"\t child_models : {child_list_str}")
        print("\t", self.diffStrings(child_list_str, json_list_str))
        print("\n")
        
    
    def diffPriorityModel(self, target_model, json_priority_list):
        """! 
        @fn         diffPriorityModel
        @brief      €ê²ê²°í•© ëª¨ë¸°ì„ œìœ„ ëª¨ë¸ ë¹„êµ
        @details    
        
        @reference  https://github.com/sumannam/DEVS-Python/issues/31
        
        @param  target_model        ê²°í•© ëª¨ë¸ ¸ìŠ¤´ìŠ¤
        @param  json_priority_list  json Œì¼°ì„ œìœ„ ëª¨ë¸ ë¦¬ìŠ¤

        @author     ¨ìˆ˜ë§sumannam@gmail.com)
        @date       2025.01.22
        """
        priority_list = target_model.getPrioriryModelNameList()
        
        # ë¦¬ìŠ¤¸ë ¤íŠ¸ë§ìœ¼ë¡ë³€
        priority_list_str = ', '.join(priority_list)
        json_list_str = json_priority_list.get('priority')
        
        # ë¹„êµ ê²°ê³¼ ì¶œë ¥
        print("=== priority ===")
        print(f"\t priority : {priority_list_str}")
        print("\t", self.diffStrings(priority_list_str, json_list_str))
        print("\n")
        
    
    def diffCoupling(self, target_model, coupling_list):
        """! 
        @fn         diffCoupling
        @brief      €ê²ê²°í•© ëª¨ë¸ì»¤í”Œë§•ë³´ ë¹„êµ
        @details    
        
        @reference  https://github.com/sumannam/DEVS-Python/issues/27
        
        @param  target_model           ê²°í•© ëª¨ë¸ ¸ìŠ¤´ìŠ¤
        @param  coupling_list   ì»¤í”Œë§•ë³´ ë¦¬ìŠ¤

        @author     ¨ìˆ˜ë§sumannam@gmail.com)
        @date       2025.01.22
        
        @remarks    2) (Jira-DEVS-49) ŒìŠ¤ ëª¨ë¸ê³¬íŠ¸ì„œ ¤ìˆ˜ëª©ì  ëª¨ë¸ê³¬íŠ¸ê°€ ˜ì˜¬ ˆì–´, ´ë „í•œ ì²˜ë¦¬[2024.04.16; ¨ìˆ˜ë§
                        ˆë ¤ì–´, TRANSD.out -> GENR.stop / TRANSD.out -> EF.result
                    1) ì»¤í”Œë§•ë³´ì„œ ŒìŠ¤ ëª¨ë¸ê¸° ì‹ Œê ˆì–´ ì¡°ê±´ë¬ì¶”ê[2024.04.16; ¨ìˆ˜ë§
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
                
                # remarks 2) ´ìŠˆ ì²˜ë¦¬
                if coupling.get(key) in dst_model_port_list:
                    continue
                else:                    
                    json_coupling = key + " -> " + coupling[key]
                    
                    # remarks 2) ´ìŠˆ ì²˜ë¦¬
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
        @brief      ì ëª¨ë¸ ŒìŠ¤
        @details    ì ëª¨ë¸¨ìˆ˜¸ëíƒœ„ì´, ´ëíƒœ„ì´, ì¶œë ¥)ê²€ì¦¼ë¬¸ ‘ì„±

        @param  model       ì ëª¨ë¸¸ìŠ¤´ìŠ¤
        @param  json_file   json Œì¼ ê²½ë¡œ€ Œì¼´ë¦„

        @author     ¨ìˆ˜ë§sumannam@gmail.com)
        @date       2022.01.31

        @remarks    ê²°í•© ëª¨ë¸ ì¶”êë¡ ¨ìˆ˜ëªrunAutoModelTest -> runAtomicModelTest) ë³€ê²2024.04.15; ¨ìˆ˜ë§
                    ˜ì •test_script1.json ë²„ì „¼ë¡œ ë¡œì§ ë³€ê²2022.06.19; ¨ìˆ˜ë§
                    ê²°ê³¼¤ì˜ ë¬¸ìë¹„êµë¬ì¶”ê[2022.06.19; ¨ìˆ˜ë§
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
        @brief      ì ëª¨ë¸ŒìŠ¤ê²°ê³¼(A)€ ¤í¬ë¦½íŠ¸ê²°ê³¼(B)ë¥ë¹„êµ
        @details    ë¹„êµ ê²°ê³¼ 0´ë©´ A==B, 1´ë©´ Bì¶”êë¬¸ìë°œê²¬, -1´ë©´ B œë¬¸ìë°œê²¬

        @param  model_name      ì ëª¨ë¸´ë¦„
        @param  atom_content    ŒìŠ¤¤í¬ë¦½íŠ¸ ë¬¸ì

        @author     ¨ìˆ˜ë§sumannam@gmail.com)
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
        @brief      ë¬¸ìë¹„êµ
        @details    ì ëª¨ë¸ ŒìŠ¤¸ë „í•œ ë¬¸ìë¹„êµ(ì¶”ê ê¸€ ¹ìƒ‰,  œ ê¸€ ë¹¨ê°•)

        @param  a    ì ëª¨ë¸ ŒìŠ¤ê²°ê³¼
        @param  b    JSONassert

        @author     ¨ìˆ˜ë§sumannam@gmail.com)
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