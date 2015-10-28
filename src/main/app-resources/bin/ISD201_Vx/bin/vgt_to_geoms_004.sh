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
# source ${ciop_job_include}
#-------------------------------------------------------------------------------------# 
# the environment variables 
#-------------------------------------------------------------------------------------# 
# bash /application/bin/ISD5_node/ini.sh
export -p DIR=~/data/ISD/
export -p OUTDIR=$DIR/ISD000
export -p SBDIR=$OUTDIR/SM001/
export -p HDIR=/application/bin/ISD5_Nx/
export -p PDIR=$OUTDIR/PM001
export -p CMDIR=$OUTDIR/CM001
export -p HDIR=~/wp07-di/src/main/app-resources/bin/ISD5_Nx/
export -p LDIR=$OUTDIR/COKC
export -p CDIR=$OUTDIR/SM001
export -p VDIR=$OUTDIR/VM001
export -p ZDIR=$OUTDIR/GEOMS

export PATH=/opt/anaconda/bin/:$PATH
#-------------------------------------------------------------------------------------#

for file in $SBDIR/Sx001*.tif; do
filename01=$(basename $file .tif)
f=${filename01/#Sx001_/LANDC001_1}  
j=${f/%/}
for file2 in $j; do
filename02=$(basename $file2 .tif )
done;
echo $filename01 $filename02
# => For Discriminant classes 0.8:
for i in {4,5,6,7}; do 
gdal_calc.py -A $SBDIR/${filename01}.tif -B $RECLASS/${filename02}.tif --outfile=$PDIR/CR${filename01}_0$i.tif --calc="(B==$i)*(A*0+8000)" --overwrite  --NoDataValue=-9999 --type=UInt32;
done;
done

for file in $SBDIR/Sx001*.tif; do
filename01=$(basename $file .tif)
f=${filename01/#Sx001_/LANDC001_1}  
j=${f/%/}
for file2 in $j; do
filename02=$(basename $file2 .tif )
done;
echo $filename01 $filename02
# => For Non-Discriminant classes 0.5:
for i in {1,8,9,10,11}; do 
gdal_calc.py -A $SBDIR/${filename01}.tif -B $RECLASS/${filename02}.tif --outfile=$PDIR/CR${filename01}_0$i.tif --calc="(B==$i)*(A*0)" --overwrite  --NoDataValue=-9999 --type=UInt32;
done;
done


for file in $SBDIR/Sx001*.tif; do
filename01=$(basename $file .tif)
f=${filename01/#Sx001_/LANDC001_1}  
j=${f/%/}
for file2 in $j; do
filename02=$(basename $file2 .tif )
done;
echo $filename01 $filename02
# => For Non-Discriminant classes 0.5:
for i in {2,3}; do 
gdal_calc.py -A $SBDIR/${filename01}.tif -B $RECLASS/${filename02}.tif --outfile=$PDIR/CR${filename01}_0$i.tif --calc="(B==$i)*(A*0+8000)" --overwrite  --NoDataValue=-9999 --type=UInt32;
done;
done


#-------------------------------------------------------------------------------------#
export -p PDIR=$OUTDIR/PM001
mv $PDIR/CRSx001__010.tif  $PDIR/CRSx001__10.tif
mv $PDIR/CRSx001__011.tif  $PDIR/CRSx001__11.tif

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
list.filenames
rstack003<-stack(raster(list.filenames[1]),
raster(list.filenames[2]), raster(list.filenames[3]), raster(list.filenames[4]), raster(list.filenames[5]),
raster(list.filenames[6]), raster(list.filenames[7]), raster(list.filenames[8]), raster(list.filenames[9]),
raster(list.filenames[10]), raster(list.filenames[11]))

rastD6<-sum(rstack003, na.rm=TRUE)
writeRaster(rastD6, filename=paste("CR001_",".tif", sep=""), format="GTiff", overwrite=TRUE)
#}

EOF
#-------------------------------------------------------------------------------------#
z001="$(gdalinfo $LDIR/Bx002_.tif  | grep "Pixel Size" |  awk  -F, ' {print $(NF-1)}'| awk '{ gsub ("[(),]","") ; print  $4  }')"
gdalwarp -tr $z001 $z001 -r bilinear -overwrite $PDIR/CR001_.tif $PDIR/CR001_03.tif
#-------------------------------------------------------------------------------------#
#-------------------------------------------------------------------------------------#
# ASCII to geoMS (.OUT or .dat)
#-------------------------------------------------------------------------------------#
export -p PDIR=$OUTDIR/PM001

for file in $PDIR/CR001_*03.tif; do
filename=$(basename $file .tif)
gdal_translate  -of AAIGrid  $PDIR/${filename}.tif   $PDIR/${filename}.asc 
awk '$1 ~ /^[0-9]/' $PDIR/${filename}.asc > $PDIR/${filename}.txt
#gdalinfo $PDIR/${filename}.asc > $PDIR/ReadMe${filename}.txt
done

export -p LDIR=$OUTDIR/COKC

#-------------------------------------------------------------------------------------#
R --vanilla --no-readline   -q  <<'EOF'

INDIR = Sys.getenv(c('PDIR'))
OUTDIR = Sys.getenv(c('PDIR'))
OUTDIR01 = Sys.getenv(c('ZDIR'))

setwd(INDIR)

## load the package
require("zoo")
require("rgdal")
require("raster")
require("sp")

options(max.print=99999999) 
options("scipen"=100, "digits"=4)

#read data#
# list all files from the current directory
list.files(pattern=".tif$")  
# create a list from these files
list.filenames<-list.files(pattern=".tif$")
list.filenames02<-list.files(pattern=".txt$")

#for (j in 1:4){ 
#print(j)
dt=assign(paste(path=OUTDIR,'/',pattern="CR001_03",".txt",sep =""),list.files(pattern=paste("CR001_03",".*\\.txt",sep="")))
print(dt)

#-------------------------------------------------------------------------------------#
file003<-read.table(paste(path=OUTDIR,'/',dt,sep=""))

setwd(OUTDIR01)
list.files(pattern=".tif$")  
# create a list from these files
list.filenames<-list.files(pattern=".tif$")
list.filenames02<-list.files(pattern=".txt$")

list.filename=assign(paste(path=OUTDIR01,'/',pattern="Bx002_",".tif",sep =""),list.files(pattern=paste("Bx002_",".*\\.tif",sep="")))
file<-readGDAL(paste(path=OUTDIR01,'/',list.filename,sep=""))

setwd(INDIR)
file005 = as.matrix(file003, nrow = file@grid@cells.dim[1], ncol = file@grid@cells.dim[2])

file004 = matrix(0, nrow = file@grid@cells.dim[2], ncol = file@grid@cells.dim[1])

for (i in 1:dim(file005)[1]) {file004[i,]=file005[dim(file005)[1]-i+1,] }

file006<-as.data.frame(t(file004))
sdf003<-stack(file006)

#-------------------------------------------------------------------------------------#

sdf10003<-sdf003$values
sdf01003<-sdf003$values/10000

# create a list from these files

list.filename=assign(paste(path=OUTDIR,'/',pattern="CR001_03",".tif",sep =""),list.files(pattern=paste("CR001_03",".*\\.tif",sep="")))
file<-readGDAL(paste(path=OUTDIR,'/',list.filename,sep=""))

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
write.table(sdf01111003[,c(4:4)],paste(path=OUTDIR,'/' ,'CRx0100003_','.dat',sep = ""),  row.names = FALSE, col.names = FALSE)

#}
EOF

#-------------------------------------------------------------------------------------#
#export -p HDIR=/application/bin/ISD5_Nx/
export -p HDIR=/home/melodies-ist/wp07-di/src/main/app-resources/bin/ISD5_Nx/
#-------------------------------------------------------------------------------------# 
for file in $PDIR/*.dat; do 
filename=$(basename $file .dat )
awk 'NR > 1 { print $3 }' $HDIR/header.txt > $PDIR/${filename}_01.dat
cat $file  >> $PDIR/${filename}_01.dat
sed -i '/^[[:space:]]*$/d' $PDIR/${filename}_01.dat  
#sed -i -e 's/^/ /' $PDIR/CR10000.dat 
sed -i -e 's/^/ /' $PDIR/${filename}_01.dat
#To convert the line endings in a text file from UNIX to DOS format (LF to CRLF)
#sed -i 's/$/\r/' $PDIR/CR10000.dat 
sed -i 's/$/\r/' $PDIR/${filename}_01.dat
cp $PDIR/${filename}_01.dat $ZDIR/${filename}_01.dat
done
rm -rf $PDIR
#-------------------------------------------------------------------------------------# 
# here we publish the results
#-------------------------------------------------------------------------------------# 
# CRx0100004b=ciop.publish($PDIR/CRx0100004b)

echo "DONE"
