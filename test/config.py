import os
import sys

if 'win' in sys.platform:  # Windows
    sys.path.append('D:\\Git\DEVS-Python')
    sys.path.append('D:\\Git\DEVS-Python\\test')
    sys.path.append('D:\\Git\DEVS-Python\\projects\\coupledmodelTest')    
else:  # Linux, Unix, MacOS
    sys.path.append('.')