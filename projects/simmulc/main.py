import config

# 시뮬레이션
from projects.simmulc.coupbase.EF_PIPING import EF_PIPING
if __name__ == '__main__':
    ef_piping = EF_PIPING()
    ef_piping.initialize() 
    ef_piping.restart()