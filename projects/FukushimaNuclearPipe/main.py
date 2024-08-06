import config

# 시뮬레이션
from coupbase.EF_PIPE import EF_PIPE
if __name__ == '__main__':
    ef_piping = EF_PIPE()
    ef_piping.initialize() 
    ef_piping.restart()