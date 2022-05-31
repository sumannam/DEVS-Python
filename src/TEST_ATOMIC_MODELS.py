import sys
import math
import json
from abc import abstractmethod

sys.path.append('D:/Git/DEVS-Python')

from src.ATOMIC_MODELS import ATOMIC_MODELS
from src.CONTENT import CONTENT

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
        """
        script = open(json_file)
        json_dic = json.load(script)

        model_name = model.getName()

        if model_name not in json_dic.keys():
            print("There is no %s MODEL in %s" %(model_name, json_file))
            return

        for i in json_dic[model_name]:
            x = json_dic[model_name][i]
            print(">>> %s" %x)

            param = [x for x in x.split(' ')]

            input_type = param[2]

            if input_type == "inject":
                port_name = param[3]
                value = param[4]
                elased_time = self.atomic_model.decideNumberType(param[5])

                model.sendInject(port_name, value, elased_time)
                send_result = self.atomic_model.getInjectResult(input_type)
            
            if input_type == "output?":
                output = CONTENT()
                output = model.outputFunc()
                send_result = self.atomic_model.getOutputResult(output)

            if input_type == "int-transition":
                model.internalTransitionFunc()
                send_result = self.atomic_model.getIntTransitionResult()

            print(send_result)