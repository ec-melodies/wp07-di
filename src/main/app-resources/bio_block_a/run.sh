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

#variables
export -p ODIR=/data/outDIR
export -p DIR=$ODIR/ISD
export -p OUTDIR=$ODIR/ISD/ISD000 
export -p CDIR=$OUTDIR/SM001 
export -p VDIR=$OUTDIR/VM001 
export -p NVDIR=$VDIR/class_NDV001/ndv_msc && mkdir -pm 777 $NVDIR
export -p SBDIR=$CDIR/class_SOIL001/soil_msc && mkdir -pm 777 $SBDIR

export -p INP2=$OUTDIR/AOI.txt
export -p Y2=$(cat $INP2| awk '{ print  $2 }')
export -p IR=$(cat $INP2| awk '{ print  $3 }')

ciop-log "AOI: $IR"
ciop-log "Year: $Y2"

res=$?

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




