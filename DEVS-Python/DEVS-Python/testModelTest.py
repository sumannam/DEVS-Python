import unittest

from P import P

class Test_testModelTest(unittest.TestCase):
    def setUp(self):
        self.p = P()

    def test_modeltest_inject(self):
        self.p.send("in", "g1", 5)
        send_result = self.p.sendPrint("inject")
        assert send_result == "state s = (inf passive g1 10)"

if __name__ == '__main__':
    unittest.main()
