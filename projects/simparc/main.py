import os
import sys
import json

sys.path.append('D:/Git/DEVS-Python')
sys.path.append('D:/Git/DEVS-Python/projects/simparc')

THIS_FOLDER = os.path.dirname(os.path.abspath(__file__))

from projects.simparc.P import P

if __name__ == '__main__':
    # p = P()
    # p.modelTest(p)
    json_file = os.path.join(THIS_FOLDER, 'p_test.json')

    script = open(json_file)
    json_dic = json.load(script)

    for i in json_dic["p"]:
        print(json_dic["p"][i])



from projects.simparc.EF_P import EF_P
# if __name__ == '__main__':
#     ef_p = EF_P()
#     ef_p.initialize() 
#     ef_p.restart()
    