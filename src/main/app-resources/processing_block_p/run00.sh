#!/bin/bash
#-------------------------------------------------------------------------------------# 
# PURPOSE: isd_cx
#-------------------------------------------------------------------------------------# 

# source the ciop functions (e.g. ciop-log)
source ${ciop_job_include}

#-------------------------------------------------------------------------------------# 
#-------------------------------------------------------------------------------------# 
start=`date +%s`
#-------------------------------------------------------------------------------------#

export -p IDIR=/application
echo $IDIR
export -p IXDIR=$IDIR/processing_block_p/bin/
export -p HXDIR=$IDIR/parameters

export -p IDIR=/application
export -p ODIR=/data/outDIR
export -p DIR=$ODIR/ISD
export -p OUTDIR=$DIR/ISD000
export -p VITO=$OUTDIR/VITO
export -p INP2=$OUTDIR/AOI.txt

#Year
export -p Y2=$(cat $INP2| awk '{ print  $2 }')

export -p IR="$( ciop-getparam aoi )"
ciop-log "AOI: $IR"

ciop-log "Year: ${Year}"

if ((Y2<=2003)) ; then
    export -p Y1=$(($Y2-20))
    echo "20 years"
else
    export -p Y1=$(($Y2-25))
    echo "25 years"
fi

echo "Here:" $Y2

function igcx(){
exec $IXDIR"isd_cx001.sh" $1 $2
}

export -p CRS32662=$IR
echo $CRS32662

export -p AOIX=$HXDIR/AOI_ISD.txt
echo $AOIX

if [[ $CRS32662 == AOI1 ]] ; then
	grep "Cx_AOI1" $AOIX > $ZDIR/list_isd_cx1.txt;
	echo $CRS32662

elif [[ $CRS32662 == AOI2 ]] ; then
	grep "Cx_AOI2" $AOIX > $ZDIR/list_isd_cx1.txt;
	echo $CRS32662

elif [[ $CRS32662 == AOI3 ]] ; then
	grep "Cx_AOI3" $AOIX > $ZDIR/list_isd_cx1.txt;
	echo $CRS32662

elif [[ $CRS32662 == AOI4 ]] ; then 
	grep "Cx_AOI4" $AOIX > $ZDIR/list_isd_cx1.txt;
	echo $CRS32662
else
	echo "AOI out of range"
fi

ciop-log "INFO" "parametros: $AOIX $CRS32662"


#while IFS='' read -r line || [[ -n "$input" ]]; do; 
#do
#  echo "${input}" | ciop-publish -s
#  igcx $Y2 $IR 
#done < "$ZDIR/list_isd_cx1.txt"

igcx $Y2 $IR 
#-------------------------------------------------------------------------------------# 
#-------------------------------------------------------------------------------------# 
end=`date +%s`
runtime=$((end-start))
echo "Runtime: $runtime seconds"

ciop-log "INFO" "isd: $runtime seconds"
#-------------------------------------------------------------------------------------# 
exit 0 
