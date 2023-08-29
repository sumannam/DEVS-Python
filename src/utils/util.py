import logging
import os
import sys
from pathlib import Path

global project_path
project_path = ""
PROJECT_NAME = "DEVS-Python"
INFINITY = float('inf')

def setDevPath():
    global project_path

    current_path = Path.cwd()
    path_str = str(current_path)

    if path_str[-11:] == PROJECT_NAME:
        sys.path.append(path_str)

        project_path = os.path.dirname(__file__)
        sys.path.append(project_path)
    if path_str.find("projects") == -1:
        pass
        # os.walk("..")
        # current_path = Path.cwd()
        # parent_path = current_path.parent.name
        # print(parent_path)


print(project_path)

logging.basicConfig(
    format = '(%(filename)s:%(funcName)s:%(lineno)d)\n%(message)s',
    level=logging.INFO,
    filename="sim_msg_log.txt"
)

def logInfoCoordinator(devs_name, time_next, time_last, star_child, wait_list):

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

