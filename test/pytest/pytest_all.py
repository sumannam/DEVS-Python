import os
import sys
import pytest

# 테스트 실행
pytest_result = pytest.main(["--rootdir=d:/Git/DEVS-Python"
                             , "d:/Git/DEVS-Python/test/pytest/pytest_EF_P.py"])


if pytest_result == 0:
    print("테스트가 모두 성공했습니다!")
else:
    print("테스트에 실패했습니다!")
