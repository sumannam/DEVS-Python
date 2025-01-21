class MqttMsg:
    def __init__(self, topic, payload):
        self.topic = topic
        self.payload = payload