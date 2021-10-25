import sys
import unittest

sys.path.append('D:/Git/DEVS-Python')

from projects.simparc.P import P
from src.CONTENT import CONTENT

class Test_tesPModelTest(unittest.TestCase):
    def setUp(self):
        self.p = P()

    def test_modeltest_p_inject(self):
        """! 
        @fn         test_modeltest_p_inject
        @brief      P 모델 External Transition Function 테스트
        @details    >>> send p inject in g1 5

        @author     남수만(sumannam@gmail.com)
        @date       2021.10.21
        """
        self.p.sendInject("in", "g1", 5)
        send_result = self.p.getInjectResult("inject")

        assert send_result == "state s = (10 busy g1 10)"

    def test_modeltest_p_output(self):
        """! 
        @fn         test_modeltest_p_output
        @brief      P 모델 Output Function 테스트
        @details    >>> send p inject in g1 5
                    >>> send p output?

        @author     남수만(sumannam@gmail.com)
        @date       2021.10.21
        """
        self.p.sendInject("in", "g1", 5)

        output = CONTENT()
        output = self.p.outputFunc(self.p.state)
        send_result = self.p.getOutputResult(output)

        assert send_result == "y = " + output.port + " " + output.value

    def test_modeltest_p_inttransition(self):
        """! 
        @fn         test_modeltest_p_output
        @brief      P 모델 Internal Transition Function 테스트
        @details    >>> send p inject in g1 5
                    >>> send p output?
                    >>> send p int-transition

        @author     남수만(sumannam@gmail.com)
        @date       2021.10.21
        """
        self.p.sendInject("in", "g1", 5)
        self.p.outputFunc(self.p.state)

        self.p.internalTransitionFunc(self.p.state)
        send_result = self.p.getIntTransitionResult()

        assert send_result == "state s = (inf passive g1 10)"

    def test_modeltest_p_inject(self):
        """! 
        @fn         test_modeltest_p_output
        @brief      P 모델 External Transition Function 테스트
        @details    >>> send p inject in g1 5
                    >>> send p inject in g2 1

        @author     남수만(sumannam@gmail.com)
        @date       2021.10.21
        """
        self.p.sendInject("in", "g1", 5)
        self.p.sendInject("in", "g2", 1)

        send_result = self.p.getInjectResult("inject")

        assert send_result == "state s = (9 busy g1 10)"

if __name__ == '__main__':
    unittest.main()