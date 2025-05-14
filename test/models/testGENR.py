import sys
import os
import unittest

from src.PORT import PORT

from projects.simparc.mbase.GENR import GENR

class testGENR(unittest.TestCase):
    def setUp(self):
        """테스트 전에 실행되는 설정"""
        self.genr = GENR()

    def test_initial_state(self):
        """초기 상태 테스트"""
        self.assertEqual(self.genr.state["phase"], "active")
        self.assertEqual(self.genr.state["sigma"], 0)
        self.assertEqual(self.genr.state["inter_arrival_time"], 3)
        self.assertEqual(self.genr.count, 1)

    def test_external_transition_stop(self):
        """중지 이벤트 처리 테스트"""
        # 중지 이벤트 생성
        port = PORT()
        port.port = "stop"
        
        # 외부 전이 함수 실행
        self.genr.externalTransitionFunc(10.0, port)
        
        # 상태 검증
        self.assertEqual(self.genr.state["phase"], "passive")

    def test_external_transition_continue(self):
        """계속 이벤트 처리 테스트"""
        # 계속 이벤트 생성 (stop이 아닌 포트)
        port = PORT()
        port.port = "other"
        
        # 외부 전이 함수 실행
        self.genr.externalTransitionFunc(10.0, port)
        
        # 상태 검증 - 상태가 변경되지 않아야 함
        self.assertEqual(self.genr.state["phase"], "active")

    def test_internal_transition(self):
        """내부 전이 함수 테스트"""
        # 내부 전이 함수 실행
        self.genr.internalTransitionFunc()
        
        # 상태 검증
        self.assertEqual(self.genr.state["phase"], "active")
        self.assertEqual(self.genr.state["sigma"], 3)  # inter_arrival_time

    def test_output_function(self):
        """출력 함수 테스트"""
        # 첫 번째 작업 생성
        output1 = self.genr.outputFunc()
        self.assertIsNotNone(output1)
        self.assertEqual(output1.port, "out")
        self.assertEqual(output1.value, "JOB-1")
        
        # 내부 전이 실행
        self.genr.internalTransitionFunc()
        
        # 두 번째 작업 생성
        output2 = self.genr.outputFunc()
        self.assertIsNotNone(output2)
        self.assertEqual(output2.port, "out")
        self.assertEqual(output2.value, "JOB-2")
        
        # 카운터 증가 확인
        self.assertEqual(self.genr.count, 3)

    def test_sequential_job_generation(self):
        """순차적 작업 생성 테스트"""
        # 여러 작업을 순차적으로 생성
        for i in range(1, 4):
            output = self.genr.outputFunc()
            self.assertEqual(output.value, f"JOB-{i}")
            self.genr.internalTransitionFunc()
        
        # 최종 카운터 값 확인
        self.assertEqual(self.genr.count, 4)

if __name__ == '__main__':
    unittest.main()
