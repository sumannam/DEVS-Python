from collections import defaultdict

class COUPLING_INFO():
    def __init__(self, src_model, src_port, dst_model, dst_port):
        self.from_model = src_model
        self.from_port = src_port
        self.to_model = dst_model
        self.to_port = dst_port

class COUP_MODEL():
    def __init__(self, name):
        self.name = name

    def __str__(self):
        return self.name

    def __repr__(self):
        return "'"+self.name+"'"


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


    def addCoupling(self, from_model, from_port, to_model, to_port):
        """! 
        @fn         addCoupling
        @brief      모델의 커플링 정보 추가
        @details    커플링의 관계는 다음과 같이 저장된다.
 			    	Key (Source) 		| Value (Destination) 
 		    		--------------------|---------------------
 	    			[P, out]     		| [EF, in]			  

        @param from_model   소스 모델
        @param from_port    소스 모델의 포트
        @param to_model     목적지 모델
        @param to_port      목적지 모델의 포트

        @author     남수만(sumannam@gmail.com)
        @date       2021.10.15        

        @remark     모델의 인스턴스로 바로 저장하고 사용하기가 어려워 커플링 정보를 문자열로 변경하여 저장 [남수만;2021.10.26]

        @todo       [취소] map를 dictionary로 변경하고 key 중복 허용(https://kangprog.tistory.com/27) [남수만;2021.10.25]
        """
        src_key = from_model.__class__.__name__ + "." + from_port
        dst_value = to_model.__class__.__name__ + "." + to_port
        self.coupling_dic[src_key] = dst_value
        #self.coupling_map[from_model, from_port].append(model_list)
        # self.coupling_map = ([from_model, from_port], [to_model, to_port])