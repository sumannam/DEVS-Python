import sys

sys.path.append('D:/Git/DEVS-Python')

from src.ENTITIES import ENTITIES

class PROCESSORS(ENTITIES):
    def __init__(self, model_name):
        self.name = model_name

        print(self.name)