import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
from email.mime.base import MIMEBase
from email import encoders

# 세션생성, 로그인
s = smtplib.SMTP('smtp.gmail.com', 587)
s.starttls()
s.login('sumannam', 'knmrpoxtssgchpdb')

# 제목, 본문 작성
msg = MIMEMultipart()
msg['Subject'] = 'dwg file'
msg.attach(MIMEText('본문', 'plain'))

# 파일첨부 (파일 미첨부시 생략가능)
# attachment = open('파일명', 'rb')
# part = MIMEBase('application', 'octet-stream')
# part.set_payload((attachment).read())
# encoders.encode_base64(part)
# part.add_header('Content-Disposition', "attachment; filename= " + filename)
# msg.attach(part)

# 메일 전송
s.sendmail("sumannam@gmail.com", "sumannam@naver.com", msg.as_string())
s.quit()

# ref: https://minimin2.tistory.com/44

# ---

# import smtplib
# import email

# from email.mime.image import MIMEImage
# from email.mime.multipart import MIMEMultipart
# from email.mime.text import MIMEText
# from email.mime.application import MIMEApplication

# recipients = ["sumannam@gmail.com"]

# message = MIMEMultipart();
# message['Subject'] = '메일 전송 테스트'
# message['From'] = 'sumannam@naver.com'
# message['To'] = ",".join(recipients)

# content = """
#     <html>
#     <body>
#         <h2>{title}</h2>
#         <p>메일 전송 테스트입니다</p>
#     </body>
#     </html>
# """.format(
# title = '메일.. 받으셨나요..?'
# )

# mimetext = MIMEText(content,'html')
# message.attach(mimetext)

# email_id = 'sumannam'
# email_pw = 'knmrpoxtssgchpdb'

# server = smtplib.SMTP('smtp.gmail.com', 587)
# server.ehlo()
# server.starttls()
# server.login(email_id, email_pw)
# server.sendmail(message['From'], recipients, message.as_string())
# server.quit()