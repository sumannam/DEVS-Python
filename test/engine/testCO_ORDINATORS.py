import os
import sys
import unittest
import logging
from pathlib import Path

# Add the project root directory to the Python path
project_root = str(Path(__file__).parent.parent.parent)
sys.path.append(project_root)

from src.log import logInfoCoordinator, logInfoSimulator, logDebugCoordinator, logDebugSimulator, setLogLevel
from src.CO_ORDINATORS import CO_ORDINATORS
from src.SIMULATORS import SIMULATORS

# Import models from test_models folder
from mbase.EF import testEF
from mbase.PS import testPS
from mbase.GENR import testGENR
from mbase.TRANSD import testTRANSD
from mbase.BP import testBP

class TestCoordinators(unittest.TestCase):
    def setUp(self):
        # Set log level to DEBUG for detailed logging
        setLogLevel(logging.DEBUG)
        
        # Create components
        self.genr = testGENR()
        self.transd = testTRANSD()
        self.ef = testEF()
        self.ps = testPS()
        self.bp1 = testBP("BP1")
        self.bp2 = testBP("BP2")
        self.bp3 = testBP("BP3")
        
        # Create coordinators
        self.ef_p = CO_ORDINATORS()
        self.ef_p.setName("EF_P")
        self.ef_p.addChild(self.ef)
        self.ef_p.addChild(self.ps)
        
        self.ef.addChild(self.genr)
        self.ef.addChild(self.transd)
        
        self.ps.addChild(self.bp1)
        self.ps.addChild(self.bp2)
        self.ps.addChild(self.bp3)
        
        # Create simulator
        self.sim = SIMULATORS()
        self.sim.setRoot(self.ef_p)

    def test_coordinator_initialization(self):
        self.assertEqual(self.ef_p.getName(), "EF_P")
        self.assertEqual(len(self.ef_p.getChildList()), 2)
        self.assertEqual(len(self.ef.getChildList()), 2)
        self.assertEqual(len(self.ps.getChildList()), 3)

    def test_coordinator_simulation(self):
        # Run simulation
        self.sim.simulate(20)
        
        # Verify results
        self.assertEqual(self.transd.getTotal(), 3)  # Should receive 3 messages
        self.assertEqual(self.bp1.getTotal(), 1)     # Each BP should receive 1 message
        self.assertEqual(self.bp2.getTotal(), 1)
        self.assertEqual(self.bp3.getTotal(), 1)

if __name__ == '__main__':
    unittest.main()