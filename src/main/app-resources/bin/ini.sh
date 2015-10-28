#!/bin/sh
#-------------------------------------------------------------------------------------# 
# PURPOSE: Setup environment variables
#-------------------------------------------------------------------------------------# 
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
export INDIR=$DIR/INPUT
#-------------------------------------------------------------------------------------# 
#auxiliar data files (tmp): The intermediate indicators:
export OUTDIR=$DIR/ISD000/

#-------------------------------------------------------------------------------------# 
export -p NVDIR=$OUTDIR/VM001/class_NDV001/
export -p SBDIR=$OUTDIR/SM001/class_SOIL001/
export -p HDIR=/application/bin/ISD5_node/
export -p CMDIR=$OUTDIR/CM001/AOI
<<<<<<< HEAD:src/main/app-resources/bin/ini.sh
=======
export -p SPPV00101=$OUTDIR/SPPV001/AOI1/VX
export -p SPPV00102=$OUTDIR/SPPV001/AOI1/SX
>>>>>>> 771a50f1325b740d146e0f06257ab50f4fee6ab5:src/main/app-resources/bin/ini.sh
export -p CDIR=$OUTDIR/SM001
export -p VDIR=$OUTDIR/VM001
export -p PDIR=$OUTDIR/PM001
export -p ZDIR=$OUTDIR/GEOMS
export -p LAND=$INDIR/LANDCOVER
export -p LAND000=$INDIR/LANDCOVER/LANDCOVER000
export -p ISDC=$ZDIR/Cx
export -p ISDD=$ZDIR/Dx
export -p HDIR=~/wp07-di/src/main/app-resources/bin/ISD5_node/
export -p ADIR=$DIR/AOI
<<<<<<< HEAD:src/main/app-resources/bin/ini.sh
export -p CMDIR01=$CMDIR/AOI_CX
export -p CMDIR02=$CMDIR/AOI_DX

=======
>>>>>>> 771a50f1325b740d146e0f06257ab50f4fee6ab5:src/main/app-resources/bin/ini.sh
#-------------------------------------------------------------------------------------# 
mkdir -p $OUTDIR
mkdir -p $CMDIR
mkdir -p $CMDIR01
mkdir -p $CMDIR02
mkdir -p $NVDIR
mkdir -p $SBDIR
mkdir -p $CDIR
mkdir -p $VDIR
mkdir -p $PDIR
mkdir -p $ZDIR
mkdir -p $ISDC
mkdir -p $ISDD
<<<<<<< HEAD:src/main/app-resources/bin/ini.sh

=======
mkdir -p $SPPV00101
mkdir -p $SPPV00102
>>>>>>> 771a50f1325b740d146e0f06257ab50f4fee6ab5:src/main/app-resources/bin/ini.sh
#-------------------------------------------------------------------------------------# 
#output: The Indicator of Susceptibility to Desertification (ISD)
export LDIR=$OUTDIR/COKC
mkdir -p $LDIR
#-------------------------------------------------------------------------------------# 