import sys

sys.path.append('D:/Git/DEVS-Python')
sys.path.append('D:/Git/DEVS-Python/projects/simparc')


from src.DIAGRAPH_MODELS import DIAGRAPH_MODELS

from P import P

class EF_P(DIAGRAPH_MODELS):
    def __init__(self):
        DIAGRAPH_MODELS.__init__(self, self.__class__.__name__)
        
        self.addModel(P)

        


if __name__ == '__main__':
    ef_p = EF_P()