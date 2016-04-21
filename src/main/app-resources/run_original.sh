#!/bin/bash
#-------------------------------------------------------------------------------------# 
# PURPOSE: input data from ECMWF
#-------------------------------------------------------------------------------------# 

# source the ciop functions (e.g. ciop-log)
source ${ciop_job_include}

echo WP07-DI
#-------------------------------------------------------------------------------------# 
export -p IDIR=/application
echo "path ~bin:" $IDIR

#bash $IDIR/cli_block_a/bin/ini.sh

export -p ODIR=/data/outDIR
export -p DIR=$ODIR/ISD
export -p OUTDIR=$DIR/ISD000 && cd $OUTDIR && echo $OUTDIR
export -p CXDIR=$IDIR/cli_block_a/bin/
export -p SXDIR=$IDIR/bio_input_collecting/

ciop-log "creating tmp/dir: $OUTDIR" 
#-------------------------------------------------------------------------------------# 
while read Year; do

echo ${Year}

#------------------JOB----------------------------------------------------------------# 
ciop-log "INFO" "Generating AOI and year"

IR="$( ciop-getparam aoi )"
ciop-log "AOI: $IR"

export -p Y2=${Year}
ciop-log "Year: ${Year}"

if ((Y2<=2003)) ; then
    export -p Y1=$(($Y2-20))
    echo "20 years"
else
    export -p Y1=$(($Y2-25))
    echo "25 years"
fi

echo "Here:" $Y2

cd $OUTDIR

echo $Y1 $Y2 > $OUTDIR/AOI.txt

ciop-log "Generating $OUTDIR/AOI.txt"


ciop-log "INFO" "Generating ecmwf.grib 00"

#-------------------------------------------------------------------------------------# 
if [[ $IR == AOI1 ]] ; then

	for file in $(eval echo {$Y2..$Y1..5}); do
	h=$(expr $file - 5)
	echo $h $file			
	echo "$h $file 44.00 -9.75 36.00 3.50 0.75" > $OUTDIR/AOI_$file.txt
	aoi=$(cat $OUTDIR/AOI_$file.txt ); echo "$aoi" 
	years=$(awk '{print $1, $2}' $OUTDIR/AOI_$file.txt)
	#bash $CXDIR"climatic_dataset_000001.sh" $h $file 44.00 -9.75 36.00 3.50 0.75
		
	done
elif [[ $IR == AOI2 ]] ; then

	for file in $(eval echo {$Y2..$Y1..5}); do
	h=$(expr $file - 5)
	echo $h $file			
	echo "$h $file 37.5 -19.0 12.0 25.5 0.75" > $OUTDIR/AOI_$file.txt
	aoi=$(cat $OUTDIR/AOI_$file.txt ); echo "$aoi" 
	years=$(awk '{print $1, $2}' $OUTDIR/AOI_$file.txt)
	#bash $CXDIR"climatic_dataset_000001.sh" $h $file 37.5 -19.0 12.0 25.5 0.75
		
	done

elif [[ $IR == AOI3 ]] ; then

	for file in $(eval echo {$Y2..$Y1..5}); do
	h=$(expr $file - 5)
	echo $h $file			
	echo "$h $file -9.0 21.0 -31.5 41.0 0.75" > $OUTDIR/AOI_$file.txt
	aoi=$(cat $OUTDIR/AOI_$file.txt ); echo "$aoi" 
	years=$(awk '{print $1, $2}' $OUTDIR/AOI_$file.txt)
	#bash $CXDIR"climatic_dataset_000001.sh" $h $file -9.0 21.0 -31.5 41.0 0.75
		
	done

elif [[ $IR == AOI4 ]] ; then
		
	for file in $(eval echo {$Y2..$Y1..5}); do
	h=$(expr $file - 5)
	echo $h $file			
	echo "$h $file 42.5 25.5 36.0 45.0 0.75" > $OUTDIR/AOI_$file.txt
	aoi=$(cat $OUTDIR/AOI_$file.txt ); echo "$aoi" 
	years=$(awk '{print $1, $2}' $OUTDIR/AOI_$file.txt)
	#bash $CXDIR"climatic_dataset_000001.sh" $h $file 42.5 25.5 36.0 45.0 0.75
		
	done	
else
	echo "AOI out of range"
fi 


ciop-log "INFO" "Generating ecmwf.grib 01"


fcx(){
years=$(awk '{print $1, $2}' $OUTDIR/AOI.txt)
#exec $CXDIR"climatic_dataset_001000.sh" $Y1 $Y2 &
#wait
#exec $CXDIR"climatic_dataset_001001.sh" $Y1 $Y2 &
#wait
#exec $CXDIR"climatic_dataset_001005.sh" &
#wait
#exec $CXDIR"climatic_dataset_002000.sh" $Y1 $Y2 &
#wait
#exec $CXDIR"climatic_dataset_002001.sh" $Y1 $Y2 &
#wait
#exec $CXDIR"climatic_dataset_002005.sh" &
#wait
#exec $SXDIR"run.sh" $Y2    
}

ciop-log "INFO" "Generating ecmwf.dat"
#-------------------------------------------------------------------------------------# 
if [[ $IR == AOI1 ]] ; then
	echo "${AOI1=$(echo $Y1 $Y2 44.00 -9.75 36.00 3.50 0.75)}" 
	fcx && igcx
elif [[ $IR == AOI2 ]] ; then
	echo "${AOI2=$(echo $Y1 $Y2 37.5 -19.0 12.0 25.5 0.75)}" 
	fcx && igcx
elif [[ $IR == AOI3 ]] ; then
	echo "${AOI3=$(echo $Y1 $Y2 -9.0 21.0 -31.5 41.0 0.75)}" 
	fcx && igcx
elif [[ $IR == AOI4 ]] ; then
	echo "${AOI4=$(echo $Y1 $Y2 42.5 25.5 36.0 45.0 0.75)}" 
	fcx && igcx
else
	echo "AOI out of range"
fi 


function igcx(){
exec $IDIR"bio_input_collecting/run.sh" $Y2 &
wait
exec $IDIR"bio_block_p1/run.sh" $Y2 &
wait 
exec $IDIR"bio_block_a/run.sh" $Y2 &
wait
exec $IDIR"bio_block_p2/run.sh" $Y2 & 
wait
exec $IDIR"processing_block_p/run.sh" $Y2 &
wait 
exec $IDIR"processing_block_a/run.sh" $Y2
}
igcx


#----------------ENDJOB----------------------------------------------------------------# 

done

exit 0
