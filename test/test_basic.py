import sys
import unittest

sys.path.append('D:/Git/DEVS-Python')

from testPModelTest import testPModelTest
# from testEF_P import testEF_P
# from testROOT_CO_ORDINATORS import testROOT_CO_ORDINATORS

if __name__ == '__main__':
    test_p0 = unittest.TestLoader().loadTestsFromTestCase(testPModelTest)
    test_p1 = unittest.TestLoader().loadTestsFromTestCase(testPModelTest)
    test_p2 = unittest.TestLoader().loadTestsFromTestCase(testPModelTest)
    test_p3 = unittest.TestLoader().loadTestsFromTestCase(testPModelTest)
    test_p4 = unittest.TestLoader().loadTestsFromTestCase(testPModelTest)
    # test_p5 = unittest.TestLoader().loadTestsFromTestCase(testPModelTest)
    # test_p6 = unittest.TestLoader().loadTestsFromTestCase(testPModelTest)
    # test_p7 = unittest.TestLoader().loadTestsFromTestCase(testPModelTest)
    # test_p8 = unittest.TestLoader().loadTestsFromTestCase(testPModelTest)
    # test_p9 = unittest.TestLoader().loadTestsFromTestCase(testPModelTest)
    # test_efp = unittest.TestLoader().loadTestsFromTestCase(testEF_P)
    # test_root_coordinators = unittest.TestLoader().loadTestsFromTestCase(testROOT_CO_ORDINATORS)

    allTests = unittest.TestSuite()
    allTests.addTest(test_p0)
    allTests.addTest(test_p1)
    allTests.addTest(test_p2)
    allTests.addTest(test_p3)
    allTests.addTest(test_p4)
    # allTests.addTest(test_p5)
    # allTests.addTest(test_p6)
    # allTests.addTest(test_p7)
    # allTests.addTest(test_p8)
    # allTests.addTest(test_p9)
    # allTests.addTest(test_efp)
    # allTests.addTest(test_root_coordinators)

    unittest.TextTestRunner(verbosity=2, failfast=True).run(allTests)
    
