import logging
import os
import sys
import json
from pathlib import Path

global project_path
project_path = ""
PROJECT_NAME = "DEVS-Python"
INFINITY = float('inf')

UNITEST_METHOD = ''

# logger = logging.getLogger(name='sim_msg_log')
# logger.setLevel(logging.INFO)
# handler = logging.FileHandler('sim_msg_log.txt')
# formatter = logging.Formatter('(%(filename)s:%(funcName)s:%(lineno)d)\n%(message)s')
# handler.setFormatter(formatter)
# logger.addHandler(handler)


logging.basicConfig(
    format = '(%(filename)s:%(funcName)s:%(lineno)d)\n%(message)s',
    level=logging.INFO,
    filename="sim_msg_log.txt"
)

def logInfoCoordinator(devs_name, time_next, time_last, star_child, wait_list):
    if UNITEST_METHOD == 'testCoordinatorWhenReceiveY':
        coordinator_y_log = logging.getLogger('coordinator_y_log')
        handler = logging.FileHandler('coordinator_y_log.txt')
        formatter = logging.Formatter('')
        handler.setFormatter(formatter)
        coordinator_y_log.addHandler(handler)
        
        log = "devs_comp: " + devs_name + "\n" \
            + "time_next: " + str(time_next) + "\n" \
            + "time_last: " + str(time_last) + "\n" \
            + "star_child: (" + star_child + ")\n" \
            + "wait_list: (" + wait_list + ")\n\n"
        
        coordinator_y_log.info(log)
    elif UNITEST_METHOD == 'testCoordinatorWhenReceiveDone':
        coordinator_done_log = logging.getLogger('coordinator_done_log')
        handler = logging.FileHandler('coordinator_done_log.txt')
        formatter = logging.Formatter('')
        handler.setFormatter(formatter)
        coordinator_done_log.addHandler(handler)
        
        log = "devs_comp: " + devs_name + "\n" \
            + "time_next: " + str(time_next) + "\n" \
            + "time_last: " + str(time_last) + "\n" \
            + "star_child: (" + star_child + ")\n" \
            + "wait_list: (" + wait_list + ")\n\n"
        
        coordinator_done_log.info(log)
    else:
        log = "devs_comp: " + devs_name + "\n" \
            + "time_next: " + str(time_next) + "\n" \
            + "time_last: " + str(time_last) + "\n" \
            + "star_child: (" + star_child + ")\n" \
            + "wait_list: (" + wait_list + ")\n\n"
        logging.info(log)

def logInfoSimulator(devs_name, time_next, time_last):
    log = "devs_comp: " + devs_name + "\n" \
        + "time_next: " + str(time_next) + "\n" \
        + "time_last: " + str(time_last) + "\n\n"
    logging.info(log)
    



def convertJsonToString(dict):
     return json.dumps(dict)

def convertStringToJson(str):
    return json.loads(str)