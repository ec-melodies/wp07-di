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
#export PATH=/opt/anaconda/bin/:$PATH
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
export -p LAND001=$OUTDIR/SPPV001/

export -p VDIR=$OUTDIR/VM001
export -p CDIR=$OUTDIR/SM001
export -p SBDIR=$OUTDIR/SM001/class_SOIL001/

#-------------------------------------------------------------------------------------#
input006=$INDIR/NIR.tif 
input007=$INDIR/RED.tif
input002=$LAND001/LULC_mosaic.tif

#-------------------------------------------------------------------------------------#
# JOB# resample LULC para o mesmo pixel scale do target (SPOT or PROBA-V)
#-------------------------------------------------------------------------------------#
rm $LAND001/LULC_mosaic_01.tif
for file in $LAND001/LULC*.tif; do 
filename=$(basename $file .tif ) 
echo $filename
gdalinfo $LAND001/${filename}.tif
input001=$LAND001/NIR01.tif
input002=$LAND001/${filename}.tif
z001="$(gdalinfo $input001 | grep "Pixel Size" |  awk  -F, ' {print $(NF-1)}'| awk '{ gsub ("[(),]","") ; print  $4  }')"
gdalwarp -tr $z001 $z001 -r bilinear $input002 $LAND001/${filename}_01.tif
done

#-------------------------------------------------------------------------------------#
###JOB#002 Get the same boundary information_globcover
#ulx=$(gdalinfo $CDIR/input002001.tif | grep "Upper Left" | awk '{ gsub ("[(),]","") ; print  $3  }')
#uly=$(gdalinfo $CDIR/input002001.tif | grep "Upper Left" | awk '{ gsub ("[(),]","") ; print  $4  }')
#lrx=$(gdalinfo $CDIR/input002001.tif | grep "Lower Right" | awk '{ gsub ("[(),]","") ; print $3  }')
#lry=$(gdalinfo $CDIR/input002001.tif | grep "Lower Right" | awk '{ gsub ("[(),]","") ; print $4  }')

#pkcrop -ulx $ulx -uly $uly -lrx $lrx -lry $lry -i $input006 -o $CDIR/input006002.tif
#pkcrop -ulx $ulx -uly $uly -lrx $lrx -lry $lry -i $input007 -o $CDIR/input007002.tif

#gdal_translate -projwin $ulx $uly $lrx $lry -of GTiff $input006 $CDIR/input006002.tif
#gdal_translate -projwin $ulx $uly $lrx $lry -of GTiff $input007 $CDIR/input007002.tif

#-------------------------------------------------------------------------------------#
# JOB#003 Extrair as class per land cover [1:11] e 
# aplicar o factor de escala imagens PROBA-V or SPOT-VGT
# r.factor: PhyVal = DN / ScalingFactor + Offset, Offset=-0.08, Scaling factor=250 (NDVI)
# R = 0.0005 * DN (SPOT-VGT) (others)
# R = 0.0005 * DN (Proba-v) (others)
#-------------------------------------------------------------------------------------#
for file in $LAND001/NIR*01.tif; do 
filename=$(basename $file .tif ) 
echo $filename
gdalinfo $LAND001/${filename}.tif
gdal_calc.py -A $LAND001/${filename}.tif  --outfile=$SBDIR/${filename}_001.tif --calc="(0.0005*A)*10000" --overwrite --NoDataValue=-1 --type=UInt32;
done 

for file in $LAND001/RED*01.tif; do 
filename=$(basename $file .tif ) 
echo $filename
gdalinfo $LAND001/${filename}.tif
gdal_calc.py -A $LAND001/${filename}.tif f --outfile=$SBDIR/${filename}_001.tif --calc="(0.0005*A)*10000" --overwrite --NoDataValue=-1 --type=UInt32;
done

#-------------------------------------------------------------------------------------#
#calculo do BRIGHTNESS

for file in $SBDIR/NIR01_001.tif; do
filename01=$(basename $file .tif)
j=${filename01/%NIR01_001/RED01_001}  
for file2 in $j; do
filename02=$(basename $file2 .tif )
done;
echo $filename01 $filename02
gdal_calc.py -A $SBDIR/${filename01}.tif -B $SBDIR/${filename02}.tif --outfile=$SBDIR/NIRRED_Bx.tif --calc="sqrt(A*A+B*B)" --overwrite --type=UInt32;
done

#-------------------------------------------------------------------------------------#
# calculo dos valores para a parametrização: HSD and LSD
#-------------------------------------------------------------------------------------#
for file in $SBDIR/*Bx.tif; do
filename01=$(basename $file .tif)
f=${filename01/#NIRRED/LULC_mosaic}  
j=${f/%Bx/01}
for file2 in $j; do
filename02=$(basename $file2 .tif )
done;
echo $filename01 $filename02
gdalinfo $SBDIR/${filename01}.tif
gdalinfo $LAND001/${filename02}.tif

for i in 5; do  
gdal_calc.py -A $SBDIR/${filename01}.tif -B $LAND001/${filename02}.tif --outfile=$SBDIR/${filename02}_0$i.tif --calc="(B==$i)*(A)" --overwrite --NoDataValue=0 --type=UInt32; 
#zLSD="$(oft-mm -um $VDIR/class_temp/input003001_$i.tif $VDIR/class_temp/input003001_$i.tif| grep "Band 1 min"|  awk '{ gsub ("[(),]","") ; print $5  }')"
done;

for i in {1,2,3,4,6,7,8,9,10,11}; do  
gdal_calc.py -A $SBDIR/${filename01}.tif -B $LAND001/${filename02}.tif --outfile=$SBDIR/NORN_${filename02}_0$i.tif --calc="(B==$i)*(A*0+5000)" --overwrite --NoDataValue=0 --type=UInt32; 
#zLSD="$(oft-mm -um $VDIR/class_temp/input003001_$i.tif $VDIR/class_temp/input003001_$i.tif| grep "Band 1 min"|  awk '{ gsub ("[(),]","") ; print $5  }')"
done;
done

mv $SBDIR/NORN_${filename02}_010.tif $SBDIR/NORN_${filename02}_10.tif
mv $SBDIR/NORN_${filename02}_011.tif $SBDIR/NORN_${filename02}_11.tif

#-------------------------------------------------------------------------------------#
#-------------------------------------------------------------------------------------#
# calculo das medias por classe, normalização
#-------------------------------------------------------------------------------------#
export -p SBDIR=$OUTDIR/SM001/class_SOIL001/
export -p VDIR=$OUTDIR/SM001
 
#reclassification:iberian
for file in $SBDIR/LULC_mosaic_01_*.tif; do
filename01=$(basename $file .tif)
j=LULC_mosaic_01
for file2 in $j; do
filename02=$(basename $file2 .tif )
done;
echo $filename01 $filename02
i=${filename01}

#gdalinfo $SBDIR/${filename01}.tif
#gdalinfo $LAND001/${filename02}.tif

min=$(gdalinfo -stats $SBDIR/${filename01}.tif | grep "STATISTICS_MINIMUM" | awk '{ gsub ("STATISTICS_MINIMUM=","") ; print  $0  }')
max=$(gdalinfo -stats $SBDIR/${filename01}.tif | grep "STATISTICS_MAXIMUM" | awk '{ gsub ("STATISTICS_MAXIMUM=","") ; print  $0  }')
mean=$(gdalinfo -stats $SBDIR/${filename01}.tif | grep "STATISTICS_MEAN" | awk '{ gsub ("STATISTICS_MEAN=","") ; print  $0  }')

f=${filename01/#LULC_mosaic_01_0/ }
i=${f}
echo $min $max $mean $i
gdal_calc.py -A  $SBDIR/${filename01}.tif -B $LAND001/${filename02}.tif --outfile=$SBDIR/NORN_${filename01}.tif --calc="(B==$i)*((A*0+(($mean-$min)/($max-$min)))*10000)" --NoDataValue=0 --overwrite --type=UInt32
done

#-------------------------------------------------------------------------------------#
#mv  $SBDIR/NORN_LULC_mosaic_01_010.tif  $SBDIR/NORN_LULC_mosaic_01_10.tif
#mv  $SBDIR/NORN_LULC_mosaic_01_011.tif  $SBDIR/NORN_LULC_mosaic_01_11.tif

rm $SBDIR/NORN_LULC_mosaic*.xml
#-------------------------------------------------------------------------------------#
#-------------------------------------------------------------------------------------#
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


echo "DONE"
#exit 0
#-------------------------------------------------------------------------------------#