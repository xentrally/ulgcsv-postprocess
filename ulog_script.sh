#!/bin/bash
:<< 'COMMENT'
STRUCTURE OF FILES:
curr_path
|- files of all raw ulg data

This code will create a folder in the existing path called "csv_version":
csv_version
|- [ulg file name]
    |- csv files extracted from the ulg, separated into files per name.

use ulog_info file_name.ulg to view all names in the ulog.

It will display something like this:
ulog_info sample.ulg
Name (multi id, message size in bytes)    number of data points, total bytes
 actuator_controls_0 (0, 48)                 3269     156912
control_state (0, 122)                      3268     398696

the names of the csv files extracted from the ulg will then follow the format file_name_Name_mulitId.csv. 
For example: 
sample_actuator_controls_0_0.csv, sample_control_state_0.csv
COMMENT

# create csv_version folder if it doesn't exist yet.
test -d "csv_version" || mkdir csv_version
echo starting conversion of ulg files to csv.
for file in *.ulg
do 
   cd csv_version
   echo converting "$file" to csv...
   # obtain file name without extension, and create that folder.
   file_name=$(echo "$file"| sed -r "s/(.+\/)?(.+)\..+/\2/") 
   echo obtained name "$file_name"
   test -d "$file_name" || mkdir "$file_name"
   cd ..
   pwd
   
   # now, convert the ulog files into csv :D
   ulog2csv -o csv_version/"$file_name" "$file"
   echo conversion completed.
done



