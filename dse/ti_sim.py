import numpy as np
import pandas as pd
import matplotlib.pyplot as plt

sensor_x = pd.read_csv("data/ti_sim/sensor_x_strong_ofs.csv")
sensor_y = pd.read_csv("data/ti_sim/sensor_y_strong_ofs.csv")

sensor_x_bx = np.repeat(sensor_x["Bx"], 60)
sensor_x_by = np.repeat(sensor_x["By"], 60)
sensor_x_bz = np.repeat(sensor_x["Bz"], 60)

#sensor_y_bx = np.repeat(sensor_y["Bx"][0], 61*60)
#sensor_y_by = np.repeat(sensor_y["By"][0], 61*60)
#sensor_y_bz = np.repeat(sensor_y["Bz"][0], 61*60)

sensor_y_bx = np.tile(sensor_y["Bx"], 60)
sensor_y_by = np.tile(sensor_y["By"], 60)
sensor_y_bz = np.tile(sensor_y["Bz"], 60)

Bx = sensor_x_bx# + sensor_y_bx
By = sensor_x_by# + sensor_y_by
Bz = sensor_x_bz# + sensor_y_bz

import math
sensor_ang_x = sensor_x["Tilt Angle (deg)"]
#sensor_ang_y = np.tile(sensor_y["Tilt Angle (deg)"], 60)
atbxby = np.sqrt(sensor_x["Bx"] * sensor_x["Bx"] + sensor_x["Bz"] * sensor_x["Bz"])

fig = plt.figure()
ax = fig.add_subplot() # projection='3d'
#ax.scatter(Bx,By,Bz)
ax.plot(sensor_ang_x, atbxby)
#ax.scatter(sensor_ang_x,sensor_ang_y,atbxby)
plt.show()