import sys
import math
from src.MESSAGE import MESSAGE

sys.path.append('D:/Git/DEVS-Python')

from src.PROCESSORS import PROCESSORS
from src.ROOT_CO_ORDINATORS import ROOT_CO_ORDINATORS
from src.CONTENT import CONTENT

class SIMULATORS(PROCESSORS):
    def __init__(self):
        PROCESSORS.__init__(self)

        self.parent = ROOT_CO_ORDINATORS()
        self.parent.setChild(self)

    def initialize(self):
        """! 
        @fn         initialize
        @brief      원자 모델의 sigma 시간 얻기
        @details    시간 진행 함수를 통해 원자 모델 sigma 값 접근

        @author     남수만(sumannam@gmail.com)
        @date       2021.11.16
        """
        super().initialize()
        self.tN=self.devs_component.timeAdvancedFunc()

    # overriding abstract method
    def whenReceiveStar(self, input_message):
        input_time = input_message.getTime()
        if( input_time == self.tN ):
            devs_output = CONTENT()
            devs_output = self.devs_component.outputFunc()

            if( devs_output.getPort() != None ):
                new_message = MESSAGE
                print(input_time)

                ## 오류 발생[2021.12.08]
                new_message.setStar(MESSAGE.EXT, self.devs_component, input_time)
                new_message.addContent(devs_output)

                print(new_message)
#                 			if ( isPairParentCoupling( devs_output ) )
# 			{
# #ifdef EXPORT_LOG
# 				SIM_MSG_LOG_NAME( "Before whenReceiveY" );
# 				SIMULATOR_MSG_LOG( devs_component, tN, tL );
# #endif

# 				parent->whenReceiveY( new_mesasge );
# 			}
