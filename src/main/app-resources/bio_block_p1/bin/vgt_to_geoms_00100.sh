#!/bin/bash
#-------------------------------------------------------------------------------------# 
# PURPOSE: Local vegetation status [V(x)]
#-------------------------------------------------------------------------------------# 
# Requires:
# gdalinfo
# gdal_calc
# gdalwarp
# pktools
# R packages: 
# zoo
# rgdal
# raster
# sp
# maptools
# rciop
#-------------------------------------------------------------------------------------# 
# source the ciop functions
source ${ciop_job_include}
#-------------------------------------------------------------------------------------# 
# the environment variables 
#-------------------------------------------------------------------------------------# 
export PATH=/opt/anaconda/bin/:$PATH
export -p IDIR=/application/
export -p ODIR=/data/outDIR
export -p DIR=$ODIR/ISD
export -p OUTDIR=$DIR/ISD000
export -p VITO=$OUTDIR/VITO
export -p VDIR=$OUTDIR/VM001
export -p NVDIR=$OUTDIR/VM001/class_NDV001
#-------------------------------------------------------------------------------------#
#-------------------------------------------------------------------------------------#
# JOB# resample LULC para o mesmo pixel scale do target (SPOT or PROBA-V)

export -p Cx001=$OUTDIR/CM001/AOI/AOI_CX/Cx001.txt
#-------------------------------------------------------------------------------------#

for file in $VITO/NDV001_01_crop*.tif; do 
filename=$(basename $file .tif )
input001=$VITO/${filename}.tif
input002=$VITO/${filename/#NDV001_01_crop/LANDC002}.tif 
output003=$VITO/${filename/#NDV001_01_crop/NDV001_02_crop}.tif 
echo $input001 $input002 $output003
z001="$(gdalinfo $input002 | grep "Pixel Size" |  awk  -F, ' {print $(NF-1)}'| awk '{ gsub ("[(),]","") ; print  $4  }')"
gdalwarp -tr $z001 $z001 -r bilinear -overwrite $input001 $output003
done

#-------------------------------------------------------------------------------------#
#-------------------------------------------------------------------------------------#
# r.factor: PhyVal = DN / ScalingFactor + Offset, Offset=-0.08, Scaling factor=250
# PV = (1/250) * DN + (-0.08) 
#-------------------------------------------------------------------------------------#

for file in $VITO/NDV001_02_crop*.tif; do 
filename=$(basename $file .tif )
input001=$VITO/${filename}.tif
output003=$VITO/${filename/#NDV001_02_crop/NDV02_001_crop}.tif 
gdal_calc.py -A $input001 --outfile=$output003 --calc="(((A*0.004)-0.08)*10000.0)" --overwrite --NoDataValue=255 --type=Float64 
done
#-------------------------------------------------------------------------------------#
#-------------------------------------------------------------------------------------#
#-------------------------------------------------------------------------------------#
#-------------------------------------------------------------------------------------# 
R --vanilla --no-readline   -q  <<'EOF'
CMDIR = Sys.getenv(c('VITO'))

setwd(CMDIR)
getwd()

load("/application/parameters/WSP.RData")
xlist <- c("raster", "sp", "zoo", "rciop", "gtools", "digest", "rgdal",
"uuid", "RColorBrewer", "colorRamps", "rasterVis", "RStoolbox")
lapply(xlist, library, character.only = TRUE)

options(max.print=99999999) 
options("scipen"=100, "digits"=4)

TPmlist01<-mixedsort(list.files(pattern=paste("NDV02_001_crop*",".*\\.tif",sep="")))
TPmlist01

for (i in 1:(length(TPmlist01))){
rb=raster(paste(CMDIR,'/',TPmlist01[[i]] ,sep = ""))
rb
capture.output(rb, file=paste(CMDIR,'/','INFONDV',i,'.txt',sep = ""), append=FALSE)
capture.output(rb, file=paste(CMDIR,'/','INFO_NDV','.txt',sep = ""), append=TRUE)
}


TPmlist01<-mixedsort(list.files(path=CMDIR, pattern="LANDC002*"))
TPmlist01

for (i in 1:(length(TPmlist01))){
rb=raster(paste(CMDIR,'/',TPmlist01[[i]] ,sep = ""))
rb
capture.output(rb, file=paste(CMDIR,'/','INFOLANDC002',i,'.txt',sep = ""), append=FALSE)
capture.output(rb, file=paste(CMDIR,'/','INFO_LANDC002','.txt',sep = ""), append=TRUE)
}

EOF

#-------------------------------------------------------------------------------------# 
h=1
for file in $VITO/NDV02_001_crop*.tif; do 
filename=$(basename $file .tif )
input001=$VITO/${filename}.tif
input002=$VITO/${filename/#NDV02_001_crop/LANDC002}.tif 
echo $input001
echo $input002
# Get the same boundary information_globcover
h=$((h+1))
Cx001=$VITO/${filename/#NDV02_001_crop_/INFONDV}.txt
Cx002=$VITO/${filename/#NDV02_001_crop_/INFOLANDC002}.txt
echo $Cx001
echo $Cx002

ulx=$(cat $Cx001  | grep "extent" | awk '{ gsub ("[(),]","") ; print  $3 }')
uly=$(cat $Cx001  | grep "extent" | awk '{ gsub ("[(),]","") ; print  $6 }')
lrx=$(cat $Cx001  | grep "extent" | awk '{ gsub ("[(),]","") ; print  $4 }')
lry=$(cat $Cx001  | grep "extent" | awk '{ gsub ("[(),]","") ; print  $5 }')

ulx1=$(cat $Cx002  | grep "extent" | awk '{ gsub ("[(),]","") ; print  $3 }')
uly1=$(cat $Cx002  | grep "extent" | awk '{ gsub ("[(),]","") ; print  $6 }')
lrx1=$(cat $Cx002  | grep "extent" | awk '{ gsub ("[(),]","") ; print  $4 }')
lry1=$(cat $Cx002  | grep "extent" | awk '{ gsub ("[(),]","") ; print  $5 }')

echo $ulx $uly $lrx $lry 
echo $ulx1 $uly1 $lrx1 $lry1 
output003=$VITO/${filename/#NDV02_001_crop/LANDC01}.tif 
echo $output003 
gdal_translate -projwin $ulx $uly $lrx $lry -of GTiff $input002 $output003
done

#-------------------------------------------------------------------------------------#
#-------------------------------------------------------------------------------------#
#-------------------------------------------------------------------------------------#
#-------------------------------------------------------------------------------------#
# JOB#005 Extrair as classes por land cover [1:11] e calc os valores de HSD and LSD
#-------------------------------------------------------------------------------------#
#reclassification

h=0
for file in $VITO/NDV02_001_crop*.tif; do 
filename=$(basename $file .tif )
input001=$VITO/${filename}.tif
input002=$VITO/${filename/#NDV02_001_crop/LANDC01}.tif 
h=$((h+1))
echo $input001 
echo $input002
#for i in {2}; do
for i in {2,3,4,5,6,7}; do
output003=$NVDIR/${filename/#NDV02_001_crop/LANDC01_1}_0$i.tif   
echo $output003
gdal_calc.py -A $input001 -B $input002 --outfile=$output003 --calc="((B==$i)*(A))" --NoDataValue=0 --overwrite --type=Float64; 
done
done

#-------------------------------------------------------------------------------------#

h=0
for file in $VITO/NDV02_001_crop*.tif; do 
filename=$(basename $file .tif )
input001=$VITO/${filename}.tif
input002=$VITO/${filename/#NDV02_001_crop/LANDC01}.tif 
h=$((h+1))
echo $input001 $input002
for i in 1; do  
output003=$NVDIR/${filename/#NDV02_001_crop/LANDC01_1}_0$i.tif  
gdal_calc.py -A $input001 -B $input002 --outfile=$output003 --calc="(B==$i)*(A*0+5000)" --NoDataValue=0 --overwrite --type=Float64; 
done
done

#-------------------------------------------------------------------------------------#
h=0
for file in $VITO/NDV02_001_crop*.tif; do 
filename=$(basename $file .tif )
input001=$VITO/${filename}.tif
input002=$VITO/${filename/#NDV02_001_crop/LANDC01}.tif 
h=$((h+1))
echo $input001 $input002
for i in {8,9}; do 
output003=$NVDIR/${filename/#NDV02_001_crop/Nr_LANDC01_1}_0$i.tif  
gdal_calc.py -A $input001 -B $input002 --outfile=$output003 --calc="(B==$i)*(A*0+10000)" --NoDataValue=0 --overwrite --type=Float64; 
done
done

#-------------------------------------------------------------------------------------#
h=0
for file in $VITO/NDV02_001_crop*.tif; do 
filename=$(basename $file .tif )
input001=$VITO/${filename}.tif
input002=$VITO/${filename/#NDV02_001_crop/LANDC01}.tif 
h=$((h+1))
echo $input001 $input002
for i in {10,11}; do
output003=$NVDIR/${filename/#NDV02_001_crop/Nr_LANDC01_1}_$i.tif    
gdal_calc.py -A $input001 -B $input002 --outfile=$output003 --calc="(B==$i)*(A*0+1)" --NoDataValue=0 --overwrite --type=Float64; 
done
done

ciop-log "INFO" "vgt_to_geoms_00100.sh"

for file in $VITO/NDV001_0*.tif; do 
rm $file
done

for file in $VITO/NDV02_001_crop*.tif; do 
rm $file
done

#-------------------------------------------------------------------------------------#
echo "DONE"
exit 0