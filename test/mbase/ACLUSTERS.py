import sys

from src.COUPLED_MODELS import COUPLED_MODELS

from projects.coupledmodelTest.mbase.CLUSTER import CLUSTER
from projects.coupledmodelTest.mbase.CONTROLLER import CONTROLLER

class ACLUSTERS(COUPLED_MODELS):
	def __init__(self):
		COUPLED_MODELS.__init__(self)
		self.setName(self.__class__.__name__)

		cluster = CLUSTER()
		controller = CONTROLLER()

		self.addModel(cluster)
		self.addModel(controller)		

		# 포트 정의
		self.addInPorts("in")
		self.addOutPorts("out")

		# 외부 입력 커플링 
		self.addCoupling(self, "in", controller, "in")

		# 외부 출력 커플링
		self.addCoupling(controller, "out", self, "out")

		# 컨트롤러 -> 클러스터 커플링
		self.addCoupling(controller, "event_out", cluster, "event_in")
		self.addCoupling(controller, "packet_ach_out", cluster, "packet_ach_in")
		self.addCoupling(controller, "packet_amb_out", cluster, "packet_amb_in")
		self.addCoupling(controller, "knowledge_out", cluster, "knowledge_in")

		# 클러스터 -> 컨트롤러 커플링
		self.addCoupling(cluster, "knowledge_out", controller, "knowledge_in")
		self.addCoupling(cluster, "result_out", controller, "result_in")