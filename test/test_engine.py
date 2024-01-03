import sys
import unittest

import config

from engine.testROOT_CO_ORDINATORS import testROOT_CO_ORDINATORS

def test_engine():
    test_root_coordinators = unittest.TestLoader().loadTestsFromTestCase(testROOT_CO_ORDINATORS)

    allTests = unittest.TestSuite()
    
    allTests.addTest(test_root_coordinators)

    unittest.TextTestRunner(verbosity=2, failfast=True).run(allTests)
    
test_engine()