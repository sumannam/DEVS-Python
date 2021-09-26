import unittest

from P import P

class Test_testModelTest(unittest.TestCase):
    def setUp(self):
        self.p = P()

    def test_modeltest_inject(self):
        assert self.p.modelTest()
        #assert self.p.exter

if __name__ == '__main__':
    unittest.main()
