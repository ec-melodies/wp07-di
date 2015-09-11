#!/bin/sh
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
#export PATH=/opt/anaconda/bin/:$PATH
#-------------------------------------------------------------------------------------# 
# the environment variables 
#-------------------------------------------------------------------------------------# 
# bash /application/bin/ISD5_node/ini.sh
#-------------------------------------------------------------------------------------#
# JOB000
#-------------------------------------------------------------------------------------#
export PATH=/opt/anaconda/bin/:$PATH
export -p DIR=~/data/ISD/
export -p INDIR=$DIR/INPUT

export -p OUTDIR=$DIR/ISD000
export -p LAND001=$OUTDIR/SPPV001/AOI1/SX

export -p VDIR=$OUTDIR/VM001
export -p CDIR=$OUTDIR/SM001
export -p SBDIR=$OUTDIR/SM001/class_SOIL001/

#-------------------------------------------------------------------------------------#
input006=$INDIR/NIR.tif 
input007=$INDIR/RED.tif
input002=$LAND001/LULC.tif

#-------------------------------------------------------------------------------------#
# JOB# resample LULC para o mesmo pixel scale do target (SPOT or PROBA-V)
#-------------------------------------------------------------------------------------#

for file in $LAND001/LANDC0*.tif; do 
filename=$(basename $file .tif ) 
echo $filename
input001=$LAND001/*01_NIR.tif
input002=$LAND001/${filename}.tif
z001="$(gdalinfo $input001 | grep "Pixel Size" |  awk  -F, ' {print $(NF-1)}'| awk '{ gsub ("[(),]","") ; print  $4  }')"
gdalwarp -tr $z001 $z001 -r bilinear $input002 $LAND001/${filename}_LULC_001.tif
done

#-------------------------------------------------------------------------------------#
###JOB#002 Get the same boundary information_globcover
#ulx=$(gdalinfo $CDIR/input002001.tif | grep "Upper Left" | awk '{ gsub ("[(),]","") ; print  $3  }')
#uly=$(gdalinfo $CDIR/input002001.tif | grep "Upper Left" | awk '{ gsub ("[(),]","") ; print  $4  }')
#lrx=$(gdalinfo $CDIR/input002001.tif | grep "Lower Right" | awk '{ gsub ("[(),]","") ; print $3  }')
#lry=$(gdalinfo $CDIR/input002001.tif | grep "Lower Right" | awk '{ gsub ("[(),]","") ; print $4  }')

#pkcrop -ulx $ulx -uly $uly -lrx $lrx -lry $lry -i $input006 -o $CDIR/input006002.tif
#pkcrop -ulx $ulx -uly $uly -lrx $lrx -lry $lry -i $input007 -o $CDIR/input007002.tif

#gdal_translate -projwin $ulx $uly $lrx $lry -of GTiff $input006 $CDIR/input006002.tif
#gdal_translate -projwin $ulx $uly $lrx $lry -of GTiff $input007 $CDIR/input007002.tif

#-------------------------------------------------------------------------------------#
# JOB#003 Extrair as class per land cover [1:11] e 
# aplicar o factor de escala imagens PROBA-V or SPOT-VGT
# r.factor: PhyVal = DN / ScalingFactor + Offset, Offset=-0.08, Scaling factor=250 (NDVI)
# R = 0.0005 * DN (SPOT-VGT) (others)
# R = 0.0005 * DN (Proba-v) (others)
#-------------------------------------------------------------------------------------#
for file in $LAND001/*NIR.tif; do 
filename=$(basename $file .tif ) 
echo $filename
gdal_calc.py -A $LAND001/${filename}.tif  --outfile=$LAND001/${filename}_001.tif --calc="(0.0005*A)*10000" --overwrite --NoDataValue=-1 --type=UInt32;
done 

for file in $LAND001/*RED.tif; do 
filename=$(basename $file .tif ) 
echo $filename
gdal_calc.py -A $LAND001/${filename}.tif f --outfile=$LAND001/${filename}_001.tif --calc="(0.0005*A)*10000" --overwrite --NoDataValue=-1 --type=UInt32;
done

#-------------------------------------------------------------------------------------#
#calculo do BRIGHTNESS

for file in $LAND001/AOI1_crop*NIR_001.tif; do
filename01=$(basename $file .tif)
j=${filename01/%NIR_001/RED_001}  
for file2 in $j; do
filename02=$(basename $file2 .tif )
done;
echo $filename01 $filename02
gdal_calc.py -A $LAND001/${filename01}.tif -B $LAND001/${filename02}.tif --outfile=$LAND001/${filename02}_Bx.tif --calc="sqrt(A*A+B*B)" --overwrite --type=UInt32;
done

#-------------------------------------------------------------------------------------#
# calculo dos valores para a parametrização: HSD and LSD
#-------------------------------------------------------------------------------------#
for file in $LAND001/*Bx.tif; do
filename01=$(basename $file .tif)
f=${filename01/#AOI1_crop_0/LANDC001}  
j=${f/%_RED_001_Bx/_LULC_001 }
for file2 in $j; do
filename02=$(basename $file2 .tif )
done;
echo $filename01 $filename02

for i in {1..11}; do 
gdal_calc.py -A $LAND001/${filename01}.tif f -B $LAND001/${filename02}.tif  --outfile=$SBDIR/${filename02}_0$i.tif --calc="(B==$i)*(A)" --overwrite --NoDataValue=0 --type=UInt32; 
# $zLSD="$(oft-mm -um input003001_$i.tif input003001_$i.tif| grep "Band 1 min"|  awk '{ gsub ("[(),]","") ; print $5  }')"
# $zLSD="$(oft-mm -um input003001_$i.tif input003001_$i.tif| grep "Band 1 max"|  awk '{ gsub ("[(),]","") ; print $5  }')"
# echo $zLSD $zHSD >> zLSDzHSD_Sx.txt 
done;

mv $SBDIR/${filename02}_010.tif $SBDIR/${filename02}_10.tif
mv $SBDIR/${filename02}_011.tif $SBDIR/${filename02}_11.tif

done

#-------------------------------------------------------------------------------------#
#-------------------------------------------------------------------------------------#
# calculo das medias por classe, normalização
#-------------------------------------------------------------------------------------#
R --vanilla --no-readline   -q  <<'EOF'

#R version  3.2.1
# set working directory
INDIR = Sys.getenv(c('SBDIR'))
OUTDIR = Sys.getenv(c('SBDIR'))

setwd(INDIR)

require(sp)
require(rgdal)
require(raster)
require(rciop)    


# list all files from the current directory
list.files(pattern=".tif$") 
 
# create a list from these files
for (j in 1:4){ 
print(j)
ww=assign(paste("list.filenames_",j,sep=""),list.files(pattern=paste("LANDC001",j,".*\\.tif",sep="")))
}


for (j in 1:4){ 

list.filenames=assign(paste("list.filenames_",j,sep=""),list.files(pattern=paste("LANDC001",j,".*\\.tif",sep="")))
# create a loop to read in your data
for (i in 1:length(list.filenames))
{
# load raster data 
rastD = raster(list.filenames[i])
rastDi = raster(list.filenames[i])
# calculate Mean
rastD[rastD <= 0] = -9999
rastDi[rastDi <= 0] = -9999
rastD3<-((rastD>-9999)*(rastD[]=(cellStats(brick(rastD), mean))))
rastD5<-(maxValue(rastDi)-rastD3)/(maxValue(rastDi)-minValue(rastDi))
print(i)
writeRaster(rastD5, filename=paste("st0",i,"_classSOIL_crop_0",j,".tif", sep=""), format="GTiff", overwrite=TRUE)
}}


EOF
#-------------------------------------------------------------------------------------#
for i in {1..4}; do  
mv  $SBDIR/st010_classSOIL_crop_0$i.tif  $SBDIR/st10_classSOIL_crop_0$i.tif
mv  $SBDIR/st011_classSOIL_crop_0$i.tif  $SBDIR/st11_classSOIL_crop_0$i.tif
done

#-------------------------------------------------------------------------------------#
R --vanilla --no-readline   -q  <<'EOF'
INDIR = Sys.getenv(c('SBDIR'))
OUTDIR = Sys.getenv(c('SBDIR'))

setwd(INDIR)

require(sp)
require(rgdal)
require(raster)
require(rciop)


# list all files from the current directory
list.files(pattern=".tif$") 
 
# create a list from these files
for (j in 1:4){ 
print(j)
list.filenames=assign(paste("list.filenames_",j,sep=""),list.files(pattern=paste("_classSOIL_crop_0",j,".*\\.tif",sep="")))
# load raster data 

rstack002<-stack(raster(list.filenames[1]),
raster(list.filenames[2]),raster(list.filenames[3]),raster(list.filenames[4]),
raster(list.filenames[5]),raster(list.filenames[6]),raster(list.filenames[7]),
raster(list.filenames[8]),raster(list.filenames[9]),raster(list.filenames[10]),raster(list.filenames[11]))

rastD7<-sum(rstack002, na.rm=TRUE)

writeRaster(rastD7, filename=paste("Sx001_",j,"_crop.tif", sep=""), format="GTiff", overwrite=TRUE, na.rm=TRUE)
}

EOF
#-------------------------------------------------------------------------------------# 
# here we publish the results
#-------------------------------------------------------------------------------------# 
# Sx001 <- rciop.publish(rastD7, recursive=FALSE, metalink=TRUE)


echo "DONE"
#exit 0
#-------------------------------------------------------------------------------------#