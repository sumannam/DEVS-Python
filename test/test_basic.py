import sys
import unittest

sys.path.append('D:/Git/DEVS-Python')

from testPModelTest import testPModelTest
from testEF_P import testEF_P
from testROOT_CO_ORDINATORS import testROOT_CO_ORDINATORS

if __name__ == '__main__':
    test_p = unittest.TestLoader().loadTestsFromTestCase(testPModelTest)
    test_efp = unittest.TestLoader().loadTestsFromTestCase(testEF_P)
    test_root_coordinators = unittest.TestLoader().loadTestsFromTestCase(testROOT_CO_ORDINATORS)

    allTests = unittest.TestSuite()
    allTests.addTest(test_p)
    allTests.addTest(test_efp)
    allTests.addTest(test_root_coordinators)

    unittest.TextTestRunner(verbosity=2, failfast=True).run(allTests)