#!/bin/bash
#-------------------------------------------------------------------------------------# 
# PURPOSE: Setup environment variables
#-------------------------------------------------------------------------------------# 
#-------------------------------------------------------------------------------------# 
# define variables
Lib=/application/lib
Bin=/application/bin
#-------------------------------------------------------------------------------------# 
#-------------------------------------------------------------------------------------# 
anaconda=/opt/anaconda/bin/
#-------------------------------------------------------------------------------------# 
#-------------------------------------------------------------------------------------# 
# Define parameter path + filename

export -p ODIR=$TMPDIR/data/outDIR
#export -p ODIR=/data/outDIR
rm -rf $ODIR/ISD

export -p DIR=$ODIR/ISD
if [ ! -d "$DIR" ]; then
    mkdir -m 777 $DIR
fi

echo $DIR
#-------------------------------------------------------------------------------------# 
export OUTDIR=$DIR/ISD000
mkdir -m 777 $OUTDIR
export -p NVDIR=$OUTDIR/VM001/class_NDV001/
export -p SBDIR=$OUTDIR/SM001/class_SOIL001/
export -p CMDIR=$OUTDIR/CM001/AOI
export -p CDIR=$OUTDIR/SM001
export -p VDIR=$OUTDIR/VM001
export -p PDIR=$OUTDIR/PM001
export -p ZDIR=$OUTDIR/GEOMS
export -p VITO=$OUTDIR/VITO
export -p ISDC=$ZDIR/Cx
export -p ISDD=$ZDIR/Dx
export -p ADIR=$DIR/AOI

export -p CMDIR01=$CMDIR/AOI_CX
export -p CMDIR02=$CMDIR/AOI_DX

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
#-------------------------------------------------------------------------------------# 
export LDIR=$OUTDIR/COKC
mkdir -p $LDIR
echo $LDIR
#-------------------------------------------------------------------------------------# 

