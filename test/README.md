# DEVS-Python Test Directory / DEVS-Python 테스트 디렉토리

This directory contains test files and test models for the DEVS-Python project.
이 디렉토리는 DEVS-Python 프로젝트의 테스트 파일들과 테스트 모델들을 포함하고 있습니다.

## Directory Structure / 디렉토리 구조

```
test/
├── __init__.py
├── config.py
├── mbase/           # Test-specific model implementations / 테스트용 모델 구현
│   ├── EF_P.py
│   ├── EF.py
│   ├── PS.py
│   ├── GENR.py
│   ├── TRANSD.py
│   └── BP.py
├── model_test/      # Tests for project models / 프로젝트 모델 테스트
│   └── ...
├── engine/          # Engine-related tests / 엔진 관련 테스트
│   ├── testBROADCAST_MODELS.py
│   └── ...
├── unitest_all.py   # Main test runner / 메인 테스트 실행기
├── unitest_engine.py # Engine test suite / 엔진 테스트 모음
└── unitest_models.py # Model test suite / 모델 테스트 모음
```

## Directory Descriptions / 디렉토리 설명

### `/test/mbase` (Model Base) / (모델 베이스)
- **Purpose / 목적**: Contains base model classes specifically implemented for testing
  - 테스트를 위해 특별히 구현된 기본 모델 클래스들을 포함
- **Characteristics / 특징**:
  - Independent model implementations for testing
    - 테스트를 위한 독립적인 모델 구현
  - Models are implemented separately from project models
    - 프로젝트 모델과 독립적으로 구현
  - Used directly in test cases
    - 테스트 케이스에서 직접 사용
- **Example Models / 예시 모델**:
  - `EF_P.py`, `EF.py`, `PS.py`, `GENR.py`, `TRANSD.py`, `BP.py`
- **Usage Example / 사용 예시**:
  ```python
  from mbase.EF import EF
  from mbase.PS import PS
  ```

### `/test/model_test` (Model Test) / (모델 테스트)
- **Purpose / 목적**: Contains test code for actual project models
  - 실제 프로젝트 모델들을 위한 테스트 코드를 포함
- **Characteristics / 특징**:
  - Tests for models in the `projects/` directory
    - `projects/` 디렉토리의 모델들을 테스트
  - Test cases that validate project model behavior
    - 프로젝트 모델의 동작을 검증하는 테스트 케이스
  - Functional tests for implemented models
    - 구현된 모델의 기능 테스트
- **Example Tests / 예시 테스트**:
  - Project-specific model test code
    - 프로젝트별 모델 테스트 코드
  - Model behavior validation tests
    - 모델 동작 검증 테스트
- **Usage Example / 사용 예시**:
  ```python
  from projects.simps_broadcastmodel.coupbase.EF import EF
  from projects.simps_broadcastmodel.coupbase.PS import PS
  ```

### `/test/engine` / (엔진)
- Contains tests for the DEVS engine components
  - DEVS 엔진 컴포넌트에 대한 테스트를 포함
- Tests for coordinators, simulators, and other engine-related functionality
  - 코디네이터, 시뮬레이터 및 기타 엔진 관련 기능에 대한 테스트

## Test Suite Files / 테스트 모음 파일들

### `unitest_all.py` / (통합 테스트 실행기)
- **Purpose / 목적**: Main test runner that executes all test suites
  - 모든 테스트 모음을 실행하는 메인 테스트 실행기
- **Functionality / 기능**:
  - Runs both engine and model tests
    - 엔진 테스트와 모델 테스트를 모두 실행
  - Provides build success/failure status
    - 빌드 성공/실패 상태를 제공
  - Uses subprocess to run tests independently
    - 서브프로세스를 사용하여 테스트를 독립적으로 실행

### `unitest_engine.py` / (엔진 테스트 모음)
- **Purpose / 목적**: Test suite for DEVS engine components
  - DEVS 엔진 컴포넌트에 대한 테스트 모음
- **Components / 구성요소**:
  - Tests for ROOT_CO_ORDINATORS
    - ROOT_CO_ORDINATORS 테스트
  - Tests for CO_ORDINATORS
    - CO_ORDINATORS 테스트
  - Tests for SIMULATORS
    - SIMULATORS 테스트
- **Features / 특징**:
  - Automatic log file cleanup
    - 자동 로그 파일 정리
  - Verbose test output
    - 상세한 테스트 출력
  - Fail-fast test execution
    - 실패 시 즉시 중단되는 테스트 실행

### `unitest_models.py` / (모델 테스트 모음)
- **Purpose / 목적**: Comprehensive test suite for DEVS models
  - DEVS 모델에 대한 종합적인 테스트 모음
- **Components / 구성요소**:
  - Atomic Models tests
    - 원자 모델 테스트
  - Coupled Models tests
    - 결합 모델 테스트
- **Features / 특징**:
  - Performance monitoring
    - 성능 모니터링
  - Memory usage tracking
    - 메모리 사용량 추적
  - CSV result logging
    - CSV 형식의 결과 로깅
  - Multiple test runs with statistics
    - 통계를 포함한 다중 테스트 실행

## Configuration / 설정

The `config.py` file in the test directory sets up the necessary Python paths for testing. It is automatically imported when the test package is initialized.
테스트 디렉토리의 `config.py` 파일은 테스트에 필요한 Python 경로를 설정합니다. 이는 테스트 패키지가 초기화될 때 자동으로 import됩니다.

## Running Tests / 테스트 실행

To run the tests, use the following command from the project root:
테스트를 실행하려면 프로젝트 루트에서 다음 명령어를 사용하세요:

```bash
python -m unittest discover test
```

Or for specific test files:
또는 특정 테스트 파일을 실행하려면:

```bash
python -m unittest test/engine/testBROADCAST_MODELS.py
``` 