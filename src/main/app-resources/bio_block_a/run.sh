#!/bin/bash
#-------------------------------------------------------------------------------------# 
# PURPOSE: run file for Ix
#-------------------------------------------------------------------------------------# 
#-------------------------------------------------------------------------------------# 
# source the ciop functions (e.g. ciop-log)
source ${ciop_job_include}
#-------------------------------------------------------------------------------------# 
export -p IDIR=/application
export -p IXDIR=$IDIR/bio_block_a/bin/
#-------------------------------------------------------------------------------------# 
export -p IR=$2
ciop-log "AOI: $IR"

export -p Y2=$1
ciop-log "Year: $Y2"

res=$?

export -p ODIR=/data/outDIR
export -p DIR=$ODIR/ISD
export -p OUTDIR=$ODIR/ISD/ISD000 
export -p CDIR=$OUTDIR/SM001 
export -p VDIR=$OUTDIR/VM001 
export -p NVDIR=$VDIR/class_NDV001/ndv_msc && mkdir -pm 777 $NVDIR
export -p SBDIR=$CDIR/class_SOIL001/soil_msc && mkdir -pm 777 $SBDIR

function igcx(){
exec $IXDIR"vgt_to_geoms_00201.sh" $Y2 $IR &
wait 
exec $IXDIR"vgt_to_geoms_00101.sh" $Y2 $IR & 
wait
exec $IXDIR"vgt_to_geoms_00501.sh" $Y2 $IR
}

igcx
ciop-log "INFO" "bio_block_a/run.sh"
#-------------------------------------------------------------------------------------# 

exit 0




