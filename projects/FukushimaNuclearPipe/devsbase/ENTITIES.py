# from devsbase.util import setDevPath
# setDevPath()

class ENTITIES:
    def __init__(self):
        self.name = ""
    
    def setName(self, name):
        """! 
        @fn         setName()
        @brief      엔티티 이름 설정
        @details    모델의 엔티티 이름 설정

        @author     남수만(sumannam@gmail.com)
        @date       2021.11.16
        """
        self.name = name

    def getName(self):
        """! 
        @fn         getName()
        @brief      엔티티 이름 전달
        @details    모델의 엔티티 이름 설정

        @return     엔티티 이름 반환

        @author     남수만(sumannam@gmail.com)
        @date       2021.11.16
        """
        return self.name

    def getEntity(self):
        return self
