from src.KERNEL_MODELS import KERNEL_MODELS
from src.MODELS import MODELS
from src.PORT import PORT

from src.COUPLING import *

class BROADCAST_MODELS(KERNEL_MODELS):
    def __init__(self, name: str = "BROADCAST_MODELS"):
        """
        Constructor for BROADCAST_MODEL
        
        Parameters:
        -----------
        name : str
            Name of the broadcast model (default: "BROADCAST")
        """
        super().__init__()
        self.setName(name)
        self.controllee = None
        self.controllee_list = []
        
    def makeControllee(self, child_model, num_child):
        """
        Make controllee for broadcast behavior
        
        Parameters:
        -----------
        model : MODELS
            Controllee model
        """
        
        base_name = child_model.__name__
        
        for i in range(num_child):
            model_name = f"{base_name}{i+1}"
            child = child_model(model_name)
            
            self.addModel(child)
            self.controllee = child
            self.controllee_list.append(child)
    
    def getControlleeList(self):
        return self.controllee_list    
        
    def addCoupling(self, src_model, src_port, dst_model, dst_port):
        """
        Add coupling for broadcast behavior
        
        Parameters:
        -----------
        src : MODELS
            Source model
        src_port : PORT
            Source port
        dst : MODELS
            Destination model
        dst_port : PORT
            Destination port
        """
        if(self.existChildModel(src_model)==True and self.existChildModel(dst_model)==True):  # IC (Internal Coupling)
            # for src_controllee in self.controllee_list:
            #     for dst_controllee in self.controllee_list:
            #         # Get ports by name
            #         src_controllee_port = src_controllee.get_out_port(src_port.getName())
            #         dst_controllee_port = dst_controllee.get_in_port(dst_port.getName())
                    
            #         # Add to internal coupling relation
            #         if src_controllee_port and dst_controllee_port:
            #             key = (src_controllee, src_controllee_port.getName())
            #             if key not in self.internal_coupling:
            #                 self.internal_coupling[key] = []
            #             self.internal_coupling[key].append((dst_controllee, dst_controllee_port))
            for i in range(len(self.controllee_list)):
                for j in range(len(self.controllee_list)):
                    self.internal_coupling.addCoupling(self.controllee_list[i], src_port, self.controllee_list[j], dst_port)
                        
        elif(self.existChildModel(src_model)==True and self.existChildModel(dst_model)==False):  # EOC (External Output Coupling)
            for i in range(len(self.controllee_list)):
                self.external_output_coupling.addCoupling(self.controllee_list[i], src_port, dst_model, dst_port)
                    
        elif(self.existChildModel(src_model)==False and self.existChildModel(dst_model)==True):  # EIC (External Input Coupling)
            for i in range(len(self.controllee_list)):
                self.external_input_coupling.addCoupling(src_model, src_port, self.controllee_list[i], dst_port)
        else:
            # Error case - print error message or raise exception
            print(f"Error: Neither {src_model.getName()} nor {dst_port.getName()} is a child of {self.get_name()}")
            
    
    def translate(self, coupling_type, model, port):
        """
        Translate coupling information for broadcast behavior
        
        Parameters:
        -----------
        coupling_type : int
            Type of coupling (EOC: 0, IC: 1, EIC: 2)
        src : MODELS
            Source model
        port : PORT
            Port
            
        Returns:
        --------
        ModelPortList
            List of model-port pairs
        """
        model_port_list = []
        
        if coupling_type == COUPLING_TYPE.EOC:  # External Output Coupling
            key = (model, port)
            if key in self.external_output_coupling:
                model_port_list = self.external_output_coupling[key].copy()
                
        elif coupling_type == COUPLING_TYPE.IC:  # Internal Coupling
            key = (model, port)
            if key in self.internal_coupling:
                model_port_list = self.internal_coupling[key].copy()
                
        elif coupling_type == COUPLING_TYPE.EIC:  # External Input Coupling
            port_name = port
            if port_name in self.external_input_coupling:
                model_port_list = self.external_input_coupling[port_name].copy()
        
        return model_port_list