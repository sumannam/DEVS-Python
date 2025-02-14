import matplotlib.pyplot as plt
import numpy as np

# 데이터 준비
sequences = list(range(1, 21))
proposed = [4.6, 5.6, 10.5, 3.1, 1.6, 4.0, 5.8, 1.1, 2.2, 2.6, 
          1.0, 1.2, 2.0, 2.9, 1.5, 1.0, 3.1, 1.4, 1.4, 0.6]
unittest = [11.7, 3.1, 2.8, 3.9, 4.0, 9.1, 6.9, 4.4, 0.4, 0.4,
           1.8, 2.8, 2.4, 1.9, 5.7, 4.0, 0.9, 2.5, 0.8, 4.3]
pytest = [15.9, 2.4, 3.6, 1.4, 1.1, 5.7, 2.5, 0.5, 3.3, 1.8,
         2.5, 2.3, 1.3, 1.7, 0.5, 5.2, 1.7, 1.1, 3.0, 0.9]

# 글꼴 설정
plt.rcParams['font.family'] = 'Times New Roman'
plt.rcParams['font.size'] = 12

# 그래프 설정
plt.figure(figsize=(10, 6))

# 선 그래프 그리기
plt.plot(sequences, proposed, 'rs-', label='Proposed System', markersize=9, linewidth=1.5, markerfacecolor='white')
plt.plot(sequences, unittest, 'g^-', label='Unitest', markersize=7, linewidth=1.5, markerfacecolor='white')
plt.plot(sequences, pytest, 'bo-', label='Pytest', markersize=7, linewidth=1.5, markerfacecolor='white')

# 그래프 꾸미기
plt.grid(True, linestyle='-', alpha=0.2)
plt.xlabel('Test Sequence', fontsize=13, fontweight='bold')
plt.ylabel('CPU Usage (%)', fontsize=13, fontweight='bold')

# y축 범위 및 눈금 설정
plt.ylim(0, 16)
plt.yticks(range(0, 17, 4))

# x축 눈금 설정
plt.xticks(sequences)

# 범례 설정 - 그래프 상단 중앙에 한 줄로
plt.legend(loc='upper center', bbox_to_anchor=(0.5, 1.15), ncol=3)

# 여백 조정
plt.tight_layout()

# 그래프 저장
plt.savefig('cpu_usage_comparison.png', dpi=300, bbox_inches='tight')
plt.show()

# 통계 출력
print("\nStatistical Analysis:")
print(f"Proposed Method - Mean: {np.mean(proposed):.3f} %, Std: {np.std(proposed):.3f}")
print(f"Unittest        - Mean: {np.mean(unittest):.3f} %, Std: {np.std(unittest):.3f}")
print(f"Pytest         - Mean: {np.mean(pytest):.3f} %, Std: {np.std(pytest):.3f}")