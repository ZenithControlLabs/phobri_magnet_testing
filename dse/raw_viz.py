import numpy as np
import pandas as pd
import matplotlib.pyplot as plt

#raw = pd.read_csv("data/ctlr_one_mag.csv")
raw = pd.read_csv("data/ctlr_full.csv")

fig = plt.figure()
ax = fig.add_subplot(projection='3d')
ax.scatter(raw["hx_x"][:10000],raw["hx_y"][:10000],raw["hx_z"][:10000], color="red")
ax.scatter(raw["hy_x"][:10000],raw["hy_y"][:10000],raw["hy_z"][:10000])
ax.set_xlabel("BX")
ax.set_ylabel("BY")
ax.set_zlabel("BZ")
plt.show()
