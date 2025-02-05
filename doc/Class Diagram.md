```mermaid

%% 작성자: 남수만
%% 작성일: 2025-02-04
%% 버전 : v1.0
%%
%% 주석
%%      (v1.0) Original DEVS 기반 클래스 다이어그램 생성 완료[2025.02.04; 남수만]
%%          Ref : https://github.com/sumannam/DEVS-Python/issues/43

classDiagram
direction TB
    class ENTITIES {
	    - string name
	    + setName(name)
	    + getName() string
	    + getEntity() ENTITIES
    }

    class MODELS {
	    - PROCESSORS processor
	    - MODELS parent
	    - list inport_list
	    - list outport_list
	    + setProcessor(processor)
	    + getProcessor() PROCESSORS
	    + addInPort(port_name)
	    + addInPorts(*ports)
	    + addOutPort(port_name)
	    + addOutPorts(*ports)
	    + getInports() list
	    + getOutports() list
	    + getInport(port_name) PORT
	    + getOutport(port_name) PORT
	    + setParent(model)
	    + getParent() MODELS
	    + getPriorityList()
	    + outputFunc()
	    + internalTransitionFunc()
	    + timeAdvancedFunc()
	    + hasExternalOutputCopling(src, port)
	    + translate(coupling_type, model, port)
	    + getModelPortName(model, port) string
    }

    class ATOMIC_MODELS {
	    - SIMULATORS processor
	    - dict state
	    - int ta
	    - int elapsed_time
	    + setName(name)
	    + addState(key, value)
	    + holdIn(phase, sigma)
	    + Continue(e)
	    + passviate()
	    + timeAdvancedFunc() int
	    + modelTest(model)
	    + decideNumberType(time)
	    + sendInject(port_name, value, time)
	    + getInjectResult(type) string
	    + getOutputResult(content) string
	    + getIntTransitionResult() string
	    + externalTransitionFunc(e, x)
	    + internalTransitionFunc()
	    + outputFunc()
    }

    class COUPLED_MODELS {
	    - list child_list
	    - CO_ORDINATORS processor
	    - list priority_list
	    - COUPLING external_output_coupling
	    - COUPLING external_input_coupling
	    - COUPLING internal_coupling
	    + setName(name)
	    + addModel(child)
	    + getModels()
	    + existChildModel(child) bool
	    + getChildModel(child_name)
	    + getChildModelNameList()
	    + addCoupling(src_model, src_port, dst_model, dst_port)
	    + getInternalCoupling()
	    + getPriorityList()
	    + getPrioriryModelNameList()
	    + initialize()
	    + getClockBase()
	    + restart()
	    + hasOutputCoupling(src_model, port)
	    + getDestinationCoupling(src_model, port)
	    + translate(coupling_type, model, port)
    }

    class PROCESSORS {
	    -parent
	    -devs_component
	    -time_last: int
	    -time_next: float
	    -runtime: int
	    +setParent(processor)
	    +getParent()
	    +setDevsComponent(model)
	    +getDevsComponent()
	    +getRunTime() int
	    +initialize()
	    +getTimeOfNextEvent() float
	    +getTimeOfLastEvent() int
	    +setName(name)
	    +getName() string
	    +whenReceiveStar(input_message)*
	    +whenReceiveY(input_message)*
    }

    class ROOT_CO_ORDINATORS {
	    -name: string
	    -clock_base: int
	    -child: PROCESSORS
	    +setName(name)
	    +setChild(processor)
	    +getClockBase() int
	    +initialize()
	    +restart()
	    +whenReceiveDone(input_message)
    }

    class CO_ORDINATORS {
	    -event_type: string
	    -parent: ROOT_CO_ORDINATORS
	    -processor_list: list
	    -processor_time: dict
	    -devs_component
	    -star_child: list
	    -wait_list: list
	    +addChild(processor)
	    +getWaitList() list
	    +initialize()
	    +setTimeOfNextEvent()
	    +whenReceiveStar(input_message)
	    +whenReceiveY(input_message)
	    +whenReceiveX(input_message)
	    +whenReceiveDone(input_message)
	    +removeWaitList(source)
	    +setStarChild()
	    +countSameTimeInChildren(time) int
	    +reconstructMessage(coupling_type, message, coupled_model, destination) MESSAGE
	    +extractPortName(model_port_name) string
	    +convertListToStr(list) string
    }

    class SIMULATORS {
	    -parent: ROOT_CO_ORDINATORS
	    +initialize()
	    +whenReceiveStar(input_message)
	    +whenReceiveX(input_message)
	    +isPairParentCoupling(content) bool
    }

    class MESSAGE_TYPE {
	    STAR
	    EXT
	    Done
	    X
	    Y
    }

    class MESSAGE {
	    -type: MESSAGE_TYPE
	    -source
	    -time: int
	    -content: CONTENT
	    +setRootStar(type, time)
	    +setStar(type, model, time)
	    +setExt(type, model, time)
	    +setDone(type, model, time)
	    +getType() MESSAGE_TYPE
	    +getSource()
	    +getTime() int
	    +getContent() CONTENT
	    +addContent(content)
    }

    class COUPLING {
	    + addCoupling(src_model, src_port, dst_model, dst_port)
	    + get(model_port_name)
	    + find(model_port_name)
    }

    class UNITEST_MODELS {
	    -atomic_model: ATOMIC_MODELS
	    -coupled_model: COUPLED_MODELS
	    +runCoupledModelTest(model, json_file)
	    +runAtomicModelTest(model, json_file)
	    +diffChildModel(target_model, json_child_list)
	    +diffPriorityModel(target_model, json_priority_list)
	    +diffCoupling(target_model, coupling_list)
	    +makeCommand(model_name, atom_content) string
	    +diffStrings(a: str, b: str) string
    }

    class CONTENT {
	    -value: string
	    -port: string
	    +setContent(port, value)
	    +getPort() string
	    +getValue() string
    }

	<<enumeration>> MESSAGE_TYPE

    ENTITIES <|-- MODELS
    MODELS <|-- ATOMIC_MODELS
    MODELS <|-- COUPLED_MODELS
    ENTITIES <|-- PROCESSORS
    PROCESSORS <|-- ROOT_CO_ORDINATORS
    PROCESSORS <|-- CO_ORDINATORS
    PROCESSORS <|-- SIMULATORS
    COUPLING <.. COUPLED_MODELS : manages

	class MESSAGE_TYPE:::Ash
	class MESSAGE:::Ash
	class COUPLING:::Ash
	class UNITEST_MODELS:::Ash
	class CONTENT:::Ash

	classDef Ash :,stroke-width:1px, stroke-dasharray:none, stroke:#999999, fill:#EEEEEE, color:#000000


