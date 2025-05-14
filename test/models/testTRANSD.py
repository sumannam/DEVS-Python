import sys
import os
import unittest

from src.PORT import PORT

from projects.simparc.mbase.TRANSD import TRANSD

class testTRANSD(unittest.TestCase):
    def setUp(self):
        """테스트 전에 실행되는 설정"""
        self.transd = TRANSD()

    def test_initial_state(self):
        """초기 상태 테스트"""
        self.assertEqual(self.transd.state["phase"], "active")
        self.assertEqual(self.transd.state["sigma"], 30)  # observation_interval
        self.assertEqual(self.transd.state["clock"], 0.0)
        self.assertEqual(self.transd.state["total_ta"], 0.0)
        self.assertEqual(self.transd.state["arrived_list"], {})
        self.assertEqual(self.transd.state["solved_list"], {})

    def test_external_transition_arrived(self):
        """도착 이벤트 처리 테스트"""
        # 도착 이벤트 생성
        port = PORT()
        port.port = "arrived"
        port.value = "job1"
        
        # 외부 전이 함수 실행
        self.transd.externalTransitionFunc(10.0, port)
        
        # 상태 검증
        self.assertEqual(self.transd.state["clock"], 10.0)
        self.assertEqual(self.transd.state["arrived_list"]["job1"], 0.0)

    def test_external_transition_solved(self):
        """해결 이벤트 처리 테스트"""
        # 먼저 작업 도착
        port_arrived = PORT()
        port_arrived.port = "arrived"
        port_arrived.value = "job1"
        self.transd.externalTransitionFunc(10.0, port_arrived)
        
        # 작업 해결
        port_solved = PORT()
        port_solved.port = "solved"
        port_solved.value = "job1"
        self.transd.externalTransitionFunc(20.0, port_solved)
        
        # 상태 검증
        self.assertEqual(self.transd.state["clock"], 30.0)
        self.assertEqual(self.transd.state["solved_list"]["job1"], 10.0)
        self.assertEqual(self.transd.state["total_ta"], 10.0)  # 30.0 - 10.0

    def test_internal_transition(self):
        """내부 전이 함수 테스트"""
        self.transd.internalTransitionFunc()
        
        # 상태 검증
        self.assertEqual(self.transd.state["phase"], "passive")
        self.assertEqual(self.transd.state["clock"], 30.0)  # observation_interval

    def test_output_function(self):
        """출력 함수 테스트"""
        # 작업 도착 및 해결 시나리오 설정
        port_arrived = PORT()
        port_arrived.port = "arrived"
        port_arrived.value = "job1"
        self.transd.externalTransitionFunc(10.0, port_arrived)
        
        port_solved = PORT()
        port_solved.port = "solved"
        port_solved.value = "job1"
        self.transd.externalTransitionFunc(20.0, port_solved)
        
        # 출력 함수 실행
        output = self.transd.outputFunc()
        
        # 출력 검증
        self.assertIsNotNone(output)
        self.assertEqual(output.port, "out")
        self.assertEqual(output.value, 10.0)  # 평균 처리 시간

    def test_get_arrival_time(self):
        """도착 시간 조회 함수 테스트"""
        # 작업 도착 설정
        port = PORT()
        port.port = "arrived"
        port.value = "job1"
        self.transd.externalTransitionFunc(10.0, port)
        
        # 도착 시간 조회 및 검증
        arrival_time = self.transd.get_arrival_time("job1")
        self.assertEqual(arrival_time, 0.0)
        
        # 존재하지 않는 작업 ID 테스트
        # non_existent_time = self.transd.get_arrival_time("non_existent")
        # self.assertEqual(non_existent_time, -1)

if __name__ == '__main__':
    unittest.main()
