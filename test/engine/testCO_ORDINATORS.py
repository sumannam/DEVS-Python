import os
import sys
import unittest

import src.util as util

sys.path.append(os.path.dirname(os.path.abspath(os.path.dirname(__file__))))
import config

from src.MESSAGE import MESSAGE
from src.CONTENT import CONTENT
from src.CO_ORDINATORS import CO_ORDINATORS

from projects.simparc.coupbase.EF import EF
from projects.simparc.mbase.GENR import GENR

class testCO_ORDINATORS(unittest.TestCase):
    """
    ΄λ¤λ” ROOT_CO_ORDINATORS ΄λ¤λ μ¤Έν•©λ‹¤.
    """

    def setUp(self):
        """
        μ¤κ²½¤μ •©λ‹
        """
        self.ef = EF()
        self.ef.initialize()

    def testInitialize(self):
        """
        λª¨λΈ μ΄κΈ°”λ μ¤Έν•©λ‹¤.

        ¨μλª¨λΈ μ΄κΈ°”μ μµμ† κ°„μ¤Έν•©λ‹¤.
        EF-Pμµμ† Sigma κ°„κ²€¬ν•©λ‹¤.

        :‘μ„± ¨μλ§sumannam@gmail.com)
        :‘μ„± 2024.01.04

        :TDD: 
        :Έμ…: https://www.notion.so/modsim-devs/TDD-c80a15fcb34c40319b7a4e3d9b0211a7?pvs=4
        """
        time_list = list(self.ef.processor.processor_time.values())
        
        assert time_list == [0, 10]
        
    def testWhenReceiveStar(self):
        """
        λª¨λΈwhenReceiveStar ¨μλ¥μ¤Έν•©λ‹¤.

        ¨μμ΄κΈ°λª¨λΈwhenReceiveStar ¨μλ¥μ¤Έν•©λ‹¤.
        'Star' λ©”μ‹μ§€λ¥μ‹ „μ ¤μ κ°„΄λ΅ λ² μ΄¤μ κ°™μμ§€ κ²€¬ν•©λ‹¤.

        :‘μ„± ¨μλ§sumannam@gmail.com)
        :‘μ„± 2024.01.04
        """
        
        star_msg = MESSAGE()
        star_msg.setRootStar('Star', 0)
        self.ef.processor.whenReceiveStar(star_msg)
        
        time_next = self.ef.processor.getTimeOfNextEvent()
        
        assert time_next == 3
        
    def testWhenReceiveY(self):
        """
        λª¨λΈwhenReceiveY ¨μλ¥μ¤Έν•©λ‹¤.

        ¨μμ΄κΈ°λª¨λΈwhenReceiveY ¨μλ¥μ¤Έν•©λ‹¤.
        'Y' λ©”μ‹μ§€λ¥μ‹ „μ ¤μ κ°„΄λ΅ λ² μ΄¤μ κ°™μμ§€ κ²€¬ν•©λ‹¤.

        :‘μ„± ¨μλ§
        :‘μ„± 2024.01.04
        """
        util.UNITEST_METHOD = 'testWhenReceiveY'
        
        self.genr = GENR()       
        input_message = MESSAGE()
        input_message.setExt('Y', self.genr, 0)

        input_content = CONTENT()
        input_content.setContent("out", "TEST-1")
        input_message.addContent(input_content)        
        
        current_path = os.path.dirname(os.path.abspath(os.path.dirname(__file__)))
        parent_path = os.path.abspath(os.path.join(current_path, os.pardir))

        log_file = parent_path + "\\" + "sim_msg_log.txt"
                                       
        # μΌμ΅΄μ¬λ” κ²½μ°  
        if os.path.isfile(log_file):
            os.remove(log_file)
        else:
            print("Error: {} μΌμ΅΄μ¬μ μµλ‹¤.".format(log_file))

        self.ef.processor.whenReceiveY(input_message)
        
        
        
    def testWhenReceiveX(self):
        self.genr = GENR()

        input_message = MESSAGE()
        input_message.setExt('X', self.genr, 0)
        