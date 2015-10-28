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
export PATH=/opt/anaconda/bin/:$PATH
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
export -p LAND001=$OUTDIR/VITO/

export -p CDIR=$OUTDIR/SM001
export -p SBDIR=$OUTDIR/SM001/class_SOIL001/

#-------------------------------------------------------------------------------------#
#-------------------------------------------------------------------------------------#
# JOB# resample LULC para o mesmo pixel scale do target (SPOT or PROBA-V)
#-------------------------------------------------------------------------------------#

input001=$1
input002=$2
input003=$3

#input001=/home/melodies-ist/data/ISD/ISD000/VITO/NIR001_01.tif
#input002=/home/melodies-ist/data/ISD/ISD000/VITO/LANDC001_1.tif
#input003=/home/melodies-ist/data/ISD/ISD000/VITO/RED001_01.tif


z001="$(gdalinfo $input002 | grep "Pixel Size" |  awk  -F, ' {print $(NF-1)}'| awk '{ gsub ("[(),]","") ; print  $4  }')"
gdalwarp -tr $z001 $z001 -r bilinear -overwrite $input001 $LAND001/NIR02.tif 

z001="$(gdalinfo $input002 | grep "Pixel Size" |  awk  -F, ' {print $(NF-1)}'| awk '{ gsub ("[(),]","") ; print  $4  }')"
gdalwarp -tr $z001 $z001 -r bilinear -overwrite $input003 $LAND001/RED02.tif 

#-------------------------------------------------------------------------------------#
#-------------------------------------------------------------------------------------#
# JOB#003 Extrair as class per land cover [1:11] e 
# aplicar o factor de escala imagens PROBA-V or SPOT-VGT
# r.factor: PhyVal = DN / ScalingFactor + Offset, Offset=-0.08, Scaling factor=250 (NDVI)
# R = 0.0005 * DN (SPOT-VGT) (others)
# R = 0.0005 * DN (Proba-v) (others)
#-------------------------------------------------------------------------------------#
gdal_calc.py -A $LAND001/NIR02.tif  --outfile=$SBDIR/NIR02_001.tif --calc="(0.0005*A)*10000" --overwrite --NoDataValue=-1 --type=Int32
gdal_calc.py -A $LAND001/RED02.tif  --outfile=$SBDIR/RED02_001.tif --calc="(0.0005*A)*10000" --overwrite --NoDataValue=-1 --type=Int32

#-------------------------------------------------------------------------------------#
#calculo do BRIGHTNESS
gdal_calc.py -A $SBDIR/NIR02_001.tif -B $SBDIR/RED02_001.tif --outfile=$SBDIR/NIRRED_Bx.tif --calc="sqrt(A*A+B*B)" --NoDataValue=-1 --overwrite --type=Int32
#-------------------------------------------------------------------------------------#
# calculo dos valores para a parametrização: HSD and LSD
#-------------------------------------------------------------------------------------#
for i in 6; do  
gdal_calc.py -A $SBDIR/NIRRED_Bx.tif -B $input002 --outfile=$SBDIR/LANDC001_1_0$i.tif --calc="(B==$i)*(A)" --NoDataValue=0 --overwrite --type=Int32
#zLSD="$(oft-mm -um $VDIR/class_temp/input003001_$i.tif $VDIR/class_temp/input003001_$i.tif| grep "Band 1 min"|  awk '{ gsub ("[(),]","") ; print $5  }')"
done

#-------------------------------------------------------------------------------------#
#-------------------------------------------------------------------------------------#
# calculo das medias por classe, normalização
#-------------------------------------------------------------------------------------#
export -p SBDIR=$OUTDIR/SM001/class_SOIL001/
export -p VDIR=$OUTDIR/SM001
export -p ISD5_Nx=~/wp07-di/src/main/app-resources/bin/ISD5_Nx/

#-------------------------------------------------------------------------------------#
R --vanilla --no-readline   -q  <<'EOF'

# set working directory
INDIR = Sys.getenv(c('SBDIR'))
OUTDIR = Sys.getenv(c('ISD5_Nx'))
setwd(INDIR)

require(sp)
require(rgdal)
require(raster)
require(rciop)

# list all files from the current directory
list.files(pattern=".tif$") 
 
# create a list from these files

#print(j)

list.filenames=assign(paste("list.filenames",sep=""),list.files(pattern=paste("LANDC001",".*\\.tif",sep="")))
list.filenames

for (j in 1:length(list.filenames)){ 

x<-readGDAL(list.filenames)

# set NA values to -9999
#fun <- function(x) { x[is.na(x)] <- -9999; return(x)} 
#rc3 <- calc(rc2, fun)

x02<-as.matrix(x@data)
x002<-as.double(x02)/10000
bps <- boxplot.stats(x002)


ISD_LSD=bps$stats[1] #lower wisker
write.table(ISD_LSD,paste(path=OUTDIR,'/' ,'ISD_LSDsx_',j,'.txt',sep = ""),row.names = FALSE, col.names =  FALSE, quote = FALSE, append = FALSE) 
print(ISD_LSD)

ISD_HSD=bps$stats[5] #upper wisker 
write.table(ISD_HSD,paste(path=OUTDIR,'/' ,'ISD_HSDsx_',j,'.txt',sep = ""),row.names = FALSE, col.names =  FALSE, quote = FALSE, append = FALSE) 
print(ISD_HSD)

ISD_MEAN=mean(x002, na.rm=TRUE) #mean
write.table(ISD_MEAN,paste(path=OUTDIR,'/' ,'ISD_MEANsx_',j,'.txt',sep = ""),row.names = FALSE, col.names =  FALSE, quote = FALSE, append = FALSE) 
print(ISD_MEAN)
}
EOF
#-------------------------------------------------------------------------------------#

for i in {1,2,3,4,5,7,8,9,10,11}; do  
gdal_calc.py -A $SBDIR/NIRRED_Bx.tif -B $input002 --outfile=$SBDIR/NORN_LANDC001_1_0$i.tif --calc="(B==$i)*(A*0+5000)" --overwrite --NoDataValue=0 --type=UInt32; 
#zLSD="$(oft-mm -um $VDIR/class_temp/input003001_$i.tif $VDIR/class_temp/input003001_$i.tif| grep "Band 1 min"|  awk '{ gsub ("[(),]","") ; print $5  }')"
done

mv $SBDIR/NORN_LANDC001_1_010.tif $SBDIR/NORN_LANDC001_1_10.tif
mv $SBDIR/NORN_LANDC001_1_011.tif $SBDIR/NORN_LANDC001_1_11.tif

#-------------------------------------------------------------------------------------#
#-------------------------------------------------------------------------------------#
# # calculo das medias das classes, normalização 

export -p SBDIR=$OUTDIR/SM001/class_SOIL001/
export -p VDIR=$OUTDIR/VM001

h=0
#reclassification:iberian
for file in $SBDIR/LANDC001_1_*.tif; do
filename01=$(basename $file .tif)
j=LANDC001_1
for file2 in $j; do
filename02=$(basename $file2 .tif )
done;
echo $filename01 $filename02
i=${filename01}

h=$((h+1))
#gdalinfo $NVDIR/${filename01}.tif
#gdalinfo $LAND001/${filename02}.tif

f=${filename01/#LANDC001_1_0/ }
i=${f}

ISD_HSD=$(awk '$1 ~ /^[0-9]/' $ISD5_Nx/ISD_HSDsx_$h.txt)
ISD_LSD=$(awk '$1 ~ /^[0-9]/' $ISD5_Nx/ISD_LSDsx_$h.txt)
ISD_MEAN=$(awk '$1 ~ /^[0-9]/' $ISD5_Nx/ISD_MEANsx_$h.txt)

echo $ISD_HSD $ISD_LSD $ISD_MEAN $i $h
gdal_calc.py -A  $SBDIR/${filename01}.tif -B $LAND001/${filename02}.tif --outfile=$SBDIR/NORN_${filename01}.tif --calc="(B==$i)*((A*0+(($ISD_MEAN-$ISD_LSD)/($ISD_HSD-$ISD_LSD)))*10000)" --NoDataValue=0 --overwrite --type=UInt32
done

#-------------------------------------------------------------------------------------#
R --vanilla --no-readline   -q  <<'EOF'

# set working directory
INDIR = Sys.getenv(c('SBDIR'))
VDIR = Sys.getenv(c('SBDIR'))
setwd(INDIR)

require(sp)
require(rgdal)
require(raster)
require(rciop)

# list all files from the current directory
list.files(pattern=".tif$") 
 
# create a list from these files
#for (j in 1:4){ 
#print(j)
list.filenames=assign(paste("list.filenames",sep=""),list.files(pattern=paste("NORN_",".*\\.tif",sep="")))
list.filenames
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
summary(rastD6)
writeRaster(rastD6, filename=paste("Sx001_",".tif", sep=""), format="GTiff", overwrite=TRUE, na.rm=TRUE)
#}

EOF
#-------------------------------------------------------------------------------------# 
# here we publish the results
#-------------------------------------------------------------------------------------# 
# Sx001 <- rciop.publish(rastD7, recursive=FALSE, metalink=TRUE)

cp $SBDIR/Sx001_.tif $CDIR/Sx001_.tif
#rm -rf $SBDIR

echo "DONE"
#exit 0
#-------------------------------------------------------------------------------------#