# 실행 방법 : python -m pytest pytest_EF_P.py

import sys
import os
import pytest

sys.path.append(os.path.dirname(os.path.abspath(os.path.dirname(__file__))))
import config

from projects.simparc.coupbase.EF_P import EF_P
ef_p = EF_P()

@pytest.fixture
def ef_p():
    return EF_P()

def test_add_models(ef_p):
    class_list = ef_p.getModels()
    model_list = [model.__class__.__name__ for model in class_list]

    assert model_list == ['EF', 'P']

def test_add_internal_coupling(ef_p):
    coupling_list = ef_p.internal_coupling
    assert coupling_list.coupling_dic == {'EF.out': ['P.in'], 'P.out': ['EF.in']}
