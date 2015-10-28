#!/bin/sh
#-------------------------------------------------------------------------------------# 
# PURPOSE: RESAMPLE_AOI LULC
#-------------------------------------------------------------------------------------# 
# Requires:
# gdalinfo
# gdal_calc
# gdalwarp
#-------------------------------------------------------------------------------------# 

# bash /application/bin/ISD5_node/ini.sh
export -p DIR=~/data/ISD/
#export PATH=/opt/anaconda/bin/:$PATH
export -p INDIR=~/data/INPUT/ISD
export -p OUTDIR=$DIR/ISD000/
export -p CMDIR01=$OUTDIR/CM001//AOI/AOI_CX
export -p OUTDIR01=~/data/ISD/ISD000/VITO

Cx001=$(grep "Cx001" $1)
LAND001=$(grep "GLOBCOVER" $1)

mkdir -p $OUTDIR01
#-------------------------------------------------------------------------------------#
# CROP LAND/LANDCOVER
#-------------------------------------------------------------------------------------# 

# Get the same boundary information_globcover
ulx=$(gdalinfo $Cx001  | grep "Upper Left" | awk '{ gsub ("[(),]","") ; print  $3  }')
uly=$(gdalinfo $Cx001  | grep "Upper Left" | awk '{ gsub ("[(),]","") ; print  $4  }')
lrx=$(gdalinfo $Cx001  | grep "Lower Right" | awk '{ gsub ("[(),]","") ; print $3  }')
lry=$(gdalinfo $Cx001  | grep "Lower Right" | awk '{ gsub ("[(),]","") ; print $4  }')
echo $ulx $uly $lrx $lry  
gdal_translate -projwin $ulx $uly $lrx $lry -of GTiff $LAND001 $OUTDIR01/GLOBCOVER_01.tif 

#-------------------------------------------------------------------------------------#



