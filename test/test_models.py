import sys
import unittest

import config

from models.testEF_P import testEF_P

def test_models():
    test_efp = unittest.TestLoader().loadTestsFromTestCase(testEF_P)

    allTests = unittest.TestSuite()
    
    allTests.addTest(test_efp)

    unittest.TextTestRunner(verbosity=2, failfast=True).run(allTests)
    
test_models()