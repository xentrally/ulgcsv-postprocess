#!/bin/bash

:<< 'COMMENT'
In this script, we will do some post processing on the extracted csv files.
Similar to ulog_script, we will enter into the csv_version folder and each subsequent ulog-file-folder, creating a new, post-processed csv file.
COMMENT

cd csv_version
for folder in */
do
   echo iternating into "$folder"
   cd "$folder"
   python3 <<'END_OF_PYTHON'
#!/usr/bin/env python
import pandas as pd
pd.options.mode.chained_assignment = None
import os
import numpy as np

path = os.getcwd()
# taking the current folder path
folder_name = path.split("/")[-1]

# Load example logs
gps = pd.read_csv(f"{path}/{folder_name}_vehicle_gps_position_0.csv")
# glopos = pd.read_csv(f"{path}/{folder_name}_vehicle_global_position_0.csv")
attitude = pd.read_csv(f"{path}/{folder_name}_vehicle_attitude_0.csv")
sensors = pd.read_csv(f"{path}/{folder_name}_sensor_combined_0.csv")

print("Successfully read csv files of gps, attitude and sensors.")

# Load GPS data
# gps = gps[['timestamp', 'time_utc_usec', 'lat', 'lon']]  # keep only these columns
gps = gps[['timestamp', 'time_utc_usec', 'lat', 'lon', 'alt']]  # keep only these columns
gps['lat'] = gps['lat'] * 1e-7  # convert to degrees
gps['lon'] = gps['lon'] * 1e-7
gps['alt'] = gps['alt'] / 1000 # convert to m
print("GPS data loaded")

# glopos = glopos[['timestamp', 'alt']] # global position of altitude, already in metres.
# Create column for drone altitude, relative to take off height (first height in entry of glopos)
# glopos.insert(1, 'drone_alt', 0.0)
gps.insert(1, 'drone_alt', 0.0)
#startPoint = glopos['alt'][0]
startPoint = gps['alt'][0]
# for i in range(len(glopos)):
#    diff = glopos['alt'][i] - startPoint
#    glopos['drone_alt'][i] = diff

for i in range(len(gps)):
   diff = gps['alt'][i] - startPoint
   gps['drone_alt'][i] = diff
print("Global altitude data loaded")

# Load Attitude data
# attitude = attitude[['timestamp', 'rollspeed', 'pitchspeed', 'yawspeed', 'q[0]', 'q[1]', 'q[2]', 'q[3]']]

attitude = attitude[['timestamp', 'q[0]', 'q[1]', 'q[2]', 'q[3]']]

# where q0-q3 are quaternions.

# Create RPY (roll pitch yaw) columns
attitude.insert(1, 'roll', 0.0)
attitude.insert(1, 'pitch', 0.0)
attitude.insert(1, 'yaw', 0.0)
print("Attitude data loaded and preset")

# Convert quaternions to RPY and fill
for i in range(len(attitude)):
    w = attitude['q[0]'][i].astype(float) 
    x = attitude['q[1]'][i].astype(float)
    y = attitude['q[2]'][i].astype(float)
    z = attitude['q[3]'][i].astype(float)
    
    ysqr = y * y

    t0 = 2.0 * (w * x + y * z)
    t1 = 1.0 - 2.0 * (x * x + ysqr)
    X = np.degrees(np.arctan2(t0, t1))
    attitude['roll'][i] = X

    t2 = 2.0 * (w * y - z * x)
    t2 = np.clip(t2, a_min=-1.0, a_max=1.0)
    Y = np.degrees(np.arcsin(t2))
    attitude['pitch'][i] = Y

    t3 = 2.0 * (w * z + x * y)
    t4 = 1.0 - 2.0 * (ysqr + z * z)
    Z = np.degrees(np.arctan2(t3, t4))
    attitude['yaw'][i] = Z

print(attitude)

# Merge on 'timestamp'
# first_merge = pd.merge_asof(gps.sort_values('timestamp'), attitude.sort_values('timestamp'), on='timestamp', direction='nearest')

# merged = pd.merge_asof(first_merge.sort_values('timestamp'), glopos.sort_values('timestamp'), on='timestamp', direction='nearest')

merged = pd.merge_asof(gps.sort_values('timestamp'), attitude.sort_values('timestamp'), on='timestamp', direction='nearest')


print(merged)

# Convert timestamp to datetime. Timestamps are unix microseconds.
merged['time'] = pd.to_datetime(merged['time_utc_usec'], unit='us', origin='unix', utc=True)
merged['time'] = merged['time'].astype(str)

# drop the reference for cleanliness. Add or delete from the list as you see fit.
merged.drop(columns=['time_utc_usec', 'q[0]', 'q[1]', 'q[2]', 'q[3]'])

# Reorder and rename columns
# merged = merged[['time', 'lat', 'lon', 'alt', 'drone_alt', 'rollspeed', 'pitchspeed', 'yawspeed', 'roll', 'pitch', 'yaw']]

merged = merged[['time', 'lat', 'lon', 'alt', 'drone_alt', 'roll', 'pitch', 'yaw']]

print(merged)

# Save to Excel
# merged.to_excel(f"{path}/{folder_name}_airflox_flight_log_combined.xlsx", index=False)

# Save to csv
merged.to_csv(f"{path}/{folder_name}_airflox_flight_log_local.csv")

print(f"✅ File saved as {folder_name}_airflox_flight_log_combined.csv with time, lat, lon, alt, drone_alt, pitch, roll, yaw.")
END_OF_PYTHON
   echo finished current folder csv file processing.
   cd ..
done
