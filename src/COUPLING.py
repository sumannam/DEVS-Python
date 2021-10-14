from collections import defaultdict

class COUPLING_INFO():
    def __init__(self, src_model, src_port, dst_model, dst_port):
        self.from_model = src_model
        self.from_port = src_port
        self.to_model = dst_model
        self.to_port = dst_port

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
       
        """
        self.this_model = None
        self.coupling_map = defaultdict(list)
        self.coupling_map_pair = [self.coupling_map, self.coupling_map]


    def addCoupling(self, from_model, from_port, to_model, to_port):
        self.coupling_map = ([from_model, from_port], [to_model, to_port])