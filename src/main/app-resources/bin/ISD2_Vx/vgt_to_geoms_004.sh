#!/bin/sh
#-------------------------------------------------------------------------------------# 
# PURPOSE: cor [B(x)]
#-------------------------------------------------------------------------------------# 
# Requires:
# gdalinfo
# gdal_calc
# pktools
# gdal_translate 
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
bash /application/bin/ISD5_node/ini.sh
# export -p SBDIR=$OUTDIR/SM001/class_SOIL001/
# export -p HDIR=/application/bin/ISD5_node/
# export -p CDIR=$OUTDIR/SM001
# export -p PDIR=$OUTDIR/PM001
# export -p CMDIR=$OUTDIR/CM001

export PATH=/opt/anaconda/bin/:$PATH
#-------------------------------------------------------------------------------------#
# => For Discriminant classes 0.8:
for i in {2,3,4,5,6,7}; do 
gdal_calc.py -A $SBDIR/Sx001.tif -B $CDIR/input002001.tif --outfile=$PDIR/CR001_0$i.tif --calc="(B==$i)*(A*0+8000)" --overwrite  --NoDataValue=0 --type=UInt32;
done
# => For Non-Discriminant classes 0.5:
for i in {1,8,9,10,11}; do 
gdal_calc.py -A $SBDIR/Sx001.tif -B $CDIR/input002001.tif --outfile=$PDIR/CR001_0$i.tif --calc="(B==$i)*(A*0+5000)" --overwrite  --NoDataValue=0 --type=UInt32;
done
#-------------------------------------------------------------------------------------#
mv $PDIR/CR001_010.tif  $PDIR/CR001_10.tif
mv $PDIR/CR001_011.tif  $PDIR/CR001_11.tif
export -p PDIR=$OUTDIR/PM001
#-------------------------------------------------------------------------------------#
R --vanilla --no-readline   -q  <<'EOF'

INDIR = Sys.getenv(c('PDIR'))
OUTDIR = Sys.getenv(c('PDIR'))
setwd(OUTDIR)

require(sp)
require(rgdal)
require(raster)
    
# list all files from the current directory
list.files(pattern=".tif$") 
 
# create a list from these files
list.filenames<-list.files(pattern=".tif$")

# load raster data 

rstack003<-stack(raster(list.filenames[1]),
raster(list.filenames[2]), raster(list.filenames[3]), raster(list.filenames[4]),
raster(list.filenames[5]), raster(list.filenames[6]), raster(list.filenames[7]),
raster(list.filenames[8]), raster(list.filenames[9]), raster(list.filenames[10]),
raster(list.filenames[11]))

rastD6<-sum(rstack003, na.rm=TRUE)
writeRaster(rastD6, filename="CR001.tif", format="GTiff", overwrite=TRUE)

EOF
#-------------------------------------------------------------------------------------#
##gdalwarp -tr $z001 $z001 -r bilinear $PDIR/Bx003.tif $PDIR/Bx003b.tif
#-------------------------------------------------------------------------------------#
# Sample
#-------------------------------------------------------------------------------------#
ulx=$(gdalinfo $CMDIR/Dx001.tif | grep "Upper Left" | awk '{ gsub ("[(),]","") ; print  $3  }')
uly=$(gdalinfo $CMDIR/Dx001.tif | grep "Upper Left" | awk '{ gsub ("[(),]","") ; print  $4  }')
lrx=$(gdalinfo $CMDIR/Dx001.tif | grep "Lower Right" | awk '{ gsub ("[(),]","") ; print $3  }')
lry=$(gdalinfo $CMDIR/Dx001.tif | grep "Lower Right" | awk '{ gsub ("[(),]","") ; print $4  }')

gdal_translate -projwin $ulx $uly $lrx $lry -of GTiff $PDIR/CR001.tif $PDIR/CR001rc.tif
# pkcrop -ulx $ulx -uly $uly -lrx $lrx -lry $lry -i $PDIR/CR001.tif -o $PDIR/CR001rc.tif
#-------------------------------------------------------------------------------------#
# ASCII to geoMS (.OUT or .dat)
#-------------------------------------------------------------------------------------#
gdal_translate  -of AAIGrid  $PDIR/CR001rc.tif   $PDIR/CR001.asc 
awk '$1 ~ /^[0-9]/' $PDIR/CR001.asc > $PDIR/CR001.txt
gdalinfo $PDIR/CR001.asc > $PDIR/ReadMeCR001.txt
#-------------------------------------------------------------------------------------#
R --vanilla --no-readline   -q  <<'EOF'

INDIR = Sys.getenv(c('PDIR'))
OUTDIR = Sys.getenv(c('PDIR'))
setwd(INDIR)

## load the package
require("zoo")
require("rgdal")
require("raster")
require("sp")

options(max.print=99999999) 
options("scipen"=100, "digits"=4)

dt<-paste(path=OUTDIR,'/',pattern="CR001.txt",sep ="")

#-------------------------------------------------------------------------------------#
file003<-read.table(dt)
#sdf <- stack(file003)
#sdf10<-sdf$values
#sdf01<-sdf$values/10000

file004<-as.data.frame(t(file003))
sdf003<-stack(file004)
sdf10003<-sdf003$values
sdf01003<-sdf003$values/10000

# create a list from these files
list.filename<-list.files(pattern="rc.tif")
file<-readGDAL(list.filename)
xy_sa=geometry(file)
xy<-data.frame(xy_sa)
z<- rep(0,dim(xy)[1])

#sdf10110003 <-cbind(xy, sdf10003)
#sdf01110003 <-cbind(xy, sdf01003)

#sdf10111003 <-cbind(xy,z,sdf10003)
sdf01111003 <-cbind(xy,z,sdf01003)

#sem coordenadas
#int
#write.table(sdf1011003[,c(3:3)],paste(path=OUTDIR,'/' ,'CRx1000003.dat',sep = ""),  row.names = FALSE, col.names = FALSE)
#float
write.table(sdf01111003[,c(3:3)],paste(path=OUTDIR,'/' ,'CRx0100003b.dat',sep = ""),  row.names = FALSE, col.names = FALSE)

EOF

#-------------------------------------------------------------------------------------#
HDIR=~/data/scripts_teste/
export HDIR
awk 'NR > 1 { print $3 }' $HDIR/header.txt > $PDIR/CRx0100004b.dat
cat $PDIR/CRx0100003b.dat >> $PDIR/CRx0100004b.dat

#sed -i -e 's/^/ /' $PDIR/CR10000.dat 
sed -i -e 's/^/ /' $PDIR/CRx0100004b.dat

#To convert the line endings in a text file from UNIX to DOS format (LF to CRLF)
#sed -i 's/$/\r/' $PDIR/CR10000.dat 
sed -i 's/$/\r/' $PDIR/CRx0100004b.dat 
#-------------------------------------------------------------------------------------# 
# here we publish the results
#-------------------------------------------------------------------------------------# 
# CRx0100004b=ciop.publish($PDIR/CRx0100004b)

echo "DONE"
