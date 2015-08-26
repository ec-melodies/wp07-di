#!/bin/sh
#-------------------------------------------------------------------------------------# 
# PURPOSE: Setup environment variables
#-------------------------------------------------------------------------------------# 
# verify 
# cat /application/bin/ISD5_node/main.sh
#-------------------------------------------------------------------------------------# 
# define variables
Lib=/application/lib
Bin=/application/bin
#-------------------------------------------------------------------------------------# 
#JOB=/application/bin/ISD5_node/main.sh
#-------------------------------------------------------------------------------------# 
anaconda=/opt/anaconda/bin/
#-------------------------------------------------------------------------------------# 
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
#-------------------------------------------------------------------------------------# 
# Define parameter path + filename
export DIR=~/data/ISD/
if [ ! -d "$DIR" ]; then
    mkdir $DIR
fi
#-------------------------------------------------------------------------------------# 
#input: PROVA -V, SPOT_VGT, land cover, ecwmf
#export INDIR=$DIR/INPUT
INDIR=~/data/INPUT
#-------------------------------------------------------------------------------------# 
#auxiliar data files (tmp): The intermediate indicators:
OUTDIR=$DIR/ISD001/

#-------------------------------------------------------------------------------------# 
NVDIR=$OUTDIR/VM001/class_NDV001/
SBDIR=$OUTDIR/SM001/class_SOIL001/
HDIR=/application/bin/ISD5_node/
CMDIR=$OUTDIR/CM001
CDIR=$OUTDIR/SM001
VDIR=$OUTDIR/VM001
PDIR=$OUTDIR/PM001
ZDIR=$OUTDIR/GEOMS
LAND=$INDIR/LANDCOVER
ISDC=$ZDIR/Cx
ISDD=$ZDIR/Dx
HDIR=$DIR/scripts
ADIR=$DIR/AOI
#-------------------------------------------------------------------------------------# 
mkdir -p $OUTDIR
mkdir -p $CMDIR
mkdir -p $NVDIR
mkdir -p $SBDIR
mkdir -p $CDIR
mkdir -p $VDIR
mkdir -p $PDIR
mkdir -p $ZDIR
mkdir -p $ISDC
mkdir -p $ISDD
#-------------------------------------------------------------------------------------# 
#output: The Indicator of Susceptibility to Desertification (ISD)
LDIR=$OUTDIR/COKC
mkdir -p $LDIR
#-------------------------------------------------------------------------------------# 