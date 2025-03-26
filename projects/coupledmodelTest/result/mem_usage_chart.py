import matplotlib.pyplot as plt
import numpy as np

# 데이터 준비
sequences = list(range(1, 21))
proposed = [29.316, 28.629, 28.668, 28.676, 28.719, 28.723, 28.73, 28.727, 28.746, 28.754, 
          28.758, 28.758, 28.77, 28.797, 28.793, 28.797, 28.797, 28.809, 28.809, 28.809]
unittest = [23.449, 22.59, 22.621, 22.641, 22.637, 22.629, 22.652, 22.648, 22.637, 22.668,
          22.668, 22.68, 22.684, 22.691, 22.68, 22.68, 22.695, 22.688, 22.695, 22.688]
pytest = [33.07, 32.941, 33.344, 33.707, 34.129, 34.191, 34.523, 34.629, 34.992, 34.957,
         34.973, 34.965, 34.957, 34.988, 35.0, 34.98, 35.0, 35.109, 35.391, 35.484]

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
plt.xlabel('Test Sequence', fontsize=13, fontweight='bold')  # 크기 증가 및 진하게
plt.ylabel('Memory (MB)', fontsize=13, fontweight='bold')    # 크기 증가 및 진하게

# y축 범위 및 눈금 설정
plt.ylim(15, 40)
plt.yticks(range(15, 45, 5))

# x축 눈금 설정
plt.xticks(sequences)

# 범례 설정 - 그래프 상단 중앙에 한 줄로
plt.legend(loc='upper center', bbox_to_anchor=(0.5, 1.15), ncol=3)

# 여백 조정
plt.tight_layout()

# 그래프 저장
plt.savefig('memory_usage_comparison.png', dpi=300, bbox_inches='tight')
plt.show()