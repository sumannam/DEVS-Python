# 실행 방법 : python -m pytest pytest_EF_P.py

import sys
import os
import pytest

sys.path.append(os.path.dirname(os.path.abspath(os.path.dirname(__file__))))
import config

from projects.simparc.coupbase.EF_P import EF_P

class TestEF_P:
   """! 
   @class      TestEF_P
   @brief      EF_P 결합 모델 테스트 클래스
   @details    모델 추가와 내부 커플링 테스트를 수행
   """
   
   @pytest.fixture(autouse=True)
   def setup(self):
       """각 테스트 실행 전에 EF_P 인스턴스 생성"""
       self.ef_p = EF_P()
   
   def test_add_models(self):
       """모델 추가 테스트"""
       class_list = self.ef_p.getModels()
       model_list = [model.__class__.__name__ for model in class_list]

       assert model_list == ['EF', 'P']

   def test_add_internal_coupling(self):
       """내부 커플링 테스트"""
       coupling_list = self.ef_p.internal_coupling
       assert coupling_list.coupling_dic == {
           'EF.out': ['P.in'], 
           'P.out': ['EF.in']
       }