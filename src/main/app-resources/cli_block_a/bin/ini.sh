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

#rm -rf /data/outDIR/ISD/ISD000/

export -p ODIR=/data/outDIR
export -p DIR=$ODIR/ISD
if [ ! -d "$DIR" ]; then
    rm -rf $ODIR/ISD
    mkdir -pm 777 $ODIR/ISD
fi

#-------------------------------------------------------------------------------------# 
export -p OUTDIR=$ODIR/ISD/ISD000 && mkdir -pm 777 $OUTDIR
mkdir -pm 777 $OUTDIR/VM001
export -p NVDIR=$OUTDIR/VM001/class_NDV001 && mkdir -pm 777 $NVDIR
mkdir -pm 777 $OUTDIR/SM001
export -p SBDIR=$OUTDIR/SM001/class_SOIL001 && mkdir -pm 777 $SBDIR
mkdir -pm 777 $OUTDIR/CM001
export -p CMDIR=$OUTDIR/CM001/AOI && mkdir -pm 777 $CMDIR
export -p CDIR=$OUTDIR/SM001 && mkdir -pm 777 $CDIR
export -p VDIR=$OUTDIR/VM001 && mkdir -pm 777 $VDIR
export -p PDIR=$OUTDIR/PM001 && mkdir -pm 777 $PDIR
export -p ZDIR=$OUTDIR/GEOMS && mkdir -pm 777 $ZDIR
export -p VITO=$OUTDIR/VITO && mkdir -pm 777 $VITO
export -p ISDC=$ZDIR/Cx && mkdir -pm 777 $ISDC
export -p ISDD=$ZDIR/Dx && mkdir -pm 777 $ISDD
export -p LDIR=$OUTDIR/COKC && mkdir -pm 777 $LDIR
export -p CMDIR01=$CMDIR/AOI_CX && mkdir -pm 777 $CMDIR01
export -p CMDIR02=$CMDIR/AOI_DX && mkdir -pm 777 $CMDIR02
#-------------------------------------------------------------------------------------# 
#-------------------------------------------------------------------------------------# 
exit 0
