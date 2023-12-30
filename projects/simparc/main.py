import config

# 시뮬레이션
from projects.simparc.coupbase.EF_P import EF_P
if __name__ == '__main__':
    ef_p = EF_P()
    ef_p.initialize() 
    ef_p.restart()