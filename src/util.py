import logging

# sys.path.append('D:/Git/DEVS-Python')

logging.basicConfig(
    format = '(%(filename)s:%(funcName)s:%(lineno)d)\n%(message)s',
    level=logging.INFO
)

INFINITY = float('inf')


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

