#!/bin/bash
#-------------------------------------------------------------------------------------# 
# PURPOSE: run file for bio_input_collecting
#-------------------------------------------------------------------------------------# 
#-------------------------------------------------------------------------------------# 
# source the ciop functions (e.g. ciop-log)
source ${ciop_job_include}
ciop-log "INFO" "START: Bio_input_collecting" 
#--------------------------------------------------------------------------------------# 
export PATH=/opt/anaconda/bin/:$PATH
export -p IDIR=/application
export -p IXDIR=$IDIR/bio_input_collecting/bin/
export -p YR=$IDIR/parameters/LULC

export -p ODIR=/data/outDIR
export -p DIR=$ODIR/ISD/ISD000
export -p INP2=$IDIR/parameters/vito
#-------------------------------------------------------------------------------------# 
export -p INP=$DIR/AOI.txt
export -p Y2=$(cat $INP| awk '{ print  $2 }')
export -p IR=$(cat $INP| awk '{ print  $3 }')

ciop-log "AOI: $IR"
ciop-log "Year: $Y2"

#-------------------------------------------------------------------------------------# 
ciop-log "INFO" "Step00: Bio_input_collecting" 

function probav(){
if [[ $IR == AOI1 ]] ; then
	grep $Y2 $INP2 | grep "X16Y03" > $DIR/list1.txt
	grep $Y2 $INP2 | grep "X17Y03" >> $DIR/list1.txt
	grep $Y2 $INP2 | grep "X18Y03" >> $DIR/list1.txt
	echo "${AOI=$(echo AOI1 )}"
	igcx $AOI
	echo "AOI1"

elif [[ $IR == AOI2 ]] ; then
	grep $Y2 $INP2 | grep "X16Y03" > $DIR/list1.txt
	grep $Y2 $INP2 | grep "X16Y04" >> $DIR/list1.txt
	grep $Y2 $INP2 | grep "X16Y05" >> $DIR/list1.txt
	grep $Y2 $INP2 | grep "X17Y03" >> $DIR/list1.txt
	grep $Y2 $INP2 | grep "X17Y04" >> $DIR/list1.txt
	grep $Y2 $INP2 | grep "X17Y05" >> $DIR/list1.txt
	grep $Y2 $INP2 | grep "X18Y03" >> $DIR/list1.txt
	grep $Y2 $INP2 | grep "X18Y04" >> $DIR/list1.txt
	grep $Y2 $INP2 | grep "X18Y05" >> $DIR/list1.txt
	grep $Y2 $INP2 | grep "X19Y03" >> $DIR/list1.txt
	grep $Y2 $INP2 | grep "X19Y04" >> $DIR/list1.txt
	grep $Y2 $INP2 | grep "X19Y05" >> $DIR/list1.txt
	grep $Y2 $INP2 | grep "X20Y03" >> $DIR/list1.txt
	grep $Y2 $INP2 | grep "X20Y04" >> $DIR/list1.txt
	grep $Y2 $INP2 | grep "X20Y05" >> $DIR/list1.txt
	grep $Y2 $INP2 | grep "X21Y03" >> $DIR/list1.txt
	grep $Y2 $INP2 | grep "X21Y04" >> $DIR/list1.txt
	grep $Y2 $INP2 | grep "X21Y05" >> $DIR/list1.txt
	echo "${AOI=$(echo AOI2 )}"
	igcx $AOI
	echo "AOI2"

elif [[ $IR == AOI3 ]] ; then
	grep $Y2 $INP2 | grep "X20Y06" > $DIR/list1.txt
	grep $Y2 $INP2 | grep "X21Y06" >> $DIR/list1.txt
	grep $Y2 $INP2 | grep "X22Y06" >> $DIR/list1.txt
	grep $Y2 $INP2 | grep "X20Y07" >> $DIR/list1.txt
	grep $Y2 $INP2 | grep "X21Y07" >> $DIR/list1.txt
	grep $Y2 $INP2 | grep "X22Y07" >> $DIR/list1.txt
	grep $Y2 $INP2 | grep "X20Y08" >> $DIR/list1.txt
	grep $Y2 $INP2 | grep "X21Y08" >> $DIR/list1.txt
	grep $Y2 $INP2 | grep "X22Y08" >> $DIR/list1.txt
	grep $Y2 $INP2 | grep "X20Y09" >> $DIR/list1.txt
	grep $Y2 $INP2 | grep "X21Y09" >> $DIR/list1.txt
	grep $Y2 $INP2 | grep "X22Y09" >> $DIR/list1.txt
	grep $Y2 $INP2 | grep "X20Y10" >> $DIR/list1.txt
	grep $Y2 $INP2 | grep "X21Y10" >> $DIR/list1.txt
	grep $Y2 $INP2 | grep "X22Y10" >> $DIR/list1.txt
	echo "${AOI=$(echo AOI3 )}"
	igcx $AOI
	echo "AOI3"

elif [[ $IR == AOI4 ]] ; then
	grep $Y2 $INP2 | grep "X22Y03" > $DIR/list1.txt
	grep $Y2 $INP2 | grep "X20Y03" >> $DIR/list1.txt
	grep $Y2 $INP2 | grep "X21Y03" >> $DIR/list1.txt
	grep $Y2 $INP2 | grep "X19Y03" >> $DIR/list1.txt
	echo "${AOI=$(echo AOI4 )}"
	igcx $AOI
	echo "AOI4"
else
	echo "PROBA-V out of range"
fi
}

ciop-log "INFO" "Step02: Bio_input_collecting $Y2" 


function spot_v(){
if [[ $IR == AOI1 ]] ; then
	echo "${AOI=$(echo AOI1 )}"
	grep $Y2 $INP2 > $DIR/list.txt
	igcxs $AOI
	echo "AOI1"
	echo $Y2
	
elif [[ $IR == AOI2 ]] ; then
	echo "${AOI=$(echo AOI2 )}"
	grep $Y2 $INP2 > $DIR/list.txt
	igcxs $AOI
    	echo "AOI2"
	echo $Y2

elif [[ $IR == AOI3 ]] ; then
	echo "${AOI=$(echo AOI3 )}"
	grep $Y2 $INP2 > $DIR/list.txt
	igcxs $AOI
	echo "AOI3"
	echo $Y2

elif [[ $IR == AOI4 ]] ; then
	echo "${AOI=$(echo AOI4 )}"
	grep $Y2 $INP2 > $DIR/list.txt
	igcxs $AOI
	echo "AOI4"
	echo $Y2
else
	echo "SPOT-VGT AOI out of range"
fi 
}

function igcx(){
exec $IXDIR"resample_aoi_0010100.sh" $Y2 $IR &
wait
exec $IXDIR"resample_aoi_0010300.sh" $Y2 $IR &
wait
exec $IXDIR"resample_aoi_0010701.sh" $Y2 $IR &
wait
exec $IXDIR"resample_aoi_0010704.sh" $Y2 $IR &
wait
exec $IXDIR"resample_aoi_0010900.sh" $Y2 $IR
}

function igcxs(){
exec $IXDIR"resample_aoi_0010100.sh" $Y2 $IR &
wait
exec $IXDIR"resample_aoi_0010300.sh" $Y2 $IR &
wait
exec $IXDIR"resample_aoi_0010700.sh" $Y2 $IR &
wait
exec $IXDIR"resample_aoi_0010702.sh" $Y2 $IR &
wait
exec $IXDIR"resample_aoi_0010900.sh" $Y2 $IR
}

if echo "$Y2" | grep -qE ^\-?[0-9]?\.?[0-9]+$; then
if (($Y2 < 2014 || $Y2 <1999)) ; then 
    echo "spot_v"
    spot_v
elif (($Y2 < 2018)) ; then  
    echo "probav"
    probav
else
    echo "IBCS need new satellite images"; res=3 && exit ${res}
fi
else
   echo "Year is NOT numeric." >&2; res=1 && exit ${res}
fi

exit 0
#-------------------------------------------------------------------------------------# 
#-------------------------------------------------------------------------------------#  

