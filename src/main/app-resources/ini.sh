#!/bin/bash

# verify 
cat /application/main.sh
 
# define variables
Lib=/application/lib
Bin=/application/bin


# basepath=/usr/lib64/qt-3.3/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin:

 
# define environment variables
export GRASS_BATCH_JOB=/application/main.sh

export PATH=$PATH:$Bin:$Lib
export PYTHONPATH=$Lib
export GDAL_DATA=/application/gdal
 
# run the job
grass64 -text /data/GRASSdb_ISD/World/Local/
# or
# grass70 ~/grassdata/nc_spm_08_grass7/user1
 
# switch back to interactive mode
unset GRASS_BATCH_JOB


