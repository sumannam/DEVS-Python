import sys
import unittest

import config

from models.testEF_P import testEF_P
from models.testEF import testEF
from models.testP import testP

def test_models():
    test_efp = unittest.TestLoader().loadTestsFromTestCase(testEF_P)
    test_ef = unittest.TestLoader().loadTestsFromTestCase(testEF)
    test_p = unittest.TestLoader().loadTestsFromTestCase(testP)

    allTests = unittest.TestSuite()
    
    allTests.addTest(test_efp)
    allTests.addTest(test_ef)
    allTests.addTest(test_p)

    unittest.TextTestRunner(verbosity=2, failfast=True).run(allTests)
    
test_models()