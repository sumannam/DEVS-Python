import sys
import math

sys.path.append('D:/Git/DEVS-Python')

from src.MESSAGE import MESSAGE
from src.MODELS import MODELS

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
                new_message = MESSAGE()
                new_message.setExt(MESSAGE.EXT, self.devs_component, input_time)
                new_message.addContent(devs_output)

                if(self.isPairParentCoupling(devs_output)==True):
                    self.parent.whenReceiveStar(new_message)
            
            self.devs_component.internalTransitionFunc()
            self.tL = input_message.getTime()
            self.tN = self.tL + self.devs_component.timeAdvancedFunc()

            source = MODELS()
            source = self.devs_component
            time = self.tN
            output_message = MESSAGE()
            output_message.setDone(MESSAGE.Done, source, time)




#                 			if ( isPairParentCoupling( devs_output ) )
# 			{
# #ifdef EXPORT_LOG
# 				SIM_MSG_LOG_NAME( "Before whenReceiveY" );
# 				SIMULATOR_MSG_LOG( devs_component, tN, tL );
# #endif

# 				parent->whenReceiveY( new_mesasge );
# 			}

    def isPairParentCoupling(self, content):
        """! 
        @fn         isPairParentCoupling()
        @brief      메시지의 Content으로부터 부모 모델에서 일치된 커플링이 있는지 검사
        @details    

        @param      content port, value로 구성

        @return     커플링 정보가 있으면 True, 없으면 False

        @author     남수만(sumannam@gmail.com)
        @date       2021.12.13
        """
        parent_model = MODELS()
        parent_model = self.parent.devs_component

        print(self.devs_component, content.getPort())

        bool_rslt = parent_model.hasExternalOutputCopling(self.devs_component, content.getPort())

        if(bool_rslt == True):
            return True
        else:
            return False

