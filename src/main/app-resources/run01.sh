#!/bin/bash
#-------------------------------------------------------------------------------------# 
# PURPOSE: input data from ESA
#-------------------------------------------------------------------------------------# 

# source the ciop functions (e.g. ciop-log)
source ${ciop_job_include}

echo WP07-DI
#-------------------------------------------------------------------------------------# 
export -p IDIR=/application
echo "path ~bin:" $IDIR

rm -rf /tmp/snap-mapred/*

# Setup environment variables
#chmod -R 777 /application/cli_block_a/bin/ini.sh
bash /application/cli_block_a/bin/ini.sh

export -p ODIR=/data/outDIR
export -p DIR=$ODIR/ISD
export -p OUTDIR=$DIR/ISD000 && cd $OUTDIR && echo $OUTDIR
export -p CXDIR=$IDIR/cli_block_a/bin
export -p SXDIR=$IDIR/bio_input_collecting/

ciop-log "creating tmp/dir: $OUTDIR" 


#-------------------------------------------------------------------------------------# 
while read Year; do

echo ${Year}

#------------------JOB----------------------------------------------------------------# 
ciop-log "INFO" "Generating AOI and year"

export -p IR="$( ciop-getparam aoi )"
ciop-log "AOI: $IR"

export -p Y2=${Year}
ciop-log "Year: ${Year}"

res=$? 

if echo "$Y2" | grep -qE ^\-?[0-9]?\.?[0-9]+$; then
if (($Y2 >=2000 && $Y2 <2018)) ; then 

   if (($Y2<=2003)) ; then
        export -p Y1=$(($Y2-20))
    	echo "20 years"
	echo $res

   else
    	export -p Y1=$(($Y2-25))
   	echo "25 years"
   	echo $res
   fi
else
   echo "erro: year <= 2000 or IBCS need new satellite images for 2018" >&2; res=2 && exit ${res}
   echo $res

fi
else
   echo "Year is NOT numeric." >&2; res=1 && exit ${res}
fi


echo "Here:" $Y2
cd $OUTDIR
echo "$Y1 $Y2" > $OUTDIR/AOI.txt
ciop-log "Generating $OUTDIR/AOI.txt"
#-------------------------------------------------------------------------------------# 
ciop-log "INFO" "Generating bio.tif and $IR"

#chmod -R 777 /application/bio_input_collecting/run.sh

fcx(){
years=$(awk '{print $1, $2}' $OUTDIR/AOI.txt)
exec $IDIR"/bio_input_collecting/run.sh" $Y2 $IR &
wait
exec $IDIR"/bio_block_p1/run.sh" $Y2 $IR &
wait 
exec $IDIR"/bio_block_a/run.sh" $Y2 $IR &
wait
exec $IDIR"/bio_block_p2/run.sh" $Y2 $IR   
}

ciop-log "INFO" "Generating ecmwf.dat"
#-------------------------------------------------------------------------------------# 
if [[ $IR == AOI1 ]] ; then
	echo "${AOI1=$(echo $Y1 $Y2 44.00 -9.75 36.00 3.50 0.75)}" 
	fcx
elif [[ $IR == AOI2 ]] ; then
	echo "${AOI2=$(echo $Y1 $Y2 37.5 -19.0 12.0 25.5 0.75)}" 
	fcx
elif [[ $IR == AOI3 ]] ; then
	echo "${AOI3=$(echo $Y1 $Y2 -9.0 21.0 -31.5 41.0 0.75)}" 
	fcx
elif [[ $IR == AOI4 ]] ; then
	echo "${AOI4=$(echo $Y1 $Y2 42.5 25.5 36.0 45.0 0.75)}" 
	fcx
else
	echo "AOI out of range"; res=4 && exit ${res}
fi 

#----------------ENDJOB----------------------------------------------------------------# 

done

exit 0

