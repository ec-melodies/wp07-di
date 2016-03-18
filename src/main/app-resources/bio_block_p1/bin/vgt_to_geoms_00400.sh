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
# bash /application/bin/ISD5_node/ini.sh
export -p DIR=/data/auxdata/ISD/
export -p OUTDIR=$DIR/ISD000
export -p IDIR=/application/
echo $IDIR

export -p SBDIR=$OUTDIR/SM001/
export -p PDIR=$OUTDIR/PM001
export -p CMDIR=$OUTDIR/CM001
export -p HDIR=$IDIR/parameters/
export -p LDIR=$OUTDIR/COKC
export -p CDIR=$OUTDIR/SM001
export -p VDIR=$OUTDIR/VM001
export -p ZDIR=$OUTDIR/GEOMS
export -p LAND001=$OUTDIR/VITO
export PATH=/opt/anaconda/bin/:$PATH
#-------------------------------------------------------------------------------------#

#-1 = 1 Territórios artificializados		
#-2 = 2 Agricultura de sequeiro		
#-3 = 3 Agricultura de regadio		
#-4 = 4 Florestas		
#-5 = 5 Matos		
#-6 = 6 Vegetação herbácea natural		
#-7 = 7 Vegetação esparsa		
#-8 = 8 Áreas ardidas		
#-9 = 9 Praias, Dunas, Areais e Rocha Nua		
#-10 =10  Zonas Húmidas		
#-11 =11 Corpos de Água		
#-*	= NULL

#-------------------------------------------------------------------------------------#
R --vanilla --no-readline   -q  <<'EOF'
LDIR = Sys.getenv(c('LAND001'))
CMDIR = Sys.getenv(c('LAND001'))
setwd(LDIR)
getwd()

require("zoo")
require("rgdal")
require("raster")
require("sp")
require("rciop")
require("gtools")
library(digest)

options(max.print=99999999) 
options("scipen"=100, "digits"=4)

TPmlist01<-mixedsort(list.files(pattern=paste("NDV02_*",".*\\.tif",sep="")))
TPmlist01

for (i in 1:(length(TPmlist01))){
rb=raster(paste(LDIR,'/',TPmlist01[[i]] ,sep = ""))
rb
capture.output(rb, file=paste(LDIR,'/','INFONDV02',i,'.txt',sep = ""), append=FALSE)
capture.output(rb, file=paste(LDIR,'/','INFO_NDV02','.txt',sep = ""), append=TRUE)
}

setwd(CMDIR)
TPmlist01<-mixedsort(list.files(pattern=paste("LANDC002_*",".*\\.tif",sep="")))
TPmlist01

for (i in 1:(length(TPmlist01))){
rb=raster(paste(CMDIR,'/',TPmlist01[[i]] ,sep = ""))
rb
capture.output(rb, file=paste(LDIR,'/','INFOLANDC1C',i,'.txt',sep = ""), append=FALSE)
capture.output(rb, file=paste(LDIR,'/','INFO_LANDC1C','.txt',sep = ""), append=TRUE)
}

EOF

#-------------------------------------------------------------------------------------#
h=1
for file in $LAND001/NDV02_*.tif; do 
filename=$(basename $file .tif )
input001=$LAND001/${filename}.tif
input002=$LAND001/${filename/#NDV02_001_crop/LANDC01}.tif 
# Get the same boundary information_globcover
h=$((h+1))
Cx001=$LAND001/${filename/#NDV02_001_crop_/INFONDV02}.txt
Cx002=$LAND001/${filename/#NDV02_001_crop_/INFOLANDC1C}.txt
echo $Cx001
echo $Cx002

ulx=$(cat $Cx001  | grep "extent" | awk '{ gsub ("[(),]","") ; print  $3 }')
uly=$(cat $Cx001  | grep "extent" | awk '{ gsub ("[(),]","") ; print  $6 }')
lrx=$(cat $Cx001  | grep "extent" | awk '{ gsub ("[(),]","") ; print  $4 }')
lry=$(cat $Cx001  | grep "extent" | awk '{ gsub ("[(),]","") ; print  $5 }')

ulx1=$(awk "BEGIN {print ($ulx+6184.416)}")
uly1=$(awk "BEGIN {print ($uly-6184.416)}")
lrx1=$(awk "BEGIN {print ($lrx-6184.416)}")
lry1=$(awk "BEGIN {print ($lry+6184.416)}")

echo $ulx $uly $lrx $lry 

output003=$LAND001/${filename/#NDV02_001_crop/LANDC1}.tif 
echo $output003 
gdal_translate -projwin $ulx1 $uly1 $lrx1 $lry1 -of GTiff $input002 $output003
done
#-------------------------------------------------------------------------------------#
#-------------------------------------------------------------------------------------# 

# => For Discriminant classes 0.8:
for file in $LAND001/NDV02_*.tif; do 
filename=$(basename $file .tif )
input001=$LAND001/${filename}.tif
input002=$LAND001/${filename/#NDV02_001_crop/LANDC01}.tif 
for i in {4,5,6,7}; do
output003=$PDIR/${filename/#NDV02_001_crop/CR}_0$i.tif   
echo $output003
echo $input001
echo $input002

gdal_calc.py -A $input002 -B $input002 --outfile=$output003 --calc="(B==$i)*(A*0+8000)" --overwrite --type=Int32;
done
done

# => For Non-Discriminant classes 0.0:

for file in $LAND001/NDV02_*.tif; do 
filename=$(basename $file .tif )
input001=$LAND001/${filename}.tif
input002=$LAND001/${filename/#NDV02_001_crop/LANDC01}.tif 
for i in {1,8,9}; do
output003=$PDIR/${filename/#NDV02_001_crop/CR}_0$i.tif   
echo $output003 
gdal_calc.py -A $input002 -B $input002 --outfile=$output003 --calc="(B==$i)*(A*0)" --overwrite --type=Int32;
done
done

for file in $LAND001/NDV02_*.tif; do 
filename=$(basename $file .tif )
input001=$LAND001/${filename}.tif
input002=$LAND001/${filename/#NDV02_001_crop/LANDC01}.tif  
for i in {10,11}; do
output003=$PDIR/${filename/#NDV02_001_crop/CR}_$i.tif   
echo $output003 
gdal_calc.py -A $input002 -B $input002 --outfile=$output003 --calc="(B==$i)*(A*0)" --overwrite --type=Int32;
done
done

for file in $LAND001/NDV02_*.tif; do 
filename=$(basename $file .tif )
input001=$LAND001/${filename}.tif
input002=$LAND001/${filename/#NDV02_001_crop/LANDC01}.tif  
for i in {2,3}; do
output003=$PDIR/${filename/#NDV02_001_crop/CR}_0$i.tif     
echo $output003 
gdal_calc.py -A $input002 -B $input002 --outfile=$output003 --calc="(B==$i)*(A*0+8000)" --overwrite --type=Int32;
done
done
#-------------------------------------------------------------------------------------#
export -p PDIR=$OUTDIR/PM001

#-------------------------------------------------------------------------------------#

R --vanilla --no-readline   -q  <<'EOF'

INDIR = Sys.getenv(c('PDIR'))
OUTDIR = Sys.getenv(c('PDIR'))
LDIR = Sys.getenv(c('LAND001'))
setwd(OUTDIR)
getwd()

require(sp)
require(rgdal)
require(raster)
require("rciop")
require("gtools")

# list all files from the current directory
list.files(pattern=".tif$") 
 
ww=assign(paste("list.filenames_",sep=""),mixedsort(list.files(pattern=paste("CR_",".*\\.tif",sep=""))))

setwd(LDIR)
n02 <- list.files(pattern="LANDC1_")
n03 <- length(n02)
n02
n03

setwd(OUTDIR)
for (j in 1:n03){ 
list.filenames=assign(paste("list.filenames_",j,sep=""),list.files(pattern=paste("CR_",j,"_",".*\\.tif",sep="")))
list.filenames

rstack003<-stack(raster(list.filenames[1]),
raster(list.filenames[2]), raster(list.filenames[3]), raster(list.filenames[4]), raster(list.filenames[5]),
raster(list.filenames[6]), raster(list.filenames[7]), raster(list.filenames[8]), raster(list.filenames[9]),
raster(list.filenames[10]), raster(list.filenames[11]))
rastD6<-max(rstack003, na.rm=TRUE)

head(rastD6)

writeRaster(rastD6, filename=paste("CR001_",j,".tif", sep=""), format="GTiff", overwrite=TRUE)

}

EOF
#-------------------------------------------------------------------------------------#
for file in $LAND001/NDV02_*.tif; do 
filename=$(basename $file .tif )
input001=$LAND001/${filename}.tif
input002=$PDIR/${filename/#NDV02_001_crop/CR001}.tif 
output003=$PDIR/${filename/#NDV02_001_crop/CR001_03}.tif 
#echo $output003
#gdalinfo $input001
#gdalinfo $input002
z001="$(gdalinfo $input001  | grep "Pixel Size" |  awk  -F, ' {print $(NF-1)}'| awk '{ gsub ("[(),]","") ; print  $4  }')"
gdalwarp -tr $z001 $z001 -r bilinear -overwrite $input002 $output003
done

#-------------------------------------------------------------------------------------#
#-------------------------------------------------------------------------------------#
echo "DONE"
exit 0