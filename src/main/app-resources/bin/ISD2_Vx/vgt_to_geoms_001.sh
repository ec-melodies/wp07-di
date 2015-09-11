#!/bin/sh
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
# source ${ciop_job_include}
#-------------------------------------------------------------------------------------# 
# the environment variables 
#-------------------------------------------------------------------------------------# 
# # bash /application/bin/ISD5_node/ini.sh
# RECLASS=$INDIR/${LANDCOVER}/${IOA}/*reclassify.tif
# VITO=$INDIR/${VITO}/${RES}

export PATH=/opt/anaconda/bin/:$PATH
export -p DIR=~/data/ISD/
export -p INDIR=$DIR/INPUT

export -p OUTDIR=$DIR/ISD000
export -p LAND001=$OUTDIR/SPPV001/AOI1/VX

export -p VDIR=$OUTDIR/VM001
export -p NVDIR=$OUTDIR/VM001/class_NDV001/

export PATH=/opt/anaconda/bin/:$PATH
# #-------------------------------------------------------------------------------------#
# #input 1: NDVI 
# input001=${VITO}/*_NDVI.tif
# #-------------------------------------------------------------------------------------#
# #input2: Land Cover
# input002=$RECLASS

#input 1: NDVI
input001=$INDIR/NDV.tif

#input2: Land Cover
input002=$LAND001/LULC.tif


#-------------------------------------------------------------------------------------#
# JOB# resample LULC para o mesmo pixel scale do target (SPOT or PROBA-V)
#-------------------------------------------------------------------------------------#
#
for file in $LAND001/LANDC0*.tif; do 
filename=$(basename $file .tif ) 
echo $filename
input001=$LAND001/*01_NDV.tif
input002=$LAND001/${filename}.tif
z001="$(gdalinfo $input001 | grep "Pixel Size" |  awk  -F, ' {print $(NF-1)}'| awk '{ gsub ("[(),]","") ; print  $4  }')"
gdalwarp -tr $z001 $z001 -r bilinear $input002 $LAND001/${filename}_001.tif
done

#-------------------------------------------------------------------------------------#
# JOB#004 Get the same boundary information...crop
#ulx=$(gdalinfo $VDIR/input002001.tif | grep "Upper Left" | awk '{ gsub ("[(),]","") ; print  $3  }')
#uly=$(gdalinfo $VDIR/input002001.tif | grep "Upper Left" | awk '{ gsub ("[(),]","") ; print  $4  }')
#lrx=$(gdalinfo $VDIR/input002001.tif | grep "Lower Right" | awk '{ gsub ("[(),]","") ; print $3  }')
#lry=$(gdalinfo $VDIR/input002001.tif | grep "Lower Right" | awk '{ gsub ("[(),]","") ; print $4  }')

#-------------------------------------------------------------------------------------#
# r.factor: PhyVal = DN / ScalingFactor + Offset, Offset=-0.08, Scaling factor=250 
#-------------------------------------------------------------------------------------#

for file in $LAND001/*NDV.tif; do 
filename=$(basename $file .tif ) 
echo $filename
gdal_calc.py -A $LAND001/${filename}.tif --outfile=$LAND001/${filename}_001.tif --calc="(((A*0.004)-0.08)*10000.0)" --overwrite --NoDataValue=255 --type=UInt32; 
done

#pkcrop -ulx $ulx -uly $uly -lrx $lrx -lry $lry -i $VDIR/input001000i.tif -o $VDIR/input001002.tif
#gdalwarp -te <x_min> <y_min> <x_max> <y_max> $VDIR/input001000i.tif -o $VDIR/input001002.tif
#gdal_translate -projwin $ulx $uly $lrx $lry -of GTiff $VDIR/input001000i.tif $VDIR/input001002.tif
#-------------------------------------------------------------------------------------#
# JOB#005 Extrair as classes por land cover [1:11] e calc os valores de HSD and LSD
#-------------------------------------------------------------------------------------#
for file in $LAND001/*NDV_001.tif; do
filename01=$(basename $file .tif)
f=${filename01/#AOI1_crop_0/LANDC001}  
j=${f/%_NDV_001/_001}
for file2 in $j; do
filename02=$(basename $file2 .tif )
done;
echo $filename01 $filename02
for i in {1..11}; do  
gdal_calc.py -A $LAND001/${filename01}.tif -B $LAND001/${filename02}.tif --outfile=$NVDIR/${filename02}_0$i.tif --calc="(B==$i)*(A)" --overwrite --NoDataValue=0 --type=UInt32; 
#zLSD="$(oft-mm -um $VDIR/class_temp/input003001_$i.tif $VDIR/class_temp/input003001_$i.tif| grep "Band 1 min"|  awk '{ gsub ("[(),]","") ; print $5  }')"
done;
#gdalinfo $LAND001/${filename01}.tif
#gdalinfo $LAND001/${filename02}.tif
mv $NVDIR/${filename02}_010.tif $NVDIR/${filename02}_10.tif
mv $NVDIR/${filename02}_011.tif $NVDIR/${filename02}_11.tif
done
#-------------------------------------------------------------------------------------#
# calculo das medias das classes, normalização 

export -p NVDIR=$OUTDIR/VM001/class_NDV001/
export -p VDIR=$OUTDIR/VM001
#-------------------------------------------------------------------------------------#
R --vanilla --no-readline   -q  <<'EOF'

#R version  3.2.1
# set working directory
INDIR = Sys.getenv(c('NVDIR'))
OUTDIR = Sys.getenv(c('VDIR'))

setwd(INDIR)

require("zoo")
require("rgdal")
require("raster")
require("sp")
require("rciop")

setwd(INDIR)
getwd()
    
# list all files from the current directory
list.files(pattern=".tif$") 
 
# create a list from these files
for (j in 1:4){ 
print(j)
ww=assign(paste("list.filenames_",j,sep=""),list.files(pattern=paste("LANDC001_",j,".*\\.tif",sep="")))
}

for (j in 1:4){ 

list.filenames=assign(paste("list.filenames_",j,sep=""),list.files(pattern=paste("LANDC001_",j,".*\\.tif",sep="")))
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
writeRaster(rastD5, filename=paste("st0",i,"_classNDV_crop_0",j,".tif", sep=""), format="GTiff", overwrite=TRUE)
}}

EOF
#-------------------------------------------------------------------------------------#
for i in {1..4}; do  
mv  $NVDIR/st010_classNDV_crop_0$i.tif  $NVDIR/st10_classNDV_crop_0$i.tif
mv  $NVDIR/st011_classNDV_crop_0$i.tif  $NVDIR/st11_classNDV_crop_0$i.tif
done
#-------------------------------------------------------------------------------------#
R --vanilla --no-readline   -q  <<'EOF'

# set working directory
INDIR = Sys.getenv(c('NVDIR'))
VDIR = Sys.getenv(c('VDIR'))
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
list.filenames=assign(paste("list.filenames_",j,sep=""),list.files(pattern=paste("_classNDV_crop_0",j,".*\\.tif",sep="")))
# load raster data 
rstack001<-stack(raster(list.filenames[1]),
raster(list.filenames[2]),
raster(list.filenames[3]),
raster(list.filenames[4]),
raster(list.filenames[5]),
raster(list.filenames[6]),
raster(list.filenames[7]),
raster(list.filenames[8]),
raster(list.filenames[9]),
raster(list.filenames[10]),
raster(list.filenames[11]))
rastD6<-sum(rstack001, na.rm=TRUE)

writeRaster(rastD6, filename=paste("Vx001_",j,"_crop.tif", sep=""), format="GTiff", overwrite=TRUE, na.rm=TRUE)
}

#-------------------------------------------------------------------------------------# 
# here we publish the results
#-------------------------------------------------------------------------------------# 
# Vx001 <- rciop.publish(rastD6, recursive=FALSE, metalink=TRUE)
EOF

today=$(date)
echo "The date and time are: " $today
#-------------------------------------------------------------------------------------# 
echo "DONE"