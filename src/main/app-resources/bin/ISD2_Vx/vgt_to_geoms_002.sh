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
source ${ciop_job_include}
export PATH=/opt/anaconda/bin/:$PATH
#-------------------------------------------------------------------------------------# 
# the environment variables 
#-------------------------------------------------------------------------------------# 
# bash /application/bin/ISD5_node/ini.sh
#-------------------------------------------------------------------------------------#
# JOB000
#-------------------------------------------------------------------------------------#
export INDIR=~/data/INPUT

input006=$INDIR/VITO/PV_S10_TOC_20140901_333M_V001_ib/*NIR.tif 
input007=$INDIR/VITO/PV_S10_TOC_20140901_333M_V001_ib/*RED.tif
input002=$LAND/LANDC001.tif


z001="$(gdalinfo $input006 | grep "Pixel Size" |  awk  -F, ' {print $(NF-1)}'| awk '{ gsub ("[(),]","") ; print  $4  }')"
#-------------------------------------------------------------------------------------#
###JOB#001 resample LULC para o mesmo pixel scale do target
gdalwarp -tr $z001 $z001 -r bilinear $input002 $CDIR/input002001.tif 
#-------------------------------------------------------------------------------------#
###JOB#002 Get the same boundary information_globcover
ulx=$(gdalinfo $CDIR/input002001.tif | grep "Upper Left" | awk '{ gsub ("[(),]","") ; print  $3  }')
uly=$(gdalinfo $CDIR/input002001.tif | grep "Upper Left" | awk '{ gsub ("[(),]","") ; print  $4  }')
lrx=$(gdalinfo $CDIR/input002001.tif | grep "Lower Right" | awk '{ gsub ("[(),]","") ; print $3  }')
lry=$(gdalinfo $CDIR/input002001.tif | grep "Lower Right" | awk '{ gsub ("[(),]","") ; print $4  }')

#pkcrop -ulx $ulx -uly $uly -lrx $lrx -lry $lry -i $input006 -o $CDIR/input006002.tif
#pkcrop -ulx $ulx -uly $uly -lrx $lrx -lry $lry -i $input007 -o $CDIR/input007002.tif

gdal_translate -projwin $ulx $uly $lrx $lry -of GTiff $input006 $CDIR/input006002.tif
gdal_translate -projwin $ulx $uly $lrx $lry -of GTiff $input007 $CDIR/input007002.tif

#-------------------------------------------------------------------------------------#
# JOB#003 Extrair as class per land cover [1:11] e 
# aplicar o factor de escala imagens PROBA-V or SPOT-VGT
gdal_calc.py -A $CDIR/input006002.tif --outfile=$CDIR/input006003.tif --calc="(0.0005*A)*10000" --overwrite --NoDataValue=-1 --type=UInt32;
gdal_calc.py -A $CDIR/input007002.tif --outfile=$CDIR/input007003.tif --calc="(0.0005*A)*10000" --overwrite --NoDataValue=-1 --type=UInt32;
#-------------------------------------------------------------------------------------#
#calculo do BRIGHTNESS
gdal_calc.py -A $CDIR/input006003.tif -B $CDIR/input007003.tif --outfile=$CDIR/input008001.tif --calc="sqrt(A*A+B*B)" --overwrite --type=UInt32;
#-------------------------------------------------------------------------------------#
# calculo dos valores para a parametriza��o: HSD and LSD
#-------------------------------------------------------------------------------------#
for i in {1..11}; do 
gdal_calc.py -A $CDIR/input008001.tif -B $CDIR/input002001.tif --outfile=$SBDIR/input008001s_0$i.tif --calc="(B==$i)*(A)" --overwrite --NoDataValue=0 --type=UInt32; 
# $zLSD="$(oft-mm -um input003001_$i.tif input003001_$i.tif| grep "Band 1 min"|  awk '{ gsub ("[(),]","") ; print $5  }')"
# $zLSD="$(oft-mm -um input003001_$i.tif input003001_$i.tif| grep "Band 1 max"|  awk '{ gsub ("[(),]","") ; print $5  }')"
# echo $zLSD $zHSD >> zLSDzHSD_Sx.txt 
done
#-------------------------------------------------------------------------------------#
mv $SBDIR/input008001s_010.tif  $SBDIR/input008001s_10.tif
mv $SBDIR/input008001s_011.tif  $SBDIR/input008001s_11.tif
#-------------------------------------------------------------------------------------#
# calculo das medias por classe, normaliza��o
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
rastD5<-(rastD3-minValue(rastDi))/(maxValue(rastDi)-minValue(rastDi))
print(i)
writeRaster(rastD5, filename=paste("st0",i,"_classSOIL.tif", sep=""), format="GTiff", overwrite=TRUE)
}

EOF
#-------------------------------------------------------------------------------------#
mv $SBDIR/st010_classSOIL.tif  $SBDIR/st10_classSOIL.tif
mv $SBDIR/st011_classSOIL.tif  $SBDIR/st11_classSOIL.tif
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
list.filenames<-list.files(pattern="SOIL.tif$")

# load raster data 

rstack002<-stack(raster(list.filenames[1]),
raster(list.filenames[2]),raster(list.filenames[3]),raster(list.filenames[4]),
raster(list.filenames[5]),raster(list.filenames[6]),raster(list.filenames[7]),
raster(list.filenames[8]),raster(list.filenames[9]),raster(list.filenames[10]),raster(list.filenames[11]))

rastD7<-sum(rstack002, na.rm=TRUE)

writeRaster(rastD7, filename="Sx001.tif", format="GTiff", overwrite=TRUE)
#-------------------------------------------------------------------------------------# 
# here we publish the results
#-------------------------------------------------------------------------------------# 
# Sx001 <- rciop.publish(rastD7, recursive=FALSE, metalink=TRUE)

EOF
echo "DONE"
#exit 0
#-------------------------------------------------------------------------------------#