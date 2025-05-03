import logging
import os
import sys
import json
from pathlib import Path
from datetime import datetime

global project_path
project_path = ""
PROJECT_NAME = "DEVS-Python"
INFINITY = float('inf')

UNITEST_METHOD = ''

# Log level configuration
LOG_LEVEL = logging.INFO  # Default to INFO

# Remove existing log file if it exists
log_file = "sim_msg_log.txt"
if os.path.exists(log_file):
    os.remove(log_file)

# Configure logging with improved format
class CustomFormatter(logging.Formatter):
    def format(self, record):
        if record.levelno == logging.DEBUG:
            self._style._fmt = '[%(asctime)s] %(levelname)s\nFile: %(filename)s\nMethod: %(funcName)s\nLine: %(lineno)d\n%(message)s'
        else:
            self._style._fmt = '[%(asctime)s] %(levelname)s\n%(message)s'
        return super().format(record)

# Create logger
logger = logging.getLogger()
logger.setLevel(LOG_LEVEL)

# Create file handler
file_handler = logging.FileHandler(log_file, mode='w')
file_handler.setLevel(LOG_LEVEL)

# Create formatter and add it to the handler
formatter = CustomFormatter(datefmt='%Y-%m-%d %H:%M:%S')
file_handler.setFormatter(formatter)

# Add the handler to the logger
logger.addHandler(file_handler)

def setLogLevel(level):
    """Set the logging level for the application"""
    global LOG_LEVEL
    LOG_LEVEL = level
    logger.setLevel(level)
    file_handler.setLevel(level)

def logDebugCoordinator(devs_name, time_next, time_last, star_child, wait_list):
    if LOG_LEVEL <= logging.DEBUG:
        log = f"""
Coordinator Debug Info:
----------------------
Component: {devs_name}
Time Next: {time_next}
Time Last: {time_last}
Star Child: ({star_child})
Wait List: ({wait_list})
"""
        logging.debug(log)

def logDebugSimulator(devs_name, time_next, time_last):
    if LOG_LEVEL <= logging.DEBUG:
        log = f"""
Simulator Debug Info:
-------------------
Component: {devs_name}
Time Next: {time_next}
Time Last: {time_last}
"""
        logging.debug(log)

def logInfoCoordinator(devs_name, time_next, time_last, star_child, wait_list):
    if LOG_LEVEL <= logging.INFO:
        if UNITEST_METHOD == 'testCoordinatorWhenReceiveY':
            coordinator_y_log = logging.getLogger('coordinator_y_log')
            handler = logging.FileHandler('coordinator_y_log.txt')
            formatter = logging.Formatter('[%(asctime)s] %(levelname)s\n%(message)s', datefmt='%Y-%m-%d %H:%M:%S')
            handler.setFormatter(formatter)
            coordinator_y_log.addHandler(handler)
            
            log = f"""
Coordinator Info:
----------------
Component: {devs_name}
Time Next: {time_next}
Time Last: {time_last}
Star Child: ({star_child})
Wait List: ({wait_list})
"""
            coordinator_y_log.info(log)
        elif UNITEST_METHOD == 'testCoordinatorWhenReceiveDone':
            coordinator_done_log = logging.getLogger('coordinator_done_log')
            handler = logging.FileHandler('coordinator_done_log.txt')
            formatter = logging.Formatter('[%(asctime)s] %(levelname)s\n%(message)s', datefmt='%Y-%m-%d %H:%M:%S')
            handler.setFormatter(formatter)
            coordinator_done_log.addHandler(handler)
            
            log = f"""
Coordinator Info:
----------------
Component: {devs_name}
Time Next: {time_next}
Time Last: {time_last}
Star Child: ({star_child})
Wait List: ({wait_list})
"""
            coordinator_done_log.info(log)
        else:
            log = f"""
Coordinator Info:
----------------
Component: {devs_name}
Time Next: {time_next}
Time Last: {time_last}
Star Child: ({star_child})
Wait List: ({wait_list})
"""
            logging.info(log)

def logInfoSimulator(devs_name, time_next, time_last):
    if LOG_LEVEL <= logging.INFO:
        log = f"""
Simulator Info:
--------------
Component: {devs_name}
Time Next: {time_next}
Time Last: {time_last}
"""
        logging.info(log)

def logWarning(message):
    """Log warning messages about potential issues"""
    if LOG_LEVEL <= logging.WARNING:
        logging.warning(f"""
Warning:
--------
{message}
""")

def logError(message, error=None):
    """Log error messages with optional error details"""
    if LOG_LEVEL <= logging.ERROR:
        error_details = f"\nError Details:\n{str(error)}" if error else ""
        logging.error(f"""
Error:
------
{message}{error_details}
""")

def logCritical(message, error=None):
    """Log critical error messages that may prevent program execution"""
    if LOG_LEVEL <= logging.CRITICAL:
        error_details = f"\nError Details:\n{str(error)}" if error else ""
        logging.critical(f"""
Critical Error:
--------------
{message}{error_details}
""")

def convertJsonToString(dict):
    return json.dumps(dict, indent=2)

def convertStringToJson(str):
    return json.loads(str)