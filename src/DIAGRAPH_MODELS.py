import sys

sys.path.append('D:/Git/DEVS-Python')

from src.COUPLED_MODELS import COUPLED_MODELS

class DIAGRAPH_MODELS(COUPLED_MODELS):
    def __init__(self, model_name):
        COUPLED_MODELS.__init__(self, model_name)