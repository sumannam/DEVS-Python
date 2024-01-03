import sys
import os
import unittest

sys.path.append(os.path.dirname(os.path.abspath(os.path.dirname(__file__))))
import config

from projects.simparc.mbase.P import P

class testP(unittest.TestCase):
    def setUp(self):
        self.p = P()
    
    def testExternalTransitionFunc(self):
        """! 
        @fn         test_modeltest_p_inject
        @brief      P 모델 External Transition Function 수행
        @details    >>> send p inject in g1 10

        @author     남수만(sumannam@gmail.com)
        @date       2021.10.21
        """
        self.p.sendInject("in", "g1", 10)
        send_result = self.p.getInjectResult("delta_ext")

        assert send_result == "state s = ( 10 busy g1 10 )"
    
    def testInternalTransitionFunc(self):
        """! 
        @fn         test_modeltest_p_output
        @brief      P 모델 Internal Transition Function 수행
        @details    >>> send p inject in g1 5
                    >>> send p output?
                    >>> send p int-transition

        @author     남수만(sumannam@gmail.com)
        @date       2021.10.21
        """
        self.p.sendInject("in", "g1", 10)
        self.p.outputFunc()

        self.p.internalTransitionFunc()
        send_result = self.p.getIntTransitionResult()

        assert send_result == "state s = ( inf passive g1 10 )"
    
    def testOutputFunc(self):
        """! 
        @fn         test_modeltest_p_output
        @brief      P 모델 Output Function 수행
        @details    >>> send p inject in g1 5
                    >>> send p output?

        @author     남수만(sumannam@gmail.com)
        @date       2021.10.21
        """
        self.p.sendInject("in", "g1", 10)

        # output = CONTENT()
        output = self.p.outputFunc()
        send_result = self.p.getOutputResult(output)

        assert send_result == "y = " + output.port + " " + output.value
        

