import sys

sys.path.append('D:/Git/DEVS-Python')

from src.PROCESSORS import PROCESSORS
from src.ROOT_CO_ORDINATORS import ROOT_CO_ORDINATORS

class CO_ORDINATORS(PROCESSORS):
    def __init__(self):
        self.parent=ROOT_CO_ORDINATORS()
        self.parent.setChild(self)

        self.devs_cmponent = None
