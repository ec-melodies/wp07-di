#!/bin/bash
#-------------------------------------------------------------------------------------# 
# PURPOSE: Local static degradation CS(x)
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
export PATH=/opt/anaconda/bin/:$PATH
source ${ciop_job_include}
#-------------------------------------------------------------------------------------# 
# the environment variables 
#-------------------------------------------------------------------------------------# 
export -p IDIR=/application
export -p ODIR=/data/outDIR
export -p DIR=$ODIR/ISD
export -p OUTDIR=$DIR/ISD000
export -p CMDIR=$OUTDIR/CM001
export -p CMDIR01=$CMDIR/AOI/AOI_CX
export -p CXDIR=$IDIR/cli_block_a/bin
#-------------------------------------------------------------------------------------# 
export -p Y1=$1
export -p Y2=$2
#-------------------------------------------------------------------------------------# 

IR="$( ciop-getparam aoi )"
ciop-log "AOI: $IR"
#-------------------------------------------------------------------------------------# 
echo $Y1 $Y2 
#-------------------------------------------------------------------------------------# 
#-------------------------------------------------------------------------------------# 
ciop-log "Year Cs: $Y1"
ciop-log "Year Cs: $Y2"

cd $CMDIR
echo $CMDIR
#-------------------------------------------------------------------------------------# 
R --vanilla --no-readline   -q  <<'EOF'
#R version  3.2.1

INDIR = Sys.getenv(c('CMDIR'))
INDIR
CMDIR = Sys.getenv(c('CMDIR01'))
CMDIR
setwd(INDIR)

#-------------------------------------------------------------------------------------# 
#-------------------------------------------------------------------------------------# 
# load the package

xlist <- c("raster", "sp", "zoo", "rciop", "gtools", "digest", "rgdal")
new.packages <- xlist[!(xlist %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages)

lapply(xlist, require, character.only = TRUE)

options(max.print=99999999) 
options("scipen"=100, "digits"=4)
#-------------------------------------------------------------------------------------# 
#SUBS
#-------------------------------------------------------------------------------------# 
y1 = as.numeric(Sys.getenv(c('Y1')))
y1
y2 = as.numeric(Sys.getenv(c('Y2')))
y2

setwd(INDIR)
getwd()
list.files(R.home())

#download grib product
TPmlist01<-list.files(path=INDIR, pattern="*.grib")
str(TPmlist01)

rciop.log("DEBUG", paste("Download grib product in tmp folder:","TPmlist01", sep=" "))

for (i in 2:(length(TPmlist01))){ww=assign(paste("TPm_",i,sep=""),readGDAL(paste(INDIR,'/',TPmlist01[[i]] ,sep = "")))}
xy001=geometry(TPm_3)
str(xy001)

TPmlist02<-mget(mixedsort(ls(pattern="TPm_*")))
for (i in 1:(length(TPmlist02))){ww=assign(paste("TPm_df_t",i,sep=""),t(data.frame(TPmlist02[[i]])))
str(ww)
}

TPmlist03<-mget(mixedsort(ls(pattern="TPm_df_t*")))
for (i in 1:(length(TPmlist03))){ww=assign(paste("TPm_D2to1",i,sep=""),rollapply(TPmlist03[[i]], FUN=sum,by=2,width=2,na.rm = TRUE))
str(ww)
}

TPmlist04<-mget(mixedsort(ls(pattern="TPm_D2to1*")))
for (i in 1:(length(TPmlist04))){ww=assign(paste("TPm_D2to1_sa2",i,sep=""),data.frame(t(TPmlist04[[i]])))
str(ww)
}

TPmlist05<-mget(mixedsort(ls(pattern="TPm_D2to1_sa2*")))
for (i in 1:(length(TPmlist05))){ww=assign(paste("RL1001",i,sep=""),as.matrix(TPmlist05[[i]][,c(-dim(TPmlist05[[i]])[2])]))
str(ww)
}

TPmlist06<-mget(mixedsort(ls(pattern="RL1001*")))
for (i in 1:(length(TPmlist06)-1)){ww=assign(paste("RL100401_",i,sep=""),as.data.frame(TPmlist06[[i]]))
write.table(ww,paste("RL100401_",i,".txt", sep=""),row.names = FALSE, col.names = FALSE, quote = FALSE, append = FALSE)
str(ww)
setwd(CMDIR)
#rciop.publish(paste(CMDIR,"ww", sep="/"), FALSE,TRUE)
}

ls()

rciop.log("DEBUG", "End: Average RL1")
rciop.log("INFO", "RL1_txt")
EOF
#-------------------------------------------------------------------------------------# 
#-------------------------------------------------------------------------------------# 
echo "DONE"
exit 0
