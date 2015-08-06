#!/bin/sh
############################################################################
#	
# PURPOSE:Vegetation and Soil status [B(x)]
#
#############################################################################

# Requires:
# gdalinfo
# gdal_calc
# pktools
# gdal_translate 
##R
#require(sp)
#require(rgdal)
#require(raster)

################################.............................................BX
# Check if HSD and LSD (for soil and vegetation) are equal	=> Non-Discriminant
for i in {2,3,4,5,7}; do 
gdal_calc.py -A $NVDIR/Vx001.tif -B $VDIR/input002001.tif --outfile=$LDIR/Vx003002_0$i.tif --calc="(B==$i)*(A*10000)" --overwrite --NoDataValue=0 --type=UInt32;
done

# class 6
gdal_calc.py -A $SBDIR/Sx001.tif -B $CDIR/input002001.tif --outfile=$LDIR/Sx003002_06.tif --calc="(B==$i)*(A*10000)" --overwrite --NoDataValue=0 --type=UInt32;


for i in {1,8,9,10,11}; do 
gdal_calc.py -A $SBDIR/Sx001.tif -B $CDIR/input002001.tif --outfile=$LDIR/VxSx003002_0$i.tif --calc="(B==$i)*(A*0+5000)" --overwrite  --NoDataValue=0 --type=UInt32;
done

mv $LDIR/VxSx003002_010.tif  $LDIR/VxSx003001_10.tif
mv $LDIR/VxSx003002_011.tif  $LDIR/VxSx003001_11.tif
####################################  

#############integração................................Bx
R --vanilla --no-readline   -q  <<'EOF'

INDIR = Sys.getenv(c('VDIR'))
OUTDIR = Sys.getenv(c('LDIR'))
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

rastD6<-sum(rstack003, na.rm=TRUE)
writeRaster(rastD6, filename="Bx001.tif", format="GTiff", overwrite=TRUE)

EOF

##################################VGT to GeoMS (ASCII)
##gdalwarp -tr $z001 $z001 -r bilinear $LDIR/Bx003.tif $LDIR/Bx003b.tif

#######################sample
ulx=$(gdalinfo $OUTDIR001/Dx001.tif | grep "Upper Left" | awk '{ gsub ("[(),]","") ; print  $3  }')
uly=$(gdalinfo $OUTDIR001/Dx001.tif | grep "Upper Left" | awk '{ gsub ("[(),]","") ; print  $4  }')
lrx=$(gdalinfo $OUTDIR001/Dx001.tif | grep "Lower Right" | awk '{ gsub ("[(),]","") ; print $3  }')
lry=$(gdalinfo $OUTDIR001/Dx001.tif | grep "Lower Right" | awk '{ gsub ("[(),]","") ; print $4  }')

pkcrop -ulx $ulx -uly $uly -lrx $lrx -lry $lry -i $LDIR/Bx001.tif -o $LDIR/Bx001rc.tif


### ASCII to geoMS (.OUT or .dat)

gdal_translate  -of AAIGrid  $LDIR/Bx001rc.tif   $LDIR/Bx001.asc 

echo "DONE"

awk '$1 ~ /^[0-9]/' $LDIR/Bx001.asc > $LDIR/Bx001.txt

gdalinfo $LDIR/Bx001.asc > $LDIR/ReadMeBx001.txt

head $OUTDIR001/Bx001.asc

#######################
R --vanilla --no-readline   -q  <<'EOF'

INDIR = Sys.getenv(c('LDIR'))
OUTDIR = Sys.getenv(c('LDIR'))
setwd(INDIR)

## load the package
require("zoo")
require("rgdal")
require("raster")
require("sp")
#require("matrixStats")

####console setting
###
options(max.print=99999999) 
options("scipen"=100, "digits"=4)

###read data###

#setwd("/home/melodies-ist/teste/")

dt<-paste(path=OUTDIR,'/',pattern="Bx001.txt",sep ="")
file003<-read.table(dt)
sdf <- stack(file003)
sdf10<-sdf$values
sdf01<-sdf$values/10000

# create a list from these files
list.filename<-list.files(pattern="Bx001rc.tif$")
file<-readGDAL(list.filename)
xy_sa=geometry(file)
xy<-data.frame(xy_sa)
z<- rep(0,dim(xy)[1])


sdf10110 <-cbind(xy, sdf10)
sdf01110 <-cbind(xy, sdf01)

sdf10111 <-cbind(xy,z,sdf10)
sdf01111 <-cbind(xy,z,sdf01)

##sem coordenadas
#int
write.table(sdf10110[,c(3:3)],paste(path=OUTDIR,'/' ,'Bx10000.dat',sep = ""),  row.names = FALSE, col.names = FALSE)
#float
write.table(sdf01110[,c(3:3)],paste(path=OUTDIR,'/' ,'Bx01000.dat',sep = ""),  row.names = FALSE, col.names = FALSE)

##com coordenadas x,y
#int
#write.table(sdf10110,paste(path=OUTDIR,'/' ,'Bx10110.dat',sep = ""),  row.names = FALSE, col.names = FALSE)
#float
#write.table(sdf01110,paste(path=OUTDIR,'/' ,'Bx01110.dat',sep = ""),  row.names = FALSE, col.names = FALSE)

##com coordenadas x,y,z
#int
#write.table(sdf10111,paste(path=OUTDIR,'/' ,'Bx10111.dat',sep = ""),  row.names = FALSE, col.names = FALSE)
#float
#write.table(sdf01111,paste(path=OUTDIR,'/' ,'Bx01111.dat',sep = ""),  row.names = FALSE, col.names = FALSE)

EOF

#add space
sed -i -e 's/^/ /' $LDIR/Bx10000.dat 
sed -i -e 's/^/ /' $LDIR/Bx01000.dat

#sed -i -e 's/^/ /' $LDIR/Bx10110.dat 
#sed -i -e 's/^/ /' $LDIR/Bx01110.dat

#sed -i -e 's/^/ /' $LDIR/Bx10111.dat 
#sed -i -e 's/^/ /' $LDIR/Bx01111.dat

#To convert the line endings in a text file from UNIX to DOS format (LF to CRLF)
sed -i 's/$/\r/' $LDIR/Bx10000.dat 
sed -i 's/$/\r/' $LDIR/Bx01000.dat 

#sed -i 's/$/\r/' $LDIR/Bx10110.dat  
#sed -i 's/$/\r/' $LDIR/Bx01110.dat  

#sed -i 's/$/\r/' $LDIR/Bx10111.dat  
#sed 's/$/\r/' $LDIR/Bx01111.dat

echo "DONE"




