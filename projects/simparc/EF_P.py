import sys

sys.path.append('D:/Git/DEVS-Python')
sys.path.append('D:/Git/DEVS-Python/projects/simparc')

from src.COUPLED_MODELS import COUPLED_MODELS

from P import P

class EF_P(COUPLED_MODELS):
    def __init__(self):
        COUPLED_MODELS.__init__(self, self.__class__.__name__)

        p = P()
        
        self.addModel(p)


if __name__ == '__main__':
    ef_p = EF_P()