#!/bin/sh
#-------------------------------------------------------------------------------------# 
# PURPOSE: Vegetation and Soil status [B(x)]
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
# bash /application/bin/ISD5_node/ini.sh
#-------------------------------------------------------------------------------------#
export PATH=/opt/anaconda/bin/:$PATH

# Check HSD and LSD (for soil and vegetation) 
for i in {2,3,4,5,7}; do 
gdal_calc.py -A $NVDIR/Vx001.tif -B $VDIR/input002001.tif --outfile=$LDIR/Vx003002_0$i.tif --calc="(B==$i)*(A*10000)" --overwrite --NoDataValue=0 --type=UInt32;
done
# class 6
gdal_calc.py -A $SBDIR/Sx001.tif -B $CDIR/input002001.tif --outfile=$LDIR/Sx003002_06.tif --calc="(B==$i)*(A*10000)" --overwrite --NoDataValue=0 --type=UInt32;

for i in {1,8,9,10,11}; do 
gdal_calc.py -A $SBDIR/Sx001.tif -B $CDIR/input002001.tif --outfile=$LDIR/VxSx003002_0$i.tif --calc="(B==$i)*(A*0+5000)" --overwrite  --NoDataValue=0 --type=UInt32;
done
#-------------------------------------------------------------------------------------#
mv $LDIR/VxSx003002_010.tif  $LDIR/VxSx003001_10.tif
mv $LDIR/VxSx003002_011.tif  $LDIR/VxSx003001_11.tif
#-------------------------------------------------------------------------------------#  
R --vanilla --no-readline   -q  <<'EOF'

INDIR = Sys.getenv(c('VDIR'))
OUTDIR = Sys.getenv(c('LDIR'))
setwd(OUTDIR)

require(sp)
require(rgdal)
require(raster)
require("rciop")

# list all files from the current directory
list.files(pattern=".tif$") 
 
# create a list from these files
list.filenames<-list.files(pattern=".tif$")

# load raster data 

rstack003<-stack(raster(list.filenames[1]),
raster(list.filenames[2]), raster(list.filenames[3]), raster(list.filenames[4]), raster(list.filenames[5]),
raster(list.filenames[6]), raster(list.filenames[7]), raster(list.filenames[8]), raster(list.filenames[9]),
raster(list.filenames[10]), raster(list.filenames[11]))

rastD6<-sum(rstack003, na.rm=TRUE)
writeRaster(rastD6, filename="Bx001.tif", format="GTiff", overwrite=TRUE)

EOF

#-------------------------------------------------------------------------------------#
##gdalwarp -tr $z001 $z001 -r bilinear $LDIR/Bx003.tif $LDIR/Bx003b.tif
#-------------------------------------------------------------------------------------#
# Sample
#-------------------------------------------------------------------------------------#
ulx=$(gdalinfo $CMDIR/Dx001.tif | grep "Upper Left" | awk '{ gsub ("[(),]","") ; print  $3  }')
uly=$(gdalinfo $CMDIR/Dx001.tif | grep "Upper Left" | awk '{ gsub ("[(),]","") ; print  $4  }')
lrx=$(gdalinfo $CMDIR/Dx001.tif | grep "Lower Right" | awk '{ gsub ("[(),]","") ; print $3  }')
lry=$(gdalinfo $CMDIR/Dx001.tif | grep "Lower Right" | awk '{ gsub ("[(),]","") ; print $4  }')
# 
gdal_translate -projwin $ulx $uly $lrx $lry -of GTiff $LDIR/Bx001.tif $LDIR/Bx001rc.tif

# pkcrop -ulx $ulx -uly $uly -lrx $lrx -lry $lry -i $LDIR/Bx001.tif -o $LDIR/Bx001rc.tif
#-------------------------------------------------------------------------------------#
#  ASCII to geoMS (.OUT or .dat)
#-------------------------------------------------------------------------------------#
gdal_translate  -of AAIGrid  $LDIR/Bx001rc.tif   $LDIR/Bx001.asc 
awk '$1 ~ /^[0-9]/' $LDIR/Bx001.asc > $LDIR/Bx001.txt
gdalinfo $LDIR/Bx001.asc > $LDIR/ReadMeBx001.txt

export -p LDIR=$OUTDIR/COKC
#-------------------------------------------------------------------------------------#
R --vanilla --no-readline   -q  <<'EOF'


INDIR = Sys.getenv(c('LDIR'))
OUTDIR = Sys.getenv(c('LDIR'))
setwd(INDIR)

## load the package
require("zoo")
require("rgdal")
require("raster")
require("sp")

####console setting
###
options(max.print=99999999) 
options("scipen"=100, "digits"=4)

###read data###


dt<-paste(path=OUTDIR,'/',pattern="Bx001.txt",sep ="")

file003<-read.table(dt)

#sdf <- stack(file003)
#sdf10<-sdf$values
#sdf01<-sdf$values/10000

##
file004<-as.data.frame(t(file003))
sdf003<-stack(file004)
sdf10003<-sdf003$values
sdf01003<-sdf003$values/10000

# create a list from these files
list.filename<-list.files(pattern="Bx001rc.tif$")
file<-readGDAL(list.filename)
xy_sa=geometry(file)
xy<-data.frame(xy_sa)
z<- rep(0,dim(xy)[1])

sdf10110003 <-cbind(xy, sdf10003)
sdf01110003 <-cbind(xy, sdf01003)

sdf10111003 <-cbind(xy,z,sdf10003)
sdf01111003 <-cbind(xy,z,sdf01003)

##sem coordenadas
#int
#write.table(sdf10111003[,c(3:3)],paste(path=OUTDIR,'/' ,'Bx1000003.dat',sep = ""),  row.names = FALSE, col.names = FALSE)
#float
write.table(sdf01111003[,c(3:3)],paste(path=OUTDIR,'/' ,'Bx0100003.dat',sep = ""),  row.names = FALSE, col.names = FALSE)

EOF
#-------------------------------------------------------------------------------------#
HDIR=~/data/scripts_teste/
export HDIR
awk 'NR > 1 { print $1 }' $HDIR/header.txt > $LDIR/Bx0100004.dat
cat $LDIR/Bx0100003.dat >> $LDIR/Bx0100004.dat

# add space
sed -i -e 's/^/ /' $LDIR/Bx0100004.dat

# To convert the line endings in a text file from UNIX to DOS format (LF to CRLF)
sed -i 's/$/\r/' $LDIR/Bx0100004.dat 
#-------------------------------------------------------------------------------------# 
# here we publish the results
#-------------------------------------------------------------------------------------#
# Bx0100004=ciop.publish($OUTDIR001/Bx0100004.dat)
echo "DONE"
#-------------------------------------------------------------------------------------#
#exit 0
