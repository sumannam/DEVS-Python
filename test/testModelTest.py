import unittest

from P import P

class Test_testModelTest(unittest.TestCase):
    def setUp(self):
        self.p = P()

    def test_modeltest_p_inject(self):
        self.p.send("in", "g1", 5)
        send_result = self.p.sendPrint("inject")
        assert send_result == "state s = (inf passive g1 10)"

    def test_modeltest_p_output(self):
        output = CONTENT()
        output = self.outputFunc(self.state)
        send_result = self.getOutputResult(output)
        assert send_result == "y = " + output.port + " " + output.value

    def test_modeltest_p_inttransition(self):
        self.internalTransitionFunc(self.state)
        send_result = self.getIntTransitionResult()

if __name__ == '__main__':
    unittest.main()
