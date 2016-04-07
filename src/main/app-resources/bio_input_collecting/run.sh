#!/bin/bash
#-------------------------------------------------------------------------------------# 
# PURPOSE: run file for bio_block
#-------------------------------------------------------------------------------------# 
#-------------------------------------------------------------------------------------# 
# source the ciop functions (e.g. ciop-log)
source ${ciop_job_include}

ciop-log "INFO" "START: Bio_input_collecting" 

export -p IDIR=/application
echo "path ~bin:" $IDIR

export -p IXDIR=$IDIR/bio_input_collecting/bin/
export -p YR=$IDIR/parameters/LULC

export -p DIR=$TMPDIR/data/outDIR/ISD
#export -p DIR=/data/outDIR/ISD
export -p INP2=$IDIR/parameters/vito

IR="$( ciop-getparam aoi )"
ciop-log "AOI: $IR"

export -p Y2=$1
ciop-log "Year: $Y2"
#-------------------------------------------------------------------------------------# 
ciop-log "INFO" "Step00: Bio_input_collecting" 

function igcx1(){
exec $IXDIR"resample_aoi_0010100.sh" &
wait
exec $IXDIR"resample_aoi_0010300.sh"
}

igcx1

ciop-log "INFO" "Step01: Bio_input_collecting" 

function igcx(){

exec $IXDIR"resample_aoi_0010701.sh" $Y2 &
wait
exec $IXDIR"resample_aoi_0010900.sh" $Y2
}

function probav(){
while IFS='' read -r line || [[ -n "$line" ]]; do
	if [[ "$line" == AOI1 ]] ; then
		grep "X16Y03" $INP2 > $DIR/list.txt
		grep "X17Y03" $INP2 >> $DIR/list.txt
		grep "X18Y03" $INP2 >> $DIR/list.txt
		echo "${AOI=$(echo AOI1 )}"
		igcx $AOI
		echo "AOI1"

	elif [[ "$line" == AOI2 ]] ; then
		grep "Y03" $INP2 > $DIR/list.txt
		grep "Y04" $INP2 >> $DIR/list.txt
		grep "Y05" $INP2 >> $DIR/list.txt
		echo "${AOI=$(echo AOI2 )}"
		igcx $AOI
	    echo "AOI2"

	elif [[ "$line" == AOI3 ]] ; then
		grep "X20Y06" $INP2 > $DIR/list.txt
		grep "X21Y06" $INP2 >> $DIR/list.txt
		grep "X22Y06" $INP2 >> $DIR/list.txt
		grep "X20Y07" $INP2 >> $DIR/list.txt
		grep "X21Y07" $INP2 >> $DIR/list.txt
		grep "X22Y07" $INP2 >> $DIR/list.txt
		grep "X20Y08" $INP2 >> $DIR/list.txt
		grep "X21Y08" $INP2 >> $DIR/list.txt
		grep "X22Y08" $INP2 >> $DIR/list.txt
		grep "X20Y09" $INP2 >> $DIR/list.txt
		grep "X21Y09" $INP2 >> $DIR/list.txt
		grep "X22Y09" $INP2 >> $DIR/list.txt
		grep "X20Y10" $INP2 >> $DIR/list.txt
		grep "X21Y10" $INP2 >> $DIR/list.txt
		grep "X22Y10" $INP2 >> $DIR/list.txt
		echo "${AOI=$(echo AOI3 )}"
		igcx $AOI
		echo "AOI3"

	elif [[ "$line" == AOI4 ]] ; then
		grep "X20Y03" $INP2 > $DIR/list.txt
		grep "X21Y03" $INP2 >> $DIR/list.txt
		grep "X19Y03" $INP2 >> $DIR/list.txt
		echo "${AOI=$(echo AOI4 )}"
		igcx $AOI
		echo "AOI4"
	else
		echo "PROBA-V out of range"
	fi 
done < "$IR"
}

ciop-log "INFO" "Step02: Bio_input_collecting" 

function igcxs(){
exec $IXDIR"resample_aoi_0010700.sh" $Y2 &
wait
exec $IXDIR"resample_aoi_0010900.sh" $Y2
}

function spot_v(){
while IFS='' read -r line || [[ -n "$line" ]]; do
	
	if [[ "$line" == AOI1 ]] ; then
		echo "${AOI=$(echo AOI1 )}"
		grep $Y2 $INP2 > $DIR/list.txt
		igcxs $AOI
		echo "AOI1"
		echo $Y2
	
	elif [[ "$line" == AOI2 ]] ; then
		echo "${AOI=$(echo AOI2 )}"
		grep $Y2 $INP2 > $DIR/list.txt
	    	igcxs $AOI
       		echo "AOI2"
		echo $Y2

	elif [[ "$line" == AOI3 ]] ; then
		echo "${AOI=$(echo AOI3 )}"
		grep $Y2 $INP2 > $DIR/list.txt
		igcxs $AOI
		echo "AOI3"
		echo $Y2

	elif [[ "$line" == AOI4 ]] ; then
		echo "${AOI=$(echo AOI4 )}"
		grep $Y2 $INP2 > $DIR/list.txt
		igcxs $AOI
		echo "AOI4"
		echo $Y2
	else
		echo "AOI out of range"
	fi 
done < "$IR"
}

if ((Y2<2014)) ; then
    
    spot_v 
else
    probav
fi

#-------------------------------------------------------------------------------------# 
#-------------------------------------------------------------------------------------#
#-------------------------------------------------------------------------------------#
exit 0