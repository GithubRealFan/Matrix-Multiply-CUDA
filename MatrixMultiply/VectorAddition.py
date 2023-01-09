import numpy as np
import matplotlib.pyplot as plt
s_seg = [25, 250, 2500, 25000, 250000]
data = [[87, 11, 30, 10, 9],
        [308, 43, 3, 1, 1],
        [959, 106, 12, 7, 4]]
X = np.arange(len(data[0]))
fig, ax = plt.subplots(figsize=(8, 4))
ax.bar(X + 0.00, data[0], color = 'r', width = 0.25)
ax.bar(X + 0.25, data[1], color = 'g', width = 0.25)
ax.bar(X + 0.50, data[2], color = 'b', width = 0.25)
ax.legend(labels=['Host to Device', 'Kernel', 'Device to Host'])
ax.set_xticks(X)
ax.set_xticklabels(s_seg)
plt.xlabel('Number of input values')
plt.ylabel('Execution time (ms)')
fig.tight_layout()
plt.show()
