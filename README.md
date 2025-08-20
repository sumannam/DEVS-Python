# DEVS-Python

## DEVS (Discrete Event System Specification)란?

DEVS는 이산 사건 시스템을 모델링하고 시뮬레이션하기 위한 형식적인 프레임워크이이다. 1976년 Bernard P. Zeigler에 의해 제안된 이 방법론은 다음과 같은 특징을 가지고 있다

- **모듈성**: 시스템을 독립적인 컴포넌트로 분해하여 모델링
- **계층성**: 단순한 모델들을 조합하여 복잡한 시스템을 구성
- **형식성**: 수학적으로 엄밀한 명세를 제공
- **재사용성**: 모델의 재사용과 확장이 용이

DEVS는 두 가지 기본 모델 유형을 제공합니다:
1. **원자 모델 (Atomic Model)**: 시스템의 기본 구성 요소
2. **결합 모델 (Coupled Model)**: 여러 모델을 연결하여 더 큰 시스템을 구성

## DEVS-Python

DEVS-Python은 Python을 기반으로 DEVS 모델을 구현하고 시뮬레이션할 수 있는 프레임워크이다. 이 프로젝트는 다음과 같은 특징을 가지고 있다.

### 주요 특징
- **Python 기반**: Python의 간단하고 직관적인 문법을 활용
- **객체지향 설계**: DEVS의 기본 클래스 계층 구조를 Python 클래스로 구현
- **확장성**: 풍부한 Python 라이브러리 생태계 활용 가능
- **사용자 친화적**: 초보자도 쉽게 모델링 가능

### 프로젝트 구조
```
DEVS-Python/
├── src/ # 소스 코드
├── projects/ # 예제 프로젝트
├── test/ # 테스트 코드
└── doc/ # 문서
```

## 인용
```
@software{sumannamDEVS-Python},
author = {Suman, Nam},
title = {DEVS-Python},
year = {2022},
publisher = {GitHub},
journal = {GitHub repository},
howpublished = {\url{https://github.com/sumannam/DEVS-Python},
}
```


## 라이선스
이 프로젝트는 LICENSE 파일에 명시된 라이선스 하에 배포된다.