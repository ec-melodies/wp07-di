# #!/bin/bash
#-------------------------------------------------------------------------------------# 
# PURPOSE: ISD
#-------------------------------------------------------------------------------------# 
# Requires:
# awk
# gdal_calc
# ciop
#-------------------------------------------------------------------------------------# 
# source the ciop functions
source ${ciop_job_include}
#-------------------------------------------------------------------------------------# 
# the environment variables 
anaconda=/opt/anaconda/bin/
export PATH=/opt/anaconda/bin/:$PATH
#-------------------------------------------------------------------------------------# 
export -p DIR=/data/outDIR/ISD
export -p OUTDIR=$DIR/ISD000
export -p ZDIR=$OUTDIR/GEOMS
export -p ISDC=$ZDIR/Cx
export -p ISDD=$ZDIR/Dx

export -p isd_style=$ZDIR/isd_style.sld
#-------------------------------------------------------------------------------------# 
AOI="$( ciop-getparam aoi )"
ciop-log "INFO" "AOI: $AOI"
#-------------------------------------------------------------------------------------# 
export -p D=$(date +"%d%m%Y")

for file in $ISDC/ISD_Cx002MSCAOI*.tif; do 
filename=$(basename $file .tif )
isd01=$ISDC/${filename}.tif
isd02=$ISDD/${filename/#ISD_Cx002MSCAOI/ISD_Dx002MSCAOI}.tif 
gdal_calc.py -A $isd01 -B $isd02 --outfile=$ZDIR/ISD_${D}_$AOI.tif --calc="((0.5*A)+(0.5*B))*10000" --NoDataValue=0 --overwrite  --type=UInt32

export -p INISD=$ZDIR/ISD_${D}_$AOI
export -p INISD2=$ZDIR/ISD_${D}_$AOI.tif
# publish the result

ciop-publish -m $ZDIR/ISD_${D}_$AOI.tif
#s3cmd put --recursive $ZDIR/ISD_${D}_$AOI.tif s3://melodies-wp7/
done
#-------------------------------------------------------------------------------------# 
#-------------------------------------------------------------------------------------# 
#-------------------------------------------------------------------------------------# 
ciop-log "INFO" "Upload_to_geoserver"
#-------------------------------------------------------------------------------------# 
isd_style=`cat <<EOF	
<?xml version="1.0" ?>
<sld:StyledLayerDescriptor version="1.0.0" xmlns="http://www.opengis.net/sld" xmlns:gml="http://www.opengis.net/gml" xmlns:ogc="http://www.opengis.net/ogc" xmlns:sld="http://www.opengis.net/sld">
    <sld:UserLayer>
        <sld:LayerFeatureConstraints>
            <sld:FeatureTypeConstraint/>
        </sld:LayerFeatureConstraints>
        <sld:UserStyle>
            <sld:Name>${INISD}</sld:Name>
            <sld:Title/>
            <sld:FeatureTypeStyle>
                <sld:Name/>
                <sld:Rule>
                    <sld:RasterSymbolizer>
                        <sld:Geometry>
                            <ogc:PropertyName>grid</ogc:PropertyName>
                        </sld:Geometry>
                        <sld:Opacity>1</sld:Opacity>
                        <sld:ColorMap>
                            <sld:ColorMapEntry color="#2b83ba" label="0.000000" opacity="1.0" quantity="0"/>
                            <sld:ColorMapEntry color="#80bfab" label="0.166667" opacity="1.0" quantity="0.166667"/>
                            <sld:ColorMapEntry color="#c7e8ad" label="0.333333" opacity="1.0" quantity="0.333333"/>
                            <sld:ColorMapEntry color="#ffffbf" label="0.500000" opacity="1.0" quantity="0.5"/>
                            <sld:ColorMapEntry color="#fdc980" label="0.666667" opacity="1.0" quantity="0.666667"/>
                            <sld:ColorMapEntry color="#f07c4a" label="0.833333" opacity="1.0" quantity="0.833333"/>
                            <sld:ColorMapEntry color="#d7191c" label="1.000000" opacity="1.0" quantity="1"/>
                        </sld:ColorMap>
                    </sld:RasterSymbolizer>
                </sld:Rule>
            </sld:FeatureTypeStyle>
        </sld:UserStyle>
    </sld:UserLayer>
</sld:StyledLayerDescriptor>
EOF`

echo $isd_style > $ZDIR/isd_style.sld

#-------------------------------------------------------------------------------------# 
#-------------------------------------------------------------------------------------# 
# Em construcao...
# Upload_to_geoserver
#-------------------------------------------------------------------------------------# 
# Credenciais para geoserver
#=`cat <<EOF	
export -p host_geoserver='http://geoserver.melodies.terradue.int/geoserver/rest'
export -p workspace_geoserver='melodies-wp7'
export -p username_geoserver='melodies-wp7'
#EOF`
#echo $variables_geoserver > $ZDIR/variables_geoserver.txt
#-------------------------------------------------------------------------------------# 
cat <<EOF | /opt/anaconda/bin/python - 
import os
import sys
from sys import argv
import subprocess
import cioppy
import urllib

sys.path.append('ZDIR')
D=int(os.environ['D'])
tdir=os.environ['ZDIR']
file = os.environ['INISD2']

# get the geoserver access point
username = os.environ['username_geoserver']
passw = 'changeme'
host = os.environ['host_geoserver']
print host
workspace = os.environ['workspace_geoserver']
#img.name = sub(".tif", "", basename(ISD)) 
gfile = os.environ['isd_style']
style=gfile
jobid = '2010'

subprocess.call("curl -v -u \""+username+":"+passw+"\" -XPUT -H \"Content-type:image/tiff\" --data-binary @"+file+" "+host+"/workspaces/"+workspace+"/coveragestores/"+jobid+"--"+gfile[:-9]+"/file.geotiff", shell=True)
subprocess.call("curl -v -u \""+username+":"+passw+"\" -XPUT -H \"Content-type:application/xml\" -d \"<coverage><title>"+gfile[:-9]+"</title><enabled>true</enabled><advertised>true</advertised></coverage>\" "+host+"/workspaces/"+workspace+"/coveragestores/"+jobid+"--"+gfile[:-9]+"/coverages/"+jobid+"--"+gfile[:-9]+".xml", shell=True)
subprocess.call("curl -v -u \""+username+":"+passw+"\" -XPUT -H \"Content-type:application/xml\" -d \"<layer><defaultStyle><name>"+workspace+":"+style+"</name></defaultStyle><enabled>false</enabled><styles><style><name>raster</name></style><style><name>raster</name></style></styles><advertised>true</advertised></layer>\" "+host+"/layers/"+jobid+"--"+gfile[:-9]+".xml", shell=True)

EOF
#-------------------------------------------------------------------------------------#
#-------------------------------------------------------------------------------------#
ciop-log "INFO" "Step01: isd_vx001.sh" 
#-------------------------------------------------------------------------------------#
echo "DONE"
echo 0