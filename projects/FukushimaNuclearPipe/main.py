import paho.mqtt.client as mqtt
import queue
import threading

import config

from mqttMsg import MqttMsg

# MQTT 설정 파일
MQTT_CLIENT_ID = "Simulator" # str
MQTT_HOST = "localhost" # str
MQTT_PORT = 1883 # int
MQTT_USERID = None # str | None
MQTT_USERPW = None # str | None

# 시뮬레이션
from coupbase.EF_PIPE import EF_PIPE

if __name__ == '__main__':
    # 1. Create a message queue
    msgQueue = queue.Queue()
    
    # 2. Simulation -> wiil be run on sub-thread
    def RunSimulation():
        ef_piping = EF_PIPE(msgQueue)
        ef_piping.initialize() 
        ef_piping.restart()
        # Notify Done Thread
        msgQueue.put(None)

    # 3. Mqtt Ready
    mqttc = mqtt.Client(mqtt.CallbackAPIVersion.VERSION2, client_id=MQTT_CLIENT_ID)
    # if MQTT_USERID is str and MQTT_USERPW is str:
    #     mqttc.username_pw_set(MQTT_USERID, MQTT_USERPW)
    # mqttc._connect_timeout = 1.0 # sec
    try:
        mqttc.connect(host=MQTT_HOST, port=MQTT_PORT)
    except: # Failed to connect
        pass # Ignore

    # 4. Run Simulation
    threading.Thread(target=RunSimulation, daemon=True).start()

    # 5. Mqtt & Message Queue Loop
    mqttc.loop_start()
    #
    while True:
        try:
            msg = msgQueue.get() # Waiting for message (infinite)
        except queue.Empty:
            continue
        # Termination Condition Check
        if msg is None:
            break
        # Mqtt
        if type(msg) is MqttMsg:
            if mqttc.is_connected():
                mqttc.publish(msg.topic, msg.payload)
            else: # For Test
                print(f"---mqtt---> 'topic': '{msg.topic}', 'payload': '{msg.payload}'")
        else: # For Test
            print(f"NOT `MqttMsg`: {type(msg)}: '{msg}'")
    #
    if mqttc.is_connected():
        mqttc.disconnect()
    mqttc.loop_stop()
    #
    print("---Done---")