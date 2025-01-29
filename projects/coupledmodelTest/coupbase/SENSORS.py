import sys

from src.COUPLED_MODELS import COUPLED_MODELS

from projects.coupledmodelTest.mbase.SENSOR import SENSOR
from projects.coupledmodelTest.mbase.SENSOR_CONTROLLER import SENSOR_CONTROLLER

class SENSORS(COUPLED_MODELS):
   def __init__(self):
        COUPLED_MODELS.__init__(self)
        self.setName(self.__class__.__name__)

        sensor = SENSOR()
        sensor_controller = SENSOR_CONTROLLER()

        # 하위 모델 생성
        self.addModel(sensor)
        self.addModel(sensor_controller)
        
        # 포트 정의
        self.in_port = self.addInPort("in")
        self.out_port = self.addOutPort("out")

        # 외부 입출력 커플링
        self.addCoupling(self, "in", sensor_controller, "in")
        self.addCoupling(sensor_controller, "out", self, "out")

        # 내부 커플링
        self.addCoupling(sensor_controller, "event_out", sensor, "event_in")
        self.addCoupling(sensor_controller, "packet_out", sensor, "packet_in") 
        self.addCoupling(sensor, "packet_out", sensor_controller, "packet_in")
        self.addCoupling(sensor, "sensor_out", sensor_controller, "sensor_in")

        # self.priority_list.extend([sensor_controller, sensor])