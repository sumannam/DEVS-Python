Tracers
=======

PythonPDEVS provides several features that allow you to trace the execution of your model.
Here, we present four built-in tracers, and present the interface used to create your own tracer.
For all tracers, providing the *None* object as the filename causes the trace to be printed to stdout, instead of writing it to a file.

In the context of distributed simulation, tracing is a *destructive event*, meaning that it can only occur after the GVT.
As such, tracing happens in blocks as soon as fossil collection occurs.

Verbose
-------

The first tracer is the verbose tracer, which generates a purely textual trace of your model execution.
It has already been presented before, and was used by invoking the following configuration option::

    sim.setVerbose(None)

Note that this is the only built-in tracer that works without additional configuration of the model.
An example snippet is shown below::

    __  Current Time:       0.00 __________________________________________


            INITIAL CONDITIONS in model <trafficSystem.trafficLight>
                    Initial State: red
                    Next scheduled internal transition at time 58.50


            INITIAL CONDITIONS in model <trafficSystem.policeman>
                    Initial State: idle
                    Next scheduled internal transition at time 200.00


    __  Current Time:      58.50 __________________________________________


            INTERNAL TRANSITION in model <trafficSystem.trafficLight>
                    New State: green
                    Output Port Configuration:
                            port <OBSERVED>:
                                    grey
                    Next scheduled internal transition at time 108.50


    __  Current Time:     108.50 __________________________________________


            INTERNAL TRANSITION in model <trafficSystem.trafficLight>
                    New State: yellow
                    Output Port Configuration:
                            port <OBSERVED>:
                                    yellow
                    Next scheduled internal transition at time 118.50

    ...

    __  Current Time:     200.00 __________________________________________ 


        EXTERNAL TRANSITION in model <trafficSystem.trafficLight>
                Input Port Configuration:
                        port <INTERRUPT>:
                                toManual
                New State: manual
                Next scheduled internal transition at time inf


        INTERNAL TRANSITION in model <trafficSystem.policeman>
                New State: working
                Output Port Configuration:
                        port <OUT>:
                                toManual
                Next scheduled internal transition at time 300.00

XML
---

The second tracer is the XML tracer, which generates an XML-structured trace of your model execution, compliant to the notation presented in `Bill Song's thesis <http://msdl.cs.mcgill.ca/people/bill/thesis/latexthesis.pdf>`_.
It can also simply be enabled by setting the following configuration option::

    sim.setXML(None)

To enable this XML tracing, the model has to be augmented with facilities to dump the current state in the form of an XML notation.
This is done with the *toXML()* method, which has to be defined for all complex states, and must return a string to be embedded in the XML.
This string is pasted as-is in the trace file, and should therefore not contain forbidden characters (e.g., <).
For example, a *toXML* method for the traffic light can look as follows::

    class TrafficLightMode:
        ...

        def toXML(self):
            return "<mode>%s</mode>" % self.__colour

An example snippet is shown below::

    <trace>
        <event>
            <model>trafficSystem.trafficLight</model>
            <time>0.0</time>
            <kind>EX</kind>
            <state>
                <mode>red</mode><![CDATA[red]]>
            </state>
        </event>
        <event>
            <model>trafficSystem.policeman</model>
            <time>0.0</time>
            <kind>EX</kind>
            <state>
                <mode>idle</mode><![CDATA[idle]]>
            </state>
        </event>
        <event>
            <model>trafficSystem.trafficLight</model>
            <time>58.5</time>
            <kind>IN</kind>
            <port name="OBSERVED" category="O">
                <message>grey</message>
            </port>
            <state>
                <mode>green</mode><![CDATA[green]]>
            </state>
        </event>
        ...
        <event>
            <model>trafficSystem.policeman</model>
            <time>200.0</time>
            <kind>IN</kind>
            <port name="OUT" category="O">
                <message>toManual</message>
            </port>
            <state>
                <mode>working</mode><![CDATA[working]]>
            </state>
        </event>
        <event>
            <model>trafficSystem.trafficLight</model>
            <time>200.0</time>
            <kind>EX</kind>
            <port name="INTERRUPT" category="I">
                <message>toManual</message>
            </port>
            <state>
                <mode>manual</mode><![CDATA[manual]]>
            </state>
        </event>
    </trace>


VCD
---

TODO

Cell
----

The cell tracer is discussed separately, as it has very specific behaviour and is only applicable to a select number of models.

Custom
------

Additionally, it might necessary to define your own custom tracer.
This can be done by defining a class similar to the following template.
For each trace method, an *aDEVS* parameter is passed, being a reference to the atomic DEVS model doing the transition.
On this *aDEVS* object, the following functions and attributes can be accessed:

    - *aDEVS.getModelFullName()*: full hierarchical name of the model
    - *aDEVS.IPorts*: reference to all input ports
    - *aDEVS.OPorts*: reference to all output ports
    - *aDEVS.state*: state of model
    - *aDEVS.time_last[0]*: Time of next transition
    - *aDEVS.time_next[0]*: Time of next transition
    - *aDEVS.my_output*: dictionary of output events
    - *aDEVS.my_input*: dictionary of input events
    - *aDEVS.elapsed*: elapsed time before transition

A custom tracer can be defined as follows::

    class TracerCustom(object):
        def __init__(self, uid, server, filename):
            """
            Both uid and server can be ignored, as these are only required for distributed simulation
            filename contains the name of the file in which we should write the trace
            """
            pass

        def startTracer(self, recover):
            """
            Recover is a boolean representing whether or not this is a recovered call (e.g., should the file be overwritten or appended to?)
            """
            pass

        def stopTracer(self):
            """
            Stops the tracer (e.g., flush the file)
            """
            pass

        def traceInternal(self, aDEVS):
            """
            Called for each atomic DEVS model that does an internal transition.
            """
            pass

        def traceExternal(self, aDEVS):
            """
            Called for each atomic DEVS model that does an external transition.
            """
            pass

        def traceConfluent(self, aDEVS):
            """
            Called for each atomic DEVS model that does a confluent transition.
            """
            pass

        def traceInit(self, aDEVS, t):
            """
            Called upon initialization of a model.
            The parameter *t* contains the time at which the model commences (likely 0).
            """
            pass

        def traceUser(self, time, aDEVS, variable, value):
            """
            Called upon so called *god events* during debuggin, where a user manually alters the state of an atomic DEVS instance.
            """
            pass

For some "example" tracers, have a look at the built-in tracers of PythonPDEVS, which can be found in *src/tracers*.

Note that in optimistic synchronization the destructive parts of this operation should be separated.
This can be done using the *runTraceAtController* function::

    runTraceAtController(server, uid, aDEVS, [time, trace_text])

Both the *server* and *uid* are those passed to the constructor of the tracer.

Finally, after the tracer is defined, it needs to be registered for the simulator to use it.
This is done using the following call on the instantiated simulator::

    sim.setCustomTracer(self, tracerfile, tracerclass, args):

Where:

    - *tracerfile*: the Python class containing the implementation of the tracer, which is dynamically imported.
    - *tracerclass*: the name of the class implementing the tracing functionality.
    - *args*: the list of arguments  that must additionally be passed to the tracer (e.g., filename)
