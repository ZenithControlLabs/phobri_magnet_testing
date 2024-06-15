import magpylib as magpy
import numpy as np
import matplotlib.pyplot as plt
from dataclasses import dataclass
from types import *

from magpylib.magnet import Cylinder, CylinderSegment

# GLOBAL CONSTANTS
DIST_PCB_TO_STICK_AXLE = 7 # mm
STICKBOX_LENGTH = 15 # mm
DIST_PCB_SENSOR = 0.65 # mm
UNDERSLING = 0 #-5 # mm
STICK_FULL_TILT = 30 # deg
ROT_STEPS = 40
ADC_CONV = 684.2 # (ADC LSB)/mT

def sim_magnetic_flux(magnet, sensor_pos, select_x, angles, positions):
    magnet_x = magnet(True)
    magnet_y = magnet(False)

    magnet_x.position = (0,0,DIST_PCB_TO_STICK_AXLE - UNDERSLING)
    magnet_y.position = (STICKBOX_LENGTH/2,STICKBOX_LENGTH/2,DIST_PCB_TO_STICK_AXLE - UNDERSLING)

    sensor = magpy.Sensor(position=(sensor_pos[0], sensor_pos[1], DIST_PCB_SENSOR))

    target_magnet = magnet_y
    if select_x:
        target_magnet = magnet_x

    if angles:
        steps = len(angles)
        if select_x:
            magnet_x.rotate_from_angax(angles, "y",
                                anchor=(0,0,DIST_PCB_TO_STICK_AXLE), start=0)
        else: 
            magnet_y.rotate_from_angax(angles, "x",
                                anchor=(STICKBOX_LENGTH/2, STICKBOX_LENGTH/2, DIST_PCB_TO_STICK_AXLE), start=0)
    if positions:
        steps = len(positions)
        axle_pos = np.transpose([np.zeros(steps), np.zeros(steps), positions])    
        target_magnet.move(axle_pos)
    
    if False:
        magpy.show(sensor, magnet_x, magnet_y, backend="plotly", animation=True)

    B = sensor.getB(target_magnet) * ADC_CONV
  
    if positions:
        return B[1:]
    else:
        return B


DH1H1_HEIGHT_DIAM = 1/10 * 25.4
def MAG_CYLINDER(axis_x):
    mag = Cylinder(magnetization=(0, 0, 5000), dimension=(DH1H1_HEIGHT_DIAM, DH1H1_HEIGHT_DIAM))
    if axis_x:
        mag.rotate_from_euler(90*3, "y")
    else:
        mag.rotate_from_euler(90, "x")
    return mag

SENSOR_RANGE = 30
ENTRIES = 50
resultsX = np.zeros((ENTRIES, ENTRIES))
resultsY = np.zeros((ENTRIES, ENTRIES))
resultsZ = np.zeros((ENTRIES, ENTRIES))
resultsM = np.zeros((ENTRIES, ENTRIES))
sensor_pos = (STICKBOX_LENGTH/2, 0)

angles = np.linspace(-30, 30,100)
positions = np.linspace(0, -1.0,100)
rot_results = sim_magnetic_flux(MAG_CYLINDER, sensor_pos, True, list(angles), [])
rot_results += sim_magnetic_flux(MAG_CYLINDER, sensor_pos, False, list(angles), [])
pos_results = sim_magnetic_flux(MAG_CYLINDER, sensor_pos, True, [], list(positions))
print(rot_results)
rot_results =  np.diff(rot_results, axis=0)
pos_results =  np.diff(pos_results, axis=0)
print(rot_results)

# show the derivative of each axis of B
fig, axs = plt.subplots(2,3, width_ratios=[2.0,2.0,2.0], sharey=False, sharex=False)

for thing in range(2):
    for axis in range(3):
        orig = [angles, positions][thing]
        thing2 = [rot_results, pos_results][thing]
        #fit = np.polyfit(orig,thing2[:, axis], 7)
        axs[thing][axis].set_title("dB{}/dθ M={}".format(["x","y","z"][axis], ["x","y"][thing]))
        axs[thing][axis].plot(orig[1:], thing2[:,axis])
        print("a")
        
fig.tight_layout()
fig.show()
plt.show()