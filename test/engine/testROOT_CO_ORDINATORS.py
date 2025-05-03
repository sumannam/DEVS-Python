import os
import sys
import unittest
import logging
from pathlib import Path

# Add the project root directory to the Python path
project_root = str(Path(__file__).parent.parent.parent)
sys.path.append(project_root)

from src.log import logInfoCoordinator, logInfoSimulator, logDebugCoordinator, logDebugSimulator, setLogLevel
from src.ROOT_CO_ORDINATORS import RootCoordinator
from src.SIMULATORS import SIMULATORS
from src.CO_ORDINATORS import CO_ORDINATORS

# Import models from test_models folder
from test_models.EF import EF
from test_models.PS import PS
from test_models.GENR import GENR
from test_models.TRANSD import TRANSD
from test_models.BP import BP

class TestRootCoordinators(unittest.TestCase):
    def setUp(self):
        # Set log level to DEBUG for detailed logging
        setLogLevel(logging.DEBUG)
        
        # Create components
        self.genr = GENR("GENR")
        self.transd = TRANSD("TRANSD")
        self.ef = EF("EF")
        self.ps = PS("PS")
        self.bp1 = BP("BP1")
        self.bp2 = BP("BP2")
        self.bp3 = BP("BP3")
        
        # Create coordinators
        self.root = RootCoordinator("ROOT")
        self.ef_p = CO_ORDINATORS()
        self.ef_p.setName("EF_P")
        self.ef_p.addChild(self.ef)
        self.ef_p.addChild(self.ps)
        
        self.ef.addChild(self.genr)
        self.ef.addChild(self.transd)
        
        self.ps.addChild(self.bp1)
        self.ps.addChild(self.bp2)
        self.ps.addChild(self.bp3)
        
        # Add EF_P to root
        self.root.addChild(self.ef_p)
        
        # Create simulator
        self.sim = SIMULATORS()
        self.sim.setRoot(self.root)

    def test_root_coordinator_initialization(self):
        self.assertEqual(self.root.getName(), "ROOT")
        self.assertEqual(len(self.root.getChildList()), 1)
        self.assertEqual(self.root.getChildList()[0].getName(), "EF_P")

    def test_root_coordinator_simulation(self):
        # Run simulation
        self.sim.simulate(20)
        
        # Verify results
        self.assertEqual(self.transd.getTotal(), 3)  # Should receive 3 messages
        self.assertEqual(self.bp1.getTotal(), 1)     # Each BP should receive 1 message
        self.assertEqual(self.bp2.getTotal(), 1)
        self.assertEqual(self.bp3.getTotal(), 1)

if __name__ == '__main__':
    unittest.main()