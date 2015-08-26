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
source ${ciop_job_include}
#-------------------------------------------------------------------------------------# 
# the environment variables 
#-------------------------------------------------------------------------------------# 
# # bash /application/bin/ISD5_node/ini.sh
DIR= ~/data/
INDIR=~/data/INPUT
# RECLASS=$INDIR/${LANDCOVER}/${IOA}/*reclassify.tif
# VITO=$INDIR/${VITO}/${RES}
export PATH=/opt/anaconda/bin/:$PATH
# #-------------------------------------------------------------------------------------#
# #input 1: NDVI
# input001=${VITO}/*_NDVI.tif
# #-------------------------------------------------------------------------------------#
# #input2: Land Cover
# input002=$RECLASS

#input 1: NDVI
input001=$INDIR/VITO/PV_S10_TOC_20140901_333M_V001_ib/*_NDVI.tif

#input2: Land Cover
input002=$LAND/LANDC001.tif

#-------------------------------------------------------------------------------------#
z001="$(gdalinfo $input001 | grep "Pixel Size" |  awk  -F, ' {print $(NF-1)}'| awk '{ gsub ("[(),]","") ; print  $4  }')"
#-------------------------------------------------------------------------------------#
# JOB#003 resample LULC para o mesmo pixel scale do target
gdalwarp -tr $z001 $z001 -r bilinear $input002 $VDIR/input002001.tif
#-------------------------------------------------------------------------------------#
# JOB#004 Get the same boundary information...crop
ulx=$(gdalinfo $VDIR/input002001.tif | grep "Upper Left" | awk '{ gsub ("[(),]","") ; print  $3  }')
uly=$(gdalinfo $VDIR/input002001.tif | grep "Upper Left" | awk '{ gsub ("[(),]","") ; print  $4  }')
lrx=$(gdalinfo $VDIR/input002001.tif | grep "Lower Right" | awk '{ gsub ("[(),]","") ; print $3  }')
lry=$(gdalinfo $VDIR/input002001.tif | grep "Lower Right" | awk '{ gsub ("[(),]","") ; print $4  }')

export PATH=/opt/anaconda/bin/:$PATH
gdal_calc.py -A $input001 --outfile=$VDIR/input001000i.tif --calc="(((A*0.004)-0.08)*10000.0)" --overwrite --NoDataValue=255 --type=UInt32; 
#pkcrop -ulx $ulx -uly $uly -lrx $lrx -lry $lry -i $VDIR/input001000i.tif -o $VDIR/input001002.tif
#gdalwarp -te <x_min> <y_min> <x_max> <y_max> $VDIR/input001000i.tif -o $VDIR/input001002.tif

gdal_translate -projwin $ulx $uly $lrx $lry -of GTiff $VDIR/input001000i.tif $VDIR/input001002.tif
#-------------------------------------------------------------------------------------#
# JOB#005 Extrair as classes por land cover [1:11] e calc os valores de HSD and LSD
#-------------------------------------------------------------------------------------#
for i in {1..11}; do  
gdal_calc.py -A $VDIR/input001002.tif -B $VDIR/input002001.tif --outfile=$NVDIR/input003001_0$i.tif --calc="(B==$i)*(A)" --overwrite --NoDataValue=0 --type=UInt32; 
#zLSD="$(oft-mm -um $VDIR/class_temp/input003001_$i.tif $VDIR/class_temp/input003001_$i.tif| grep "Band 1 min"|  awk '{ gsub ("[(),]","") ; print $5  }')"
echo $i
done
#-------------------------------------------------------------------------------------#
mv $NVDIR/input003001_010.tif  $NVDIR/input003001_10.tif
mv $NVDIR/input003001_011.tif  $NVDIR/input003001_11.tif
#-------------------------------------------------------------------------------------#
# calculo das medias das classes, normalização 
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
    
# list all files from the current directory
list.files(pattern=".tif$") 
 
# create a list from these files
list.filenames<-list.files(pattern=".tif$")

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
writeRaster(rastD5, filename=paste("st0",i,"_classNDV.tif", sep=""), format="GTiff", overwrite=TRUE)
}

EOF
#-------------------------------------------------------------------------------------#
mv  $NVDIR/st010_classNDV.tif  $NVDIR/st10_classNDV.tif
mv  $NVDIR/st011_classNDV.tif  $NVDIR/st11_classNDV.tif
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
list.filenames<-list.files(pattern="classNDV.tif$")

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

writeRaster(rastD6, filename="Vx001.tif", format="GTiff", overwrite=TRUE, na.rm=TRUE)
#-------------------------------------------------------------------------------------# 
# here we publish the results
#-------------------------------------------------------------------------------------# 
# Vx001 <- rciop.publish(rastD6, recursive=FALSE, metalink=TRUE)
EOF

today=$(date)
echo "The date and time are: " $today
#-------------------------------------------------------------------------------------# 
echo "DONE"