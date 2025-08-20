from abc import abstractmethod

from src.COUPLED_MODELS import COUPLED_MODELS
from src.PORT import PORT
from src.MODELS import MODELS

from src.COUPLING import *

class KERNEL_MODELS(COUPLED_MODELS):
    """
    KERNEL_MODELS class - Base class for kernel models in DEVS simulation
    
    This class implements the foundation for specialized kernel models like broadcast,
    which can be used to distribute messages to multiple recipient models.
    """
    
    def __init__(self):
        """
        Constructor for KERNEL_MODELS
        """
        super().__init__()
        # self.init_cell =  = None
        self.controllee_list = []
        
        # Coupling relations
        self.external_output_coupling = COUPLING()
        self.external_input_coupling = COUPLING()
        self.internal_coupling = COUPLING()
    
    def addCoupling(self, src_model: MODELS, src_port: PORT, 
                    dst_model: MODELS, dst_port: PORT) -> None:
        """
        Add coupling between models
        
        Parameters:
        -----------
        src_model : MODELS
            Source model
        src_port : PORT
            Source port
        dst_model : MODELS
            Destination model
        dst_port : PORT
            Destination port
        """
        pass
    
    @abstractmethod
    def makeControllee(self, child_model, num_controllee):
        pass
    
    def translate(self, coupling_type, model, port):

        """
        Translate coupling information
        
        Parameters:
        -----------
        coupling_type : int
            Type of coupling
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
        return model_port_list