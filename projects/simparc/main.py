import sys

sys.path.append('D:/Git/DEVS-Python')
sys.path.append('D :/Git/DEVS-Python/projects/simparc')

from projects.simparc.EF_P import EF_P


if __name__ == '__main__':
    ef_p = EF_P()
    ef_p.initialize() 
    ef_p.restart()
    