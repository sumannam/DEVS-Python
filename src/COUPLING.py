from enum import Enum
from collections import defaultdict

class COUPLING_TYPE(Enum):
    EOC = 1
    EIC = 2
    IC = 3

class COUPLING():
    def __init__(self):
        """! 
        @fn         __init__
        @brief      커플링 초기화
        @details    c_model: 현재 모델
                    coupling_map key: src_port | Value: dst_model->des_port
                    coupling_map_pair: coupling_map->coupling_map

        @author     남수만(sumannam@gmail.com)
        @date       2021.10.14
       
        @remark     모델 인스턴스로 map의 key로 설정하기 어려워 문자열로 변환하여 딕셔널리(coupling_dic)에 저장 [2021.10.26; 남수만]
        """
        self.this_model = None
        self.coupling_dic = {}
        # self.coupling_map = defaultdict(list)
        # self.coupling_map_pair = [self.coupling_map, self.coupling_map]


    def addDictionaryValue(self, key, value):
        if key in self.coupling_dic:
            self.coupling_dic[key].append(value)
        else:
            self.coupling_dic[key]=[value]        

    def addCoupling(self, from_model, from_port, to_model, to_port):
        """! 
        @fn         addCoupling
        @brief      모델의 커플링 정보 추가
        @details    커플링의 관계는 다음과 같이 저장된다.
 			    	Key (Source) 		| Value (Destination) 
 		    		--------------------|---------------------
 	    			[P, out]     		| [(EF, in1) (EF.in2)]

        @param from_model   소스 모델
        @param from_port    소스 모델의 포트
        @param to_model     목적지 모델
        @param to_port      목적지 모델의 포트

        @author     남수만(sumannam@gmail.com)
        @date       2021.10.15        

        @remark     중복 키 허용을 위해 value를 list로 변경[남수만; 2021.12.27]
                    모델의 인스턴스로 바로 저장하고 사용하기가 어려워 커플링 정보를 문자열로 변경하여 저장 [남수만; 2021.10.26]

        @todo       [취소] map를 dictionary로 변경하고 key 중복 허용(https://kangprog.tistory.com/27) [남수만; 2021.10.25]
        """

        src_key = from_model.__class__.__name__ + "." + from_port
        dst_value = to_model.__class__.__name__ + "." + to_port
        
        self.addDictionaryValue(src_key, dst_value)

    def find(self, src_model_port):
        """! 
        @fn         find
        @brief      소스 모델에서 일치된 모델.포트이름이 있는지 검색
        @details    입력: 모델.포트이름

        @param src_model_port   "소스 모델 이름"."포트 이름"

        @return     있으면 True, 없으면 False
        
        @author     남수만(sumannam@gmail.com)
        @date       2021.12.13
        """
        if src_model_port in self.coupling_dic:
            return True
        else:
            return False

    def get(self, model_port):
        model_port_list = []
        model_port_list = self.coupling_dic.get(model_port)
        return model_port_list