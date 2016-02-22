#!/bin/sh
#-------------------------------------------------------------------------------------# 
# PURPOSE: Setup environment variables
#-------------------------------------------------------------------------------------# 
#-------------------------------------------------------------------------------------# 
anaconda=/opt/anaconda/bin/
#-------------------------------------------------------------------------------------# 
#-------------------------------------------------------------------------------------# 
# Define parameter path + filename
export DIR=/data/auxdata/ISD/
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
#export -p HDIR=/application/bin/ISD5_Nx
export -p CMDIR=$OUTDIR/CM001/AOI
export -p CDIR=$OUTDIR/SM001
export -p VDIR=$OUTDIR/VM001
export -p PDIR=$OUTDIR/PM001
export -p ZDIR=$OUTDIR/GEOMS
export -p LAND=$INDIR/LANDCOVER
export -p LAND000=$INDIR/LANDCOVER/LANDCOVER000
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
#output: The Indicator of Susceptibility to Desertification (ISD)
export LDIR=$OUTDIR/COKC
mkdir -p $LDIR
#-------------------------------------------------------------------------------------# 