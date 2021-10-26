import sys
import unittest

sys.path.append('D:/Git/DEVS-Python')

from testPModelTest import testPModelTest
from testEF_PModel import testEF_PModel

if __name__ == '__main__':
    test_p = unittest.TestLoader().loadTestsFromTestCase(testPModelTest)
    test_efp = unittest.TestLoader().loadTestsFromTestCase(testEF_PModel)

    allTests = unittest.TestSuite()
    allTests.addTest(test_p)
    allTests.addTest(test_efp)

    unittest.TextTestRunner(verbosity=2, failfast=True).run(allTests)