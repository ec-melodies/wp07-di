#!/bin/bash
#-------------------------------------------------------------------------------------# 
# PURPOSE: Local dynamic degradation D(x)
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
#-------------------------------------------------------------------------------------# 
# the environment variables 
#-------------------------------------------------------------------------------------# 
export -p DIR=$TMPDIR/data/outDIR/ISD
#export -p DIR=/data/outDIR/ISD
export -p OUTDIR=$DIR/ISD000

export PATH=/opt/anaconda/bin/:$PATH

export -p CMDIR=$OUTDIR/CM001
export -p CMDIR02=$CMDIR/AOI/AOI_DX
export PATH=/opt/anaconda/bin/:$PATH
export -p ZDIR=$OUTDIR/GEOMS

#-------------------------------------------------------------------------------------# 
R --vanilla --no-readline   -q  <<'EOF'
#R version  3.2.1

INDIR = Sys.getenv(c('CMDIR'))
CMDIR = Sys.getenv(c('CMDIR02'))

y1 = as.numeric(Sys.getenv(c('y1')))
y2 = as.numeric(Sys.getenv(c('y2')))

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
setwd(INDIR)

TPmlist01<-list.files(path=INDIR, pattern="*.grib")
TPmlist01
for (i in 2:(length(TPmlist01))){ww=assign(paste("TPm_",i,sep=""),readGDAL(paste(INDIR,'/',TPmlist01[[i]] ,sep = "")))}
xy001=geometry(TPm_3)

TPmlist02<-mget(mixedsort(ls(pattern="TPm_*")))
for (i in 1:(length(TPmlist02))){ww=assign(paste("TPm_df_t",i,sep=""),t(data.frame(TPmlist02[[i]])))}

TPmlist03<-mget(mixedsort(ls(pattern="TPm_df_t*")))
for (i in 1:(length(TPmlist03))){ww=assign(paste("TPm_D2to1",i,sep=""),rollapply(TPmlist03[[i]], FUN=sum,by=2,width=2,na.rm = TRUE))}

TPmlist04<-mget(mixedsort(ls(pattern="TPm_D2to1*")))
for (i in 1:(length(TPmlist04))){ww=assign(paste("TPm_D2to1_sa2",i,sep=""),data.frame(t(TPmlist04[[i]])))}

TPmlist05<-mget(mixedsort(ls(pattern="TPm_D2to1_sa2*")))
for (i in 1:(length(TPmlist05))){ww=assign(paste("RL1001",i,sep=""),as.matrix(TPmlist05[[i]][,c(-dim(TPmlist05[[i]])[2])]))}

setwd(CMDIR)
TPmlist06<-mget(mixedsort(ls(pattern="RL1001*")))
for (i in 1:(length(TPmlist06)-1)){ww=assign(paste("RL100401_",i,sep=""),as.data.frame(TPmlist06[[i]]))
write.table(ww,paste("RL100401_",i,".txt", sep=""),row.names = FALSE, col.names = FALSE, quote = FALSE, append = FALSE) 
}
#-------------------------------------------------------------------------------------# 
#-------------------------------------------------------------------------------------# 
EOF

echo "DONE"
exit 0



