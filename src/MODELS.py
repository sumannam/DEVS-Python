from ENTITIES import ENTITIES
from PORT import PORT

class MODELS(ENTITIES):
    def __init__(self, model_name):
        self.name = model_name
        self.inport_list = []
        self.outport_list = []
    
    def addInPort(self, port_name):
        if port_name not in self.inport_list:
            self.inport_list.append(port_name)

    def addOutPort(self, port_name):
        if port_name not in self.outport_list:
            self.outport_list.append(port_name)

    def getInports(self):
        return self.inport_list

    def getOutports(self):
        return self_outport_list

    def getInport(self, port_name):
        port = PORT(port_name)
        if (port in self.inport_list) == true:
            return port in self.inport_list
        else:
            return None

    def getOutport(self, port_name):
        port = PORT(port_name)
        if (port in self.outport_list) == true:
            return port in self.outport_list
        else:
            return None