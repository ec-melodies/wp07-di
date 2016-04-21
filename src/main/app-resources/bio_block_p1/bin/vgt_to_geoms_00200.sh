#!/bin/bash
#-------------------------------------------------------------------------------------# 
# PURPOSE: Local soil status [S(x)]
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
#source ${ciop_job_include}
export PATH=/opt/anaconda/bin/:$PATH
#-------------------------------------------------------------------------------------# 
# the environment variables 
#-------------------------------------------------------------------------------------#
# JOB000
#-------------------------------------------------------------------------------------#
export PATH=/opt/anaconda/bin/:$PATH
export -p DIR=/data/outDIR/ISD
export -p INDIR=$DIR/INPUT
export -p OUTDIR=$DIR/ISD000
export -p VITO=$OUTDIR/VITO
export -p CDIR=$OUTDIR/SM001
export -p SBDIR=$CDIR/class_SOIL001
#-------------------------------------------------------------------------------------#
#-------------------------------------------------------------------------------------#
# JOB# resample LULC para o mesmo pixel scale do target (SPOT or PROBA-V)
#-------------------------------------------------------------------------------------#

for file in $VITO/NIR001_01_crop_*.tif; do 
filename=$(basename $file .tif )
input001=$VITO/${filename}.tif
input002=$VITO/${filename/#NIR001_01_crop/LANDC002}.tif 
output003=$VITO/${filename/#NIR001_01_crop/NIR001_02_crop}.tif 
echo $input001 $input002 $output003
z001="$(gdalinfo $input002 | grep "Pixel Size" |  awk  -F, ' {print $(NF-1)}'| awk '{ gsub ("[(),]","") ; print  $4  }')"
gdalwarp -tr $z001 $z001 -r bilinear -overwrite $input001 $output003
done

for file in $VITO/RED001_01_crop_*.tif; do 
filename=$(basename $file .tif )
input001=$VITO/${filename}.tif
input002=$VITO/${filename/#RED001_01_crop/LANDC002}.tif 
output003=$VITO/${filename/#RED001_01_crop/RED001_02_crop}.tif 
echo $input001 $input002 $output003
z001="$(gdalinfo $input002 | grep "Pixel Size" |  awk  -F, ' {print $(NF-1)}'| awk '{ gsub ("[(),]","") ; print  $4  }')"
gdalwarp -tr $z001 $z001 -r bilinear -overwrite $input001 $output003
done

#-------------------------------------------------------------------------------------#
# JOB#003 Extrair as class per land cover [1:11] e 
# aplicar o factor de escala imagens PROBA-V or SPOT-VGT
# r.factor: PhyVal = DN / ScalingFactor + Offset, Offset=-0.08, Scaling factor=250 (NDVI)
# R = 0.0005 * DN (SPOT-VGT) (others)
# R = 0.0005 * DN (Proba-v) (others)
#-------------------------------------------------------------------------------------#

for file in $VITO/RED001_02_crop*.tif; do 
filename=$(basename $file .tif )
input001=$VITO/${filename}.tif
output003=$SBDIR/${filename/#RED001_02_crop/RED02_001_crop}.tif 
gdal_calc.py -A $input001 --outfile=$output003 --calc="(0.0005*A)*10000" --overwrite --NoDataValue=-1 --type=Float64
done

for file in $VITO/NIR001_02_crop*.tif; do 
filename=$(basename $file .tif )
input001=$VITO/${filename}.tif
output003=$SBDIR/${filename/#NIR001_02_crop/NIR02_001_crop}.tif 
gdal_calc.py -A $input001 --outfile=$output003 --calc="(0.0005*A)*10000" --overwrite --NoDataValue=-1 --type=Float64
done

#-------------------------------------------------------------------------------------#
# BRIGHTNESS
for file in $SBDIR/NIR02_001_crop*.tif; do 
filename=$(basename $file .tif )
input001=$SBDIR/${filename}.tif
input002=$SBDIR/${filename/#NIR02_001_crop/RED02_001_crop}.tif 
output003=$SBDIR/${filename/#NIR02_001_crop/NIRRED_Bx}.tif 
echo $input001 $input002 $output003
gdal_calc.py -A $input001 -B $input002 --outfile=$output003 --calc="sqrt((A*A+B*B)/2)" --NoDataValue=-1 --overwrite --type=Float64
done
#-------------------------------------------------------------------------------------#

R --vanilla --no-readline   -q  <<'EOF'
SBDIR = Sys.getenv(c('SBDIR'))
CMDIR = Sys.getenv(c('VITO'))
setwd(SBDIR)
getwd()

xlist <- c("raster", "sp", "zoo", "rciop", "gtools", "digest", "rgdal")
new.packages <- xlist[!(xlist %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages)

lapply(xlist, require, character.only = TRUE)


options(max.print=99999999) 
options("scipen"=100, "digits"=4)

TPmlist01<-mixedsort(list.files(pattern=paste("NIRRED_Bx*",".*\\.tif",sep="")))
TPmlist01

for (i in 1:(length(TPmlist01))){
rb=raster(paste(SBDIR,'/',TPmlist01[[i]] ,sep = ""))
rb
capture.output(rb, file=paste(SBDIR,'/','INFONIRRED_Bx',i,'.txt',sep = ""), append=FALSE)
capture.output(rb, file=paste(SBDIR,'/','INFO_NIRRED_Bx','.txt',sep = ""), append=TRUE)
}


setwd(CMDIR)
TPmlist01<-mixedsort(list.files(pattern=paste("LANDC002_*",".*\\.tif",sep="")))
TPmlist01

for (i in 1:(length(TPmlist01))){
rb=raster(paste(CMDIR,'/',TPmlist01[[i]] ,sep = ""))
rb
capture.output(rb, file=paste(SBDIR,'/','INFOLANDC002S',i,'.txt',sep = ""), append=FALSE)
capture.output(rb, file=paste(SBDIR,'/','INFO_LANDC002S','.txt',sep = ""), append=TRUE)
}

EOF

#-------------------------------------------------------------------------------------#
h=1
for file in $SBDIR/NIRRED_Bx*.tif; do 
filename=$(basename $file .tif )
input001=$SBDIR/${filename}.tif
input002=$VITO/${filename/#NIRRED_Bx/LANDC001}.tif 
echo $input001
echo $input002
# Get the same boundary information_globcover
h=$((h+1))
Cx001=$SBDIR/${filename/#NIRRED_Bx_/INFONIRRED_Bx}.txt
Cx002=$SBDIR/${filename/#NIRRED_Bx_/INFOLANDC002S}.txt
echo $Cx001
echo $Cx002

ulx=$(cat $Cx001  | grep "extent" | awk '{ gsub ("[(),]","") ; print  $3 }')
uly=$(cat $Cx001  | grep "extent" | awk '{ gsub ("[(),]","") ; print  $6 }')
lrx=$(cat $Cx001  | grep "extent" | awk '{ gsub ("[(),]","") ; print  $4 }')
lry=$(cat $Cx001  | grep "extent" | awk '{ gsub ("[(),]","") ; print  $5 }')

echo $ulx $uly $lrx $lry 

output003=$VITO/${filename/#NIRRED_Bx/LANDC01}.tif 
echo $output003 
gdal_translate -projwin $ulx $uly $lrx $lry -of GTiff $input002 $output003
done

#-------------------------------------------------------------------------------------#
#-------------------------------------------------------------------------------------#
# calculo dos valores para a parametrização: HSD and LSD
#-------------------------------------------------------------------------------------#
#reclassification

h=0
for file in $SBDIR/NIRRED_Bx*.tif; do 
filename=$(basename $file .tif )
input001=$SBDIR/${filename}.tif
input002=$VITO/${filename/#NIRRED_Bx/LANDC01}.tif 
h=$((h+1))
echo $input001 $input002
for i in {2,3,4,5,6,7}; do
output003=$SBDIR/${filename/#NIRRED_Bx/LANDC01_1}_0$i.tif   
echo $output003
gdal_calc.py -A $input001 -B $input002 --outfile=$output003 --calc="(B==$i)*(A)" --NoDataValue=0 --overwrite --type=Float64;
done
done

h=0
for file in $SBDIR/NIRRED_Bx*.tif; do 
filename=$(basename $file .tif )
input001=$SBDIR/${filename}.tif
input002=$VITO/${filename/#NIRRED_Bx/LANDC01}.tif 
h=$((h+1))
echo $input001 $input002
for i in 1; do  
output003=$SBDIR/${filename/#NIRRED_Bx/LANDC01_1}_0$i.tif   
echo $output003
gdal_calc.py -A $input001 -B $input002 --outfile=$output003  --calc="(B==$i)*(A*0+5000)" --NoDataValue=0 --overwrite --type=Float64; 
done
done

h=0
for file in $SBDIR/NIRRED_Bx*.tif; do 
filename=$(basename $file .tif )
input001=$SBDIR/${filename}.tif
input002=$VITO/${filename/#NIRRED_Bx/LANDC01}.tif 
h=$((h+1))
echo $input001 $input002
for i in {8,9}; do
output003=$SBDIR/${filename/#NIRRED_Bx/Sr_LANDC01_1}_0$i.tif   
echo $output003 
gdal_calc.py -A $input001 -B $input002 --outfile=$output003 --calc="(B==$i)*(A*0+10000)" --NoDataValue=0 --overwrite --type=Float64; 
done
done

h=0
for file in $SBDIR/NIRRED_Bx*.tif; do 
filename=$(basename $file .tif )
input001=$SBDIR/${filename}.tif
input002=$VITO/${filename/#NIRRED_Bx/LANDC01}.tif 
h=$((h+1))
echo $input001 $input002
for i in {10,11}; do  
output003=$SBDIR/${filename/#NIRRED_Bx/Sr_LANDC01_1}_$i.tif   
echo $output003 
gdal_calc.py -A $input001 -B $input002 --outfile=$output003  --calc="(B==$i)*(A*0+1)" --NoDataValue=0 --overwrite --type=Float64; 
done
done

ciop-log "INFO" "vgt_to_geoms_00200.sh"
#-------------------------------------------------------------------------------------#
#-------------------------------------------------------------------------------------#
echo "DONE"
exit 0