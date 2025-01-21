# import config
import paho.mqtt.client as mqtt
import queue
import threading
import os

from datetime import datetime

# 시뮬레이션
from coupbase.EF_PIPE import EF_PIPE

#
from mqttMsg import MqttMsg

# MQTT
MQTT_CLIENT_ID = "Simulator" # str
MQTT_HOST = "localhost" # str
MQTT_PORT = 1883 # int
MQTT_USERID = None # str | None
MQTT_USERPW = None # str | None

def removeMQTTTimeLogFile():
    if os.path.exists("mqtt_time_log.txt"):
        os.remove("mqtt_time_log.txt")
    else:
        print("The file does not exist")

if __name__ == '__main__':
    # 1. Create a message queue
    msgQueue = queue.Queue()
    removeMQTTTimeLogFile()

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
                # 현재 시간 가져오기
                now = datetime.now()
                # 시간 형식을 '시:분:초.밀리초'로 출력
                formatted_time = now.strftime("%H:%M:%S") + f".{int(now.microsecond / 1000):03d}"

                # 시간 정보를 텍스트 파일에 기록
                with open("mqtt_time_log.txt", "a") as file:
                    file.write(f"{formatted_time} : 'topic': '{msg.topic}', 'payload': '{msg.payload}'\n")

                mqttc.publish(msg.topic, msg.payload)
            
            else: # For Test
                # # 현재 시간 가져오기
                # now = datetime.now()
                # # 시간 형식을 '시:분:초.밀리초'로 출력
                # formatted_time = now.strftime("%H:%M:%S") + f".{int(now.microsecond / 1000):03d}"

                # # 시간 정보를 텍스트 파일에 기록
                # with open("mqtt_time_log.txt", "a") as file:
                #     file.write(f"{formatted_time} : 'topic': '{msg.topic}', 'payload': '{msg.payload}'\n")
                print(f"---mqtt---> 'topic': '{msg.topic}', 'payload': '{msg.payload}'")
        else: # For Test
            print(f"NOT `MqttMsg`: {type(msg)}: '{msg}'")
    #
    if mqttc.is_connected():
        mqttc.disconnect()
    mqttc.loop_stop()
    #
    print("---Done---")

