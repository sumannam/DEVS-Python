import logging
import os
import sys
from pathlib import Path

global project_path
project_path = ""
PROJECT_NAME = "DEVS-Python"
INFINITY = float('inf')

UNITEST_METHOD = ''

logging.basicConfig(
    format = '(%(filename)s:%(funcName)s:%(lineno)d)\n%(message)s',
    level=logging.INFO,
    filename="sim_msg_log.txt"
)

def logInfoCoordinator(devs_name, time_next, time_last, star_child, wait_list):
    if UNITEST_METHOD == 'testWhenReceiveY':
        devs_engine_log = logging.getLogger('coordinator_log')
        handler = logging.FileHandler('coordinator_log.txt')
        formatter = logging.Formatter('')
        handler.setFormatter(formatter)
        devs_engine_log.addHandler(handler)
        
        log = "devs_comp: " + devs_name + "\n" \
            + "time_next: " + str(time_next) + "\n" \
            + "time_last: " + str(time_last) + "\n" \
            + "star_child: (" + star_child + ")\n" \
            + "wait_list: (" + wait_list + ")\n\n"
        
        devs_engine_log.info(log)
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

