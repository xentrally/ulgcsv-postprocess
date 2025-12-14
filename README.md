# File breakdowns
## ulog_script.sh
This script will convert all .ulg files in the current folder and convert them into a series of .csv files. These converted files are sorted into folders respective to their .ulg file name, and aggregated in a folder called "csv_version". "csv_version" will be a subfolder in the current path.
For more details, please refer to the file structure breakdown in the script.

## csv_processing.sh
This script creates a .csv file that can be used as flight logs for the AirFloX (JB Hyperspectral) sensors.
It requires:
- vehicle gps position, global position, attitude, and a combined sensor .csv file, which are usually converted from .ulg files.
- a subfolder called "csv_version" to exist, where further subfolders within this contain .csv files converted from .ulg files.
The script also provides an alternate method of adding roll, pitch and yaw speeds into the flight log.

# Running the scripts
Ensure `ulog_script.sh` and `csv_processing.sh` are in the folder with all .ulg files to convert.
In Linux terminal, use `./ulog_script.sh` for the .ulg to .csv conversion script to run. Upon completion, use `./csv_processing.sh` for .csv post processing.
