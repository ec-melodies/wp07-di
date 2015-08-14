#!/bin/bash

# verify 
# cat /application/bin/ISD5_node/main.sh
 
# define variables
Lib=/application/lib
Bin=/application/bin

JOB=/application/bin/ISD5_node/main.sh

anaconda=/opt/anaconda/bin/
# basepath=/usr/lib64/qt-3.3/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin:

 
# # define environment variables
# export GRASS_BATCH_JOB=/application/main.sh

# export PATH=$PATH:$Bin:$Lib
# export PYTHONPATH=$Lib
# export GDAL_DATA=/application/gdal
 
# # run the job
# grass64 -text /data/GRASSdb_ISD/World/Local/
# # or
# # grass70 ~/grassdata/nc_spm_08_grass7/user1
 
# # switch back to interactive mode
# unset GRASS_BATCH_JOB

##########################
# Define parameter path + filename
export DIR=~/data
mkdir -p $DIR

#input: PROVA -V, SPOT_VGT, land cover, ecwmf
#export INDIR=$DIR/INPUT
export INDIR=~/data/INPUT
cd $INDIR

#auxiliar data files (tmp): The intermediate indicators:
export OUTDIR=$DIR/ISD010/
mkdir -p $OUTDIR

export -p NVDIR=$OUTDIR/VM001/class_NDV001/
export -p SBDIR=$OUTDIR/SM001/class_SOIL001/
export -p HDIR=/application/bin/ISD5_node/
export -p OUTDIR001=$OUTDIR/CM001

export -p CDIR=$OUTDIR/SM001
export -p VDIR=$OUTDIR/VM001
export -p PDIR=$OUTDIR/PM001
export -p ZDIR=$OUTDIR/GEOMS

mkdir -p $OUTDIR001
mkdir -p $NVDIR
mkdir -p $SBDIR
mkdir -p $PDIR

#output: The Indicator of Susceptibility to Desertification (ISD)
export -p LDIR=$OUTDIR/COKC
mkdir -p $LDIR

