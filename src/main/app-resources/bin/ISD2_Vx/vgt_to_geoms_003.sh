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
#source ${ciop_job_include}
#-------------------------------------------------------------------------------------# 
# the environment variables 
#-------------------------------------------------------------------------------------# 
# bash /application/bin/ISD5_node/ini.sh
#-------------------------------------------------------------------------------------#
export PATH=/opt/anaconda/bin/:$PATH
export INDIR=$DIR/INPUT
#-------------------------------------------------------------------------------------# 
#auxiliar data files (tmp): The intermediate indicators:
export -p DIR=~/data/ISD/
export -p OUTDIR=$DIR/ISD000/
export -p NVDIR=$OUTDIR/VM001/class_NDV001/
export -p SBDIR=$OUTDIR/SM001/class_SOIL001/
export -p LDIR=$OUTDIR/COKC
export -p CDIR=$OUTDIR/SM001
export -p VDIR=$OUTDIR/VM001
export -p HDIR=~/wp07-di/src/main/app-resources/bin/ISD5_node/
export -p RECLASS=$OUTDIR/SPPV001
#-------------------------------------------------------------------------------------# 
# # Check HSD and LSD (for soil and vegetation) EStou aqui
#-------------------------------------------------------------------------------------# 
for file in $NVDIR/Vx*.tif; do
filename01=$(basename $file .tif)
f=${filename01/#Vx001_/LULC_mosaic_}  
j=${f/%/01}
for file2 in $j; do
filename02=$(basename $file2 .tif )
done;
echo $filename01 $filename02
for i in {2,3,4,6}; do 
gdal_calc.py -A $NVDIR/${filename01}.tif -B $RECLASS/${filename02}.tif --outfile=$LDIR/Vx${filename01}_0$i.tif --calc="(B==$i)*(A)" --overwrite --NoDataValue=0 --type=UInt32;
done;
done

for file in $SBDIR/Sx*.tif; do
filename01=$(basename $file .tif)
f=${filename01/#Sx001_/LULC_mosaic_}  
j=${f/%/01}
for file2 in $j; do
filename02=$(basename $file2 .tif )
done;
echo $filename01 $filename02
for i in 5; do 
gdal_calc.py -A $SBDIR/${filename01}.tif -B $RECLASS/${filename02}.tif --outfile=$LDIR/Vx${filename01}_0$i.tif --calc="(B==$i)*(A)" --overwrite  --NoDataValue=0 --type=UInt32;
done;
done

for file in $SBDIR/Sx*.tif; do
filename01=$(basename $file .tif)
f=${filename01/#Sx001_/LULC_mosaic_}  
j=${f/%/01}
for file2 in $j; do
filename02=$(basename $file2 .tif )
done;
echo $filename01 $filename02
for i in {1,7,8,9,10,11}; do 
gdal_calc.py -A $SBDIR/${filename01}.tif -B $RECLASS/${filename02}.tif --outfile=$LDIR/Vx${filename01}_0$i.tif --calc="(B==$i)*(A)" --overwrite  --NoDataValue=0 --type=UInt32;
done;
done
#-------------------------------------------------------------------------------------#
mv $LDIR/VxSx001__010.tif  $LDIR/VxSx001__10.tif
mv $LDIR/VxSx001__011.tif  $LDIR/VxSx001__11.tif
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
#for (j in 1:4){ 
#print(j)
ww=assign(paste("list.filenames_",sep=""),list.files(pattern=paste("x001_",".*\\.tif",sep="")))
#}


# create a list from these files
#for (j in 1:4)
#{ 
#print(j)
list.filenames=assign(paste("list.filenames_",sep=""),list.files(pattern=paste("x001_",".*\\.tif",sep="")))
# load raster data  

rstack003<-stack(raster(list.filenames[1]),
raster(list.filenames[2]), raster(list.filenames[3]), raster(list.filenames[4]), raster(list.filenames[5]),
raster(list.filenames[6]), raster(list.filenames[7]), raster(list.filenames[8]), raster(list.filenames[9]),
raster(list.filenames[10]), raster(list.filenames[11]))

rastD6<-sum(rstack003, na.rm=TRUE)
writeRaster(rastD6, filename=paste("Bx001_", ".tif", sep=""), format="GTiff", overwrite=TRUE)
#}

EOF

#-------------------------------------------------------------------------------------#
##gdalwarp -tr $z001 $z001 -r bilinear $LDIR/Bx003.tif $LDIR/Bx003b.tif
#-------------------------------------------------------------------------------------#
# Sample
#-------------------------------------------------------------------------------------#
#ulx=$(gdalinfo $CMDIR/Dx001.tif | grep "Upper Left" | awk '{ gsub ("[(),]","") ; print  $3  }')
#uly=$(gdalinfo $CMDIR/Dx001.tif | grep "Upper Left" | awk '{ gsub ("[(),]","") ; print  $4  }')
#lrx=$(gdalinfo $CMDIR/Dx001.tif | grep "Lower Right" | awk '{ gsub ("[(),]","") ; print $3  }')
#lry=$(gdalinfo $CMDIR/Dx001.tif | grep "Lower Right" | awk '{ gsub ("[(),]","") ; print $4  }')
# 
#gdal_translate -projwin $ulx $uly $lrx $lry -of GTiff $LDIR/Bx001.tif $LDIR/Bx001rc.tif

# pkcrop -ulx $ulx -uly $uly -lrx $lrx -lry $lry -i $LDIR/Bx001.tif -o $LDIR/Bx001rc.tif
#-------------------------------------------------------------------------------------#
#  ASCII to geoMS (.OUT or .dat)
#-------------------------------------------------------------------------------------#
export -p LDIR=$OUTDIR/COKC

for file in $LDIR/Bx001_*.tif; do
filename=$(basename $file .tif)
gdal_translate  -of AAIGrid  $LDIR/${filename}.tif   $LDIR/${filename}.asc 
awk '$1 ~ /^[0-9]/' $LDIR/${filename}.asc > $LDIR/${filename}.txt
#gdalinfo $LDIR/${filename}.asc > $LDIR/ReadMe${filename}.txt
done
#-------------------------------------------------------------------------------------#
R --vanilla --no-readline   -q  <<'EOF'

INDIR = Sys.getenv(c('LDIR'))
OUTDIR = Sys.getenv(c('LDIR'))
setwd(INDIR)

# load the package
require("zoo")
require("rgdal")
require("raster")
require("sp")

#console setting

options(max.print=99999999) 
options("scipen"=100, "digits"=4)

#read data#
# list all files from the current directory
list.files(pattern=".tif$")  
# create a list from these files
list.filenames<-list.files(pattern=".tif$")
list.filenames02<-list.files(pattern=".txt$")

#Bx001_2_crop.txt

#for (j in 1:4){ 
#print(j)
dt=assign(paste(path=OUTDIR,'/',pattern="Bx001_",".txt",sep =""),list.files(pattern=paste("Bx001_",".*\\.txt",sep="")))
print(dt)
file003<-read.table(paste(path=OUTDIR,'/',dt,sep=""))
#sdf <- stack(file003)
#sdf10<-sdf$values
#sdf01<-sdf$values/10000
#
file004<-as.data.frame(t(file003))
sdf003<-stack(file004)
sdf10003<-sdf003$values
sdf01003<-sdf003$values/10000
# create a list from these files


list.filename=assign(paste(path=OUTDIR,'/',pattern="Bx001_",".tif",sep =""),list.files(pattern=paste("Bx001_",".*\\.tif",sep="")))
file<-readGDAL(paste(path=OUTDIR,'/',list.filename,sep=""))

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
write.table(sdf01111003[,c(4:4)],paste(path=OUTDIR,'/' ,'Bx0100003_','.dat',sep = ""),  row.names = FALSE, col.names = FALSE)
#}
EOF
#-------------------------------------------------------------------------------------#
export -p HDIR=/application/bin/ISD5_node/
#-------------------------------------------------------------------------------------# 
for file in $LDIR/*.dat; do 
filename=$(basename $file .dat )
awk 'NR > 1 { print $2 }' $HDIR/header.txt > $LDIR/${filename}_01.dat
cat $file >> $LDIR/${filename}_01.dat
sed -i '/^[[:space:]]*$/d' $LDIR/${filename}_01.dat 
# add space
sed -i -e 's/^/ /' $LDIR/${filename}_01.dat
# To convert the line endings in a text file from UNIX to DOS format (LF to CRLF)
sed -i 's/$/\r/' $LDIR/${filename}_01.dat 
done

#-------------------------------------------------------------------------------------# 
# here we publish the results
#-------------------------------------------------------------------------------------#
# Bx0100004=ciop.publish($OUTDIR001/Bx0100004.dat)
echo "DONE"
#-------------------------------------------------------------------------------------#
#exit 0
