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
export PATH=/opt/anaconda/bin/:$PATH
export -p DIR=~/data/ISD/
export -p INDIR=$DIR/INPUT

export -p OUTDIR=$DIR/ISD000
export -p LAND001=$OUTDIR/VITO/
export -p VDIR=$OUTDIR/VM001
export -p NVDIR=$OUTDIR/VM001/class_NDV001/

export PATH=/opt/anaconda/bin/:$PATH
#-------------------------------------------------------------------------------------#
input001=$1
input002=$2
#-------------------------------------------------------------------------------------#
# JOB# resample LULC para o mesmo pixel scale do target (SPOT or PROBA-V)
#-------------------------------------------------------------------------------------#
z001="$(gdalinfo $input002 | grep "Pixel Size" |  awk  -F, ' {print $(NF-1)}'| awk '{ gsub ("[(),]","") ; print  $4  }')"
gdalwarp -tr $z001 $z001 -r bilinear -overwrite $input001 $LAND001/NDV02.tif 
#-------------------------------------------------------------------------------------#
#-------------------------------------------------------------------------------------#
# r.factor: PhyVal = DN / ScalingFactor + Offset, Offset=-0.08, Scaling factor=250
# PV = (1/250) * DN + (-0.08) 
#-------------------------------------------------------------------------------------#
gdal_calc.py -A $LAND001/NDV02.tif --outfile=$NVDIR/NDV02_001.tif --calc="(((A*0.004)-0.08)*10000.0)" --overwrite --NoDataValue=255 --type=Int32 
#-------------------------------------------------------------------------------------#
# JOB#005 Extrair as classes por land cover [1:11] e calc os valores de HSD and LSD
#-------------------------------------------------------------------------------------#
#reclassification
for i in {2,3,4,5,7}; do  
gdal_calc.py -A $NVDIR/NDV02_001.tif -B $LAND001/LANDC001_1.tif --outfile=$NVDIR/LANDC001_1_0$i.tif --calc="((B==$i)*(A))" --NoDataValue=0 --overwrite --type=Int32; 
#zLSD="$(oft-mm -um $VDIR/class_temp/input003001_$i.tif $VDIR/class_temp/input003001_$i.tif| grep "Band 1 min"|  awk '{ gsub ("[(),]","") ; print $5  }')"
done

for i in {1,6,8,9,10,11}; do  
gdal_calc.py -A $NVDIR/NDV02_001.tif -B $LAND001/LANDC001_1.tif --outfile=$NVDIR/NORN_LANDC001_1_0$i.tif --calc="(B==$i)*(A*0+5000)" --NoDataValue=0 --overwrite --type=Int32; 
#zLSD="$(oft-mm -um $VDIR/class_temp/input003001_$i.tif $VDIR/class_temp/input003001_$i.tif| grep "Band 1 min"|  awk '{ gsub ("[(),]","") ; print $5  }')"
done

mv $NVDIR/NORN_LANDC001_1_010.tif $NVDIR/NORN_LANDC001_1_10.tif
mv $NVDIR/NORN_LANDC001_1_011.tif $NVDIR/NORN_LANDC001_1_11.tif

#-------------------------------------------------------------------------------------#

export -p VDIR=$OUTDIR/VM001
export -p NVDIR=$OUTDIR/VM001/class_NDV001/
export -p ISD5_Nx=~/wp07-di/src/main/app-resources/bin/ISD5_Nx/
#-------------------------------------------------------------------------------------#
R --vanilla --no-readline   -q  <<'EOF'

# set working directory
INDIR = Sys.getenv(c('NVDIR'))
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
list.filenames[1]

for (j in 1:5){ 
class_2<-readGDAL(list.filenames[j])
class_02<-as.matrix(class_2@data)
class_002<-as.double(class_02)/10000
bps <- boxplot.stats(class_002) 
ISD_HSD=bps$stats[1] #lower wisker
write.table(ISD_HSD,paste(path=OUTDIR,'/' ,'ISD_HSD_',j,'.txt',sep = ""),row.names = FALSE, col.names =  FALSE, quote = FALSE, append = FALSE) 
print(ISD_HSD)
ISD_LSD=bps$stats[5] #upper wisker 
write.table(ISD_LSD,paste(path=OUTDIR,'/' ,'ISD_LSD_',j,'.txt',sep = ""),row.names = FALSE, col.names =  FALSE, quote = FALSE, append = FALSE) 
print(ISD_LSD)
ISD_MEAN=mean(class_002, na.rm=TRUE) #mean
write.table(ISD_MEAN,paste(path=OUTDIR,'/' ,'ISD_MEAN_',j,'.txt',sep = ""),row.names = FALSE, col.names =  FALSE, quote = FALSE, append = FALSE) 
print(ISD_MEAN)
}
EOF
#-------------------------------------------------------------------------------------#
# # calculo das medias das classes, normalização 

export -p NVDIR=$OUTDIR/VM001/class_NDV001/
export -p VDIR=$OUTDIR/VM001

h=0
#reclassification:iberian
for file in $NVDIR/LANDC001_1_*tif; do
filename01=$(basename $file .tif)
j=LANDC001_1

for file2 in $j; do
filename02=$(basename $file2 .tif )
done;
echo $filename01 $filename02
i=${filename01}

h=$((h+1))
f=${filename01/#LANDC001_1_0/ }
i=${f}

ISD_HSD=$(awk '$1 ~ /^[0-9]/' $ISD5_Nx/ISD_HSD_$h.txt)
ISD_LSD=$(awk '$1 ~ /^[0-9]/' $ISD5_Nx/ISD_LSD_$h.txt)
ISD_MEAN=$(awk '$1 ~ /^[0-9]/' $ISD5_Nx/ISD_MEAN_$h.txt)

echo $ISD_HSD $ISD_LSD $ISD_MEAN $i $h
gdal_calc.py -A  $NVDIR/${filename01}.tif -B $LAND001/${filename02}.tif --outfile=$NVDIR/NORN_${filename01}.tif --calc="(B==$i)*((A*0+(($ISD_LSD-$ISD_MEAN)/($ISD_LSD-$ISD_HSD)))*10000)" --NoDataValue=0 --overwrite --type=Int32
done

#-------------------------------------------------------------------------------------#
#-------------------------------------------------------------------------------------#
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
writeRaster(rastD6, filename=paste("Vx001_",".tif", sep=""), format="GTiff", overwrite=TRUE, na.rm=TRUE)
#}


#-------------------------------------------------------------------------------------# 
# here we publish the results
#-------------------------------------------------------------------------------------# 
# Vx001 <- rciop.publish(rastD6, recursive=FALSE, metalink=TRUE)
EOF

cp $NVDIR/Vx001_.tif $VDIR/Vx001_.tif
#rm -rf $NVDIR

today=$(date)
echo "The date and time are: " $today
#-------------------------------------------------------------------------------------# 
echo "DONE"