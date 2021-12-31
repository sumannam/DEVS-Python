import sys
import logging

sys.path.append('D:/Git/DEVS-Python')

from src.MODELS import MODELS
from src.PROCESSORS import PROCESSORS
from src.ROOT_CO_ORDINATORS import ROOT_CO_ORDINATORS

from src.COUPLING import COUPLING_TYPE
from src.MESSAGE import *
from src.CONTENT import CONTENT
from src.PORT import PORT

from src.util import *

class CO_ORDINATORS(PROCESSORS):
    def __init__(self):
        PROCESSORS.__init__(self)

        self.event_type = ""
        
        self.parent=ROOT_CO_ORDINATORS()
        self.parent.setChild(self)
        self.processor_list = []
        self.processor_time = {}

        self.devs_component = None
        self.star_child = []
        self.wait_list = []

    def addChild(self, processor):
        """! 
        @fn         initialize()
        @brief      자식 모델 저장
        @details    자식 모델을 접근하기 위해 리스트 형태로 저장

        @param  processor   프로세스

        @author     남수만(sumannam@gmail.com)
        @date       2021.11.16
        """
        self.processor_list.append(processor)

    def initialize(self):
        """! 
        @fn         initialize()
        @brief      모든 Coordiantor와 Simulator을 접근하여 최소 시간 탐색
        @details    결합 모델일 경우 CO_ORDINATORS.initialize() 호출
                    원자 모델일 경우 SIMULATORS.initialize() 호출
		
		@remarks	whenReceiveStar에서 자식들에게 바로 접근하기 위해 모델 문자에서 인스턴스로 변경 'self.processor_time[processor_name]=time' -> 'self.processor_time[processor]=time' [21.12.04; 남수만]
        @author     남수만(sumannam@gmail.com)
        @date       2021.11.16
        """
        for processor in self.processor_list:
            processor.initialize()
            time = processor.getTimeOfNextEvent()
            # processor_name = processor.getName()
            self.processor_time[processor]=time
        
        self.setTimeOfNextEvent()

    def setTimeOfNextEvent(self):
        """! 
        @fn         setTimeOfNextEvent()
        @brief      self.processor_time에서 가장 작은 시간 설정
        @details    시뮬레이션의 초기 시간 결정을 위해 사용

        @author     남수만(sumannam@gmail.com)
        @date       2021.11.16
        """
        time_min = min(self.processor_time.values())
        self.time_next = time_min
    
    # overriding abstract method
    def whenReceiveStar(self, input_message):
        """! 
        @fn         whenReceiveStar()
        @brief      시뮬레이션 Star-Message
        @details    

        @author     남수만(sumannam@gmail.com)
        @date       2021.11.16

        @remarks    로그 메시지(logInfoCoordinator) 출력[남수만; 2021.12.31]
        """
        msg_time = input_message.getTime()

        if( msg_time == self.time_next ):
            self.tL = msg_time
            output = MESSAGE()
            output.setStar(MESSAGE_TYPE.STAR, self.devs_component, msg_time)

            self.setStarChild()

            for child in self.star_child:
                self.wait_list.append(child)
                
                logInfoCoordinator(self.devs_component.getName()
                                    , self.time_next
                                    , self.time_last
                                    , self.convertListToStr(self.star_child)
                                    , self.convertListToStr(self.wait_list) )

                child.whenReceiveStar(output)

            self.star_child.clear()

    def whenReceiveY(self, input_message):
        """! 
        @fn         whenReceiveY()
        @brief      시뮬레이션 Y Message
        @details    

        @author     남수만(sumannam@gmail.com)
        @date       2021.11.16

        @remarks    
        """
        output = MESSAGE()
        output = self.reconstructMessage( COUPLING_TYPE.EOC, input_message, self.devs_component, self.devs_component)

        if output.getType() != None:
            logInfoCoordinator(self.devs_component.getName()
                              , self.time_next
                              , self.time_last
                              , self.convertListToStr(self.star_child)
                              , self.convertListToStr(self.wait_list) )

            self.parent.whenReceiveY(output)

        self.event_type = MESSAGE_TYPE.Y

        for processor in self.processor_list:
            if processor in self.wait_list:
                continue
            
            output = self.reconstructMessage( COUPLING_TYPE.IC, input_message, self.devs_component, processor.getDevsComponent())

            if output.getType() != None:
                
                self.wait_list.append(processor)

                logInfoCoordinator(self.devs_component.getName()
                                  , self.time_next
                                  , self.time_last
                                  , self.convertListToStr(self.star_child)
                                  , self.convertListToStr(self.wait_list) )

                processor.whenReceiveX(output)
                # self.wait_list.remove(processor)
                if processor in self.star_child:
                    self.star_child.remove(processor)

                    logInfoCoordinator(self.devs_component.getName()
                                      , self.time_next
                                      , self.time_last
                                      , self.convertListToStr(self.star_child)
                                      , self.convertListToStr(self.wait_list) )
            

    def whenReceiveX(self, input_message):
        """! 
        @fn         whenReceiveX()
        @brief      시뮬레이션 X Message
        @details    

        @author     남수만(sumannam@gmail.com)
        @date       2021.11.16

        @remarks    
        """
        self.event_type = MESSAGE_TYPE.X

        if( self.time_last <= input_message.getTime() and input_message.getTime() <= self.time_next):
            self.time_last = input_message.getTime()
            output = MESSAGE()

            ### TODO: broadcast 커플링 처리

            for processor in self.processor_list:
                if processor in self.wait_list:
                    continue

                output = self.reconstructMessage(COUPLING_TYPE.EIC, input_message, self.devs_component, processor.getDevsComponent())

                if output.getType() == None:
                    self.wait_list.append(processor)

                    logInfoCoordinator(self.devs_component.getName()
                                      , self.time_next
                                      , self.time_last
                                      , self.convertListToStr(self.star_child)
                                      , self.convertListToStr(self.wait_list) )

                    processor.whenReceiveX(output)

    def whenReceiveDone(self, input_message):
        """! 
        @fn         whenReceiveDone()
        @brief      시뮬레이션 Done Message
        @details    

        @author     남수만(sumannam@gmail.com)
        @date       2021.11.16

        @remarks    
        """
        source = input_message.getSource()
        self.removeWaitList(source)

        logInfoCoordinator(self.devs_component.getName()
                           , self.time_next
                           , self.time_last
                           , self.convertListToStr(self.star_child)
                           , self.convertListToStr(self.wait_list) )

        processor = source.getProcessor()
        self.processor_time[processor]=input_message.getTime()

        if self.wait_list.__len__ == 0:
            self.time_next = min(self.processor_time.values())
            output = MESSAGE()
            output.setDone(MESSAGE_TYPE.Done, self.devs_component, self.time_next)
            self.parent.whenReceiveDone(output)

            logInfoCoordinator(self.devs_component.getName()
                               , self.time_next
                               , self.time_last
                               , self.convertListToStr(self.star_child)
                               , self.convertListToStr(self.wait_list) )

            # DEVS-ObjC에서 아래 소스는 왜 있는지 모르겠음[남수만; 2021.12.31]
            # self.tN_children.clear()


    def removeWaitList(self, source):
        src_name = source.getName()

        for model in self.wait_list:
            model_name = model.getName()

            if model_name == src_name:
                self.wait_list.remove(model)
    

    #### self.devs_component.getPriorityList() 개발 중
    def setStarChild(self):
        self.star_child.clear()
        priority_list = self.devs_component.priority_list
        count = self.countSameTimeInChildren(self.time_next)    

        if len(priority_list) == 0 or count == 1:
            for model in self.processor_time.keys():
                if self.processor_time[model] == self.time_next:
                    self.star_child.append(model)
        ## TODO: 다중 조건문 추가 필요
        
        
    
    def countSameTimeInChildren(self, time):
        count = 0
        for value in self.processor_time.values():
            if value == time:
                count=count+1

        return count

    def reconstructMessage(self, coupling_type, message, coupled_model, destination):
        content = CONTENT()
        outport = PORT()

        source = message.getSource()
        time = message.getTime()
        content = message.getContent()
        outport = content.getPort()
        value = content.getValue()

        print(source)
        print(time)
        print(value)

        model_port_list = []
        
        if coupling_type == COUPLING_TYPE.EOC:
            model_port_list = self.devs_component.translate( COUPLING_TYPE.EOC, source, outport)
        if coupling_type == COUPLING_TYPE.IC:
            model_port_list = self.devs_component.translate( COUPLING_TYPE.IC, source, outport)
        if coupling_type == COUPLING_TYPE.EIC:
            model_port_list = self.devs_component.translate( COUPLING_TYPE.EIC, coupled_model, outport)

        emtyp_message = MESSAGE()
        is_same_model = False
        dst_name = destination.getName()

        if model_port_list == None:
            return emtyp_message
        
        for model_port in model_port_list:
            if dst_name in model_port:
                is_same_model = True
                break
        
        if is_same_model == True:
            new_message = MESSAGE()
            new_message.setExt(MESSAGE_TYPE.EXT, self.devs_component, time)

            port_name = self.extractPortName(model_port_list[0])
            content.setContent(port_name, value)
            new_message.addContent(content)

            return new_message

        else:
            return emtyp_message

    
    def extractPortName(self, model_port_name):
        lst = model_port_name.split(".")
        return lst[1]

    
    def convertListToStr(self, list):
        """! 
        @fn         convertModelListToStr()
        @brief      시뮬레이션 로그 메시지 출력
        @detail     리스트는 모델 리스트를 가지고 있어 모델 이름만 추출 필요

        @author     남수만(sumannam@gmail.com)
        @date       2021.12.31
        """
        str = ""
        for element in list:
            name = element.getName()
            str += name
        
        return str



        
        
