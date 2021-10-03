import sys
import unittest

sys.path.append('D:/Git/DEVS-Python')

from projects.simparc.P import P
from src.CONTENT import CONTENT

class Test_testModelTest(unittest.TestCase):
    def setUp(self):
        self.p = P()

    def test_modeltest_p_inject(self):
        self.p.sendInject("in", "g1", 5)
        send_result = self.p.getInjectResult("inject")

        assert send_result == "state s = (10 busy g1 10)"

    def test_modeltest_p_output(self):
        self.p.sendInject("in", "g1", 5)

        output = CONTENT()
        output = self.p.outputFunc(self.p.state)
        send_result = self.p.getOutputResult(output)

        assert send_result == "y = " + output.port + " " + output.value

    def test_modeltest_p_inttransition(self):
        self.p.sendInject("in", "g1", 5)
        output = CONTENT()
        output = self.p.outputFunc(self.p.state)

        self.p.internalTransitionFunc(self.p.state)
        send_result = self.p.getIntTransitionResult()

        assert send_result == "state s = (inf passive g1 10)"

if __name__ == '__main__':
    unittest.main()