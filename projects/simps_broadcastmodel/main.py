import config

# 시뮬레이션
from coupbase.EF_PS import EF_PS

if __name__ == '__main__':
    ef_p = EF_PS()
    ef_p.initialize() 
    ef_p.restart()