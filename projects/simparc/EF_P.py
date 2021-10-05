import sys

sys.path.append('D:/Git/DEVS-Python')

from src.DIAGRAPH_MODELS import DIAGRAPH_MODELS

class EF_P(DIAGRAPH_MODELS):
    def __init__(self):
        self.__init__(self, self.__class__.__name__)


if __name__ == '__main__':
    ef_p = EF_P()