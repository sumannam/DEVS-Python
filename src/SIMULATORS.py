from src.MODELS import MODELS
from src.PROCESSORS import PROCESSORS
from src.ROOT_CO_ORDINATORS import ROOT_CO_ORDINATORS

from src.MESSAGE import *
from src.CONTENT import CONTENT

from src.util import *

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
        self.time_next=self.devs_component.timeAdvancedFunc()

    # overriding abstract method
    def whenReceiveStar(self, input_message):
        """! 
        @fn         whenReceiveStar()
        @brief      시뮬레이션 Star-Message
        @details    

        @author     남수만(sumannam@gmail.com)
        @date       2021.11.16

        @remarks    로그 메시지(logInfoSimulator) 출력[남수만; 2021.12.31]
        """
        input_time = input_message.getTime()

        if( input_time == self.time_next ):
            devs_output = CONTENT()
            devs_output = self.devs_component.outputFunc()

            # devs_comp_name = self.devs_component.getName()
            # if devs_comp_name == "P":
            #     print(devs_comp_name)

            if( devs_output.getPort() != None ):
                new_message = MESSAGE()
                new_message.setExt(MESSAGE_TYPE.EXT, self.devs_component, input_time)
                new_message.addContent(devs_output)

                if(self.isPairParentCoupling(devs_output)==True):
                    logging.info("")
                    logInfoSimulator(self.devs_component.getName()
                                    , self.time_next
                                    , self.time_last)
                    self.parent.whenReceiveY(new_message)
            
            logging.info("")
            logInfoSimulator(self.devs_component.getName()
                            , self.time_next
                            , self.time_last)

            self.devs_component.internalTransitionFunc()
            self.time_last = input_message.getTime()
            self.time_next = self.time_last + self.devs_component.timeAdvancedFunc()
            
            logging.info("")
            logInfoSimulator(self.devs_component.getName()
                            , self.time_next
                            , self.time_last)

            # devs_comp_name = self.devs_component.getName()
            # if devs_comp_name == "GENR":
            #     print(devs_comp_name)

            source = MODELS()
            source = self.devs_component
            time = self.time_next
            output_message = MESSAGE()
            output_message.setDone(MESSAGE_TYPE.Done, source, time)

            self.parent.whenReceiveDone(output_message)

            logging.info("")
            logInfoSimulator(self.devs_component.getName(), self.time_next, self.time_last)

    
    def whenReceiveX(self, input_message):
        """! 
        @fn         whenReceiveX()
        @brief      시뮬레이션 X-Message
        @details    

        @author     남수만(sumannam@gmail.com)
        @date       2021.11.16

        @remarks    로그 메시지(logInfoSimulator) 출력[남수만; 2021.12.31]
        """
        if( self.time_last <= input_message.getTime() and input_message.getTime() <= self.time_next):
            elapsed_time = input_message.getTime() - self.time_last
            self.time_last = input_message.getTime()

            logging.info("")
            logInfoSimulator(self.devs_component.getName()
                            , self.time_next
                            , self.time_last)

            content = CONTENT()
            content = input_message.getContent()
            self.devs_component.externalTransitionFunc(elapsed_time, content)

            self.time_next = self.time_last + self.devs_component.timeAdvancedFunc()

            logging.info("")
            logInfoSimulator(self.devs_component.getName()
                            , self.time_next
                            , self.time_last)

            source = self.devs_component
            time = self.time_next
            output = MESSAGE()
            output.setDone(MESSAGE_TYPE.Done, source, time)

            self.parent.whenReceiveDone(output)

            logging.info("")
            logInfoSimulator(self.devs_component.getName()
                            , self.time_next
                            , self.time_last)
    
    
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

        # print(self.devs_component, content.getPort())

        bool_rslt = parent_model.hasOutputCoupling(self.devs_component, content.getPort())

        if(bool_rslt == True):
            return True
        else:
            return False


    
