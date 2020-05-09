import math
from MODELS import MODELS


class ATOMIC_MODELS(MODELS):
    sigma
    phase = ""

    def __init__(self):
        self.sigma = math.inf
        self.phase = ""

    def setName(seft, _name):
        self.name = _name

    def holdIn(self, _sigma, _phase):
        self.sigma = _sigma
        self.phase = _phase
        



