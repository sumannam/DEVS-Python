import sys

from src.COUPLED_MODELS import COUPLED_MODELS

from projects.coupledmodelTest.mbase.SENSOR import SENSOR
from projects.coupledmodelTest.mbase.SENSOR_CONTROLLER import SENSOR_CONTROLLER

class SENSORS(COUPLED_MODELS):
   def __init__(self, name):
       super().__init__(name)
       
       # 포트 정의
       self.in_port = self.addInPort("in")
       self.out_port = self.addOutPort("out")
       
       # 하위 모델 생성
       self.addModel(SENSOR("SN"))
       self.addModel(SENSOR_CONTROLLER("sensor_controller"))
       
       # 외부 입출력 커플링
       self.addCoupling(self, "in", self.sensor_controller, "in")
       self.addCoupling(self.sensor_controller, "out", self, "out")
       
       # 내부 커플링
       self.addCoupling(self.sensor_controller, "event_out", self.sensor, "event_in")
       self.addCoupling(self.sensor_controller, "packet_out", self.sensor, "packet_in") 
       self.addCoupling(self.sensor, "packet_out", self.sensor_controller, "packet_in")
       self.addCoupling(self.sensor, "sensor_out", self.sensor_controller, "sensor_in")