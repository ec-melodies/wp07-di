#!/bin/bash
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
export -p uuid_r=$ZDIR/uuid.txt
export -p uuid_ulr=$ZDIR/INFOISD.txt
export -p jobid="$( ciop-getparam JobID )"
ciop-log "jobid: $jobid"
export -p jobid='2010'

export -p y1=$(awk '{print $1}' $OUTDIR/AOI.txt)
echo $y1
export -p y2=$(awk '{print $2}' $OUTDIR/AOI.txt)
echo $y2

#-------------------------------------------------------------------------------------# 
#AOI="$( ciop-getparam aoi )"
#ciop-log "INFO" "AOI: $AOI"

#export -p AOI=$1
#echo $AOI

export -p AOI=$(awk '{print $1}' $OUTDIR/AOI0.txt)
echo $AOI
#-------------------------------------------------------------------------------------# 
export -p D=$(date +"%d%m%Y")
echo $D

export -p INISD0=IBCS_${D}_${AOI}_${y1}${y2}
#-------------------------------------------------------------------------------------# 
export -p INISD1=$ZDIR/BIVD1_${D}_${AOI}_${y1}${y2}.tif
export -p INISD2=$ZDIR/BIVD2_${D}_${AOI}_${y1}${y2}.tif
export -p INISD3=$ZDIR/IBCS_${D}_${AOI}_${y1}${y2}.tif
#-------------------------------------------------------------------------------------# 
#-------------------------------------------------------------------------------------# 
R --vanilla --no-readline   -q  --min-vsize=10M --min-nsize=500k <<'EOF'

# set working directory
ISDC = Sys.getenv(c('ISDC'))
ISDD = Sys.getenv(c('ISDD'))
ZDIR= Sys.getenv(c('ZDIR'))
tmp.file =Sys.getenv(c('INISD3'))
tmp.file

load("/application/parameters/WSP.RData")
xlist <- c("raster", "sp", "zoo", "rciop", "gtools", "digest", "rgdal",
"uuid", "RColorBrewer", "colorRamps", "rasterVis", "RStoolbox")
lapply(xlist, library, character.only = TRUE)

 
# create a list from these files

setwd(ISDC)
isd00<-list.files(pattern=paste("ISD_Cx002MSCAOI",".*\\.tif",sep=""))
isd01<-raster(isd00)

setwd(ISDD)
isd00<-list.files(pattern=paste("ISD_Dx002MSCAOI",".*\\.tif",sep=""))
isd02<-raster(isd00)

setwd(ZDIR)

isd03<- function(x01,x02) {(0.5*x01+0.5*x02)}
isd04<- isd03(isd01,isd02)

rm(isd02)
rm(isd01)

gprj <- "+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs"
isd05<-projectRaster(isd04,  crs = gprj)

rm(isd04)

writeRaster(isd05,filename=tmp.file,format="GTiff",datatype='FLT8S',overwrite=TRUE)

EOF
#-------------------------------------------------------------------------------------# 
# publish the result

ciop-publish -m $INISD3
#s3cmd put --recursive $INISD3 s3://melodies-wp7/
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
            <sld:Name>IBCSI</sld:Name>
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
                            <sld:ColorMapEntry color="#2b81e4" label="Low Susceptibility" opacity="1.0" quantity="0"/>
                            <sld:ColorMapEntry color="#e2e82c" label="Medium Susceptibility" opacity="1.0" quantity="0.64"/>
                            <sld:ColorMapEntry color="#fd7b03" label="High Susceptibility" opacity="1.0" quantity="0.74"/>
                            <sld:ColorMapEntry color="#ff1f07" label="Very High Susceptibility" opacity="1.0" quantity="1"/>
                        </sld:ColorMap>
                    </sld:RasterSymbolizer>
                </sld:Rule>
            </sld:FeatureTypeStyle>
        </sld:UserStyle>
    </sld:UserLayer>
</sld:StyledLayerDescriptor>
EOF`

echo $isd_style > $ZDIR/BISD.sld
#-------------------------------------------------------------------------------------# 
#-------------------------------------------------------------------------------------# 
R --vanilla --no-readline -q --min-vsize=10M --min-nsize=500k <<'EOF'
ZDIR = Sys.getenv(c('ZDIR'))
ZDIR
Y1 = Sys.getenv(c('y1'))
Y2 = Sys.getenv(c('y2'))

setwd(ZDIR)
getwd()

options(max.print=99999999) 
options("scipen"=100, "digits"=4)

load("/application/parameters/WSP.RData")
xlist <- c("raster", "sp", "zoo", "rciop", "gtools", "digest", "rgdal",
"uuid", "RColorBrewer", "colorRamps", "rasterVis", "RStoolbox")
lapply(xlist, library, character.only = TRUE)


uuid<-UUIDgenerate(TRUE)
capture.output(uuid, file=paste(ZDIR,'/','uuid','.txt',sep = ""), append=FALSE)

TPmlist01<-mixedsort(list.files(pattern=paste("IBCS_",".*\\.tif",sep="")))
TPmlist01

rb=raster(paste(ZDIR,'/',TPmlist01[[1]] ,sep = ""))
rb
capture.output(rb, file=paste(ZDIR,'/','INFOISD.txt',sep = ""), append=FALSE)

bist<-rb

a<-strsplit(bist@file@name,"_")
b=unlist(a)[3]

if ( b=="AOI1") {

   print(b)
} else if ( b=="AOI2") {

   print(b)
} else if ( b=="AOI3") {

   print(b)
} else if ( b=="AOI4") {

   print(b)
} else
   print("out of range")

   
pal.1 <- colorRampPalette(c("blue", "cyan", "yellow", "red"), bias=1)
pdf(paste(ZDIR,"/","BIST.pdf", sep=""), width = 10, height = 10)
plot(bist, col=pal.1(100), zlim = c(0,1), main=paste("IBCSI/ ",b,":",Y1,"-", Y2, "\nMELODIES: Exploiting Open Data", sep=""))
legend("bottomright",inset=0.05,"Projection: EPSG: 4326\nMore Information:\nwww.melodiesproject.eu", bty="n", cex=0.8)
grid()
dev.off()


pal.2 <- colorRampPalette(c("grey100", "grey0"))
pdf(paste(ZDIR,"/","BIST_grey.pdf", sep=""), width = 10, height = 10)
plot(bist, col=pal.2(100), zlim = c(0,1), main=paste("IBCSI/ ",b,":",Y1,"-", Y2, "\nMELODIES: Exploiting Open Data", sep=""))
legend("bottomright",inset=0.05,"Projection: EPSG: 4326\nMore Information:\nwww.melodiesproject.eu", bty="n", cex=0.8)
grid()
dev.off()

EOF

#-------------------------------------------------------------------------------------#
cp $ZDIR/BIST_grey.pdf $ZDIR/INFO_${INISD0}_grey.pdf
cp $ZDIR/BIST.pdf $ZDIR/INFO_${INISD0}_color.pdf

ciop-publish -m $ZDIR/INFO_${INISD0}_color.pdf
ciop-publish -m $ZDIR/INFO_${INISD0}_grey.pdf

rm $ZDIR/BIST_grey.pdf
rm $ZDIR/BIST.pdf
#-------------------------------------------------------------------------------------# 
#export -p uuid_r2="fba5df3a-1ce0-11e6-8c4d-02000a0f1b19"
#export -p uuid0=$(echo $uuid_r2  | awk '{ gsub ("[(),]","") ; print  $1 }')
#echo $uuid0
#-------------------------------------------------------------------------------------# 
# In R
export -p uuid0=$(cat $uuid_r  | awk '{ gsub ("[(),]","") ; print  $2 }')
export -p uuid1=$(echo $uuid0 | sed 's/[\"]//g')
echo $uuid1
#-------------------------------------------------------------------------------------# 
export -p D1=$(date +"%Y-%m-%d")
#-------------------------------------------------------------------------------------# 
ulx=$(cat $uuid_ulr | grep "extent" | awk '{ gsub ("[(),]","") ; print  $3 }')
uly=$(cat $uuid_ulr  | grep "extent" | awk '{ gsub ("[(),]","") ; print  $6 }')
lrx=$(cat $uuid_ulr  | grep "extent" | awk '{ gsub ("[(),]","") ; print  $4 }')
lry=$(cat $uuid_ulr  | grep "extent" | awk '{ gsub ("[(),]","") ; print  $5 }')

echo $ulx $uly $lrx $lry 

export -p INDICADOR=$(echo The Integrated Biophysical and Climatic Susceptibility)
export -p contact=$(echo Alzira Ramos)
export -p organisation_Name=$(echo Instituto Superior Técnico / Centro de Recursos Naturais e Ambiente)
export -p email=$(echo alzira.ramos@tecnico.ulisboa.pt)
export -p web_organisation=$(echo https://tecnico.ulisboa.pt/)
export -p resolution=$(echo 0.0027800)
export -p address_organisation=$(echo Av. Rovisco Pais)
export -p city_organisation=$(echo Lisboa)
export -p postalCode_organisation=$(echo 1049-001)
export -p country_organisation=$(echo Portugal)
#-------------------------------------------------------------------------------------# 
metadata_BVDI=`cat <<EOF	
<?xml version="1.0" ?>
<?xml version="1.0" encoding="utf-8"?>
<!-- Melodies -->
<gmd:MD_Metadata xmlns:gss="http://www.isotc211.org/2005/gss" xmlns:gsr="http://www.isotc211.org/2005/gsr" xmlns:gco="http://www.isotc211.org/2005/gco" xmlns:gml="http://www.opengis.net/gml/3.2" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:gts="http://www.isotc211.org/2005/gts" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:srv="http://www.isotc211.org/2005/srv" xmlns:gmx="http://www.isotc211.org/2005/gmx" xmlns:gmd="http://www.isotc211.org/2005/gmd">
  <gmd:fileIdentifier>
    <gco:CharacterString>${uuid1}</gco:CharacterString>
  </gmd:fileIdentifier>
  <gmd:language>
    <gmd:LanguageCode codeList="http://www.loc.gov/standards/iso639-2/php/code_list.php" codeListValue="eng">eng</gmd:LanguageCode>
  </gmd:language>
  <gmd:characterSet>
    <gmd:MD_CharacterSetCode codeList="http://standards.iso.org/ittf/PubliclyAvailableStandards/ISO_19139_Schemas/resources/codelist/gmxCodelists.xml#MD_CharacterSetCode" codeListValue="utf8">utf8</gmd:MD_CharacterSetCode>
  </gmd:characterSet>
  <gmd:hierarchyLevel>
    <gmd:MD_ScopeCode codeList="http://standards.iso.org/ittf/PubliclyAvailableStandards/ISO_19139_Schemas/resources/codelist/gmxCodelists.xml#MD_ScopeCode" codeListValue="dataset">dataset</gmd:MD_ScopeCode>
  </gmd:hierarchyLevel>
  <gmd:contact>
    <gmd:CI_ResponsibleParty>
      <gmd:individualName>
        <gco:CharacterString>${contact}</gco:CharacterString>
      </gmd:individualName>
      <gmd:organisationName>
        <gco:CharacterString>${organisation_Name} </gco:CharacterString>
      </gmd:organisationName>
      <gmd:contactInfo>
        <gmd:CI_Contact>
          <gmd:address>
            <gmd:CI_Address>
              <gmd:deliveryPoint>
                <gco:CharacterString>${address_organisation}</gco:CharacterString>
              </gmd:deliveryPoint>
              <gmd:city>
                <gco:CharacterString>${city_organisation}</gco:CharacterString>
              </gmd:city>
              <gmd:postalCode>
                <gco:CharacterString>${postalCode_organisation}</gco:CharacterString>
              </gmd:postalCode>
              <gmd:country>
                <gco:CharacterString>${country_organisation}</gco:CharacterString>
              </gmd:country>
              <gmd:electronicMailAddress>
                <gco:CharacterString>${email}</gco:CharacterString>
              </gmd:electronicMailAddress>
            </gmd:CI_Address>
          </gmd:address>
          <gmd:onlineResource>
            <gmd:CI_OnlineResource>
              <gmd:linkage>
                <gmd:URL>${web_organisation}</gmd:URL>
              </gmd:linkage>
            </gmd:CI_OnlineResource>
          </gmd:onlineResource>
        </gmd:CI_Contact>
      </gmd:contactInfo>
      <gmd:role>
        <gmd:CI_RoleCode codeList="http://www.isotc211.org/2005/resources/Codelist/gmxCodelists.xml#CI_RoleCode" codeListValue="pointOfContact">pointOfContact</gmd:CI_RoleCode>
      </gmd:role>
    </gmd:CI_ResponsibleParty>
  </gmd:contact>
  <gmd:dateStamp>
    <gco:Date>${D1}</gco:Date>
  </gmd:dateStamp>
  <gmd:metadataStandardName>
    <gco:CharacterString>ISO 19115 Sistema de Metadados Melodies WP7 - BVDI</gco:CharacterString>
  </gmd:metadataStandardName>
  <gmd:metadataStandardVersion>
    <gco:CharacterString>v.0.1</gco:CharacterString>
  </gmd:metadataStandardVersion>
  <gmd:referenceSystemInfo>
    <gmd:MD_ReferenceSystem>
      <gmd:referenceSystemIdentifier>
        <gmd:RS_Identifier>
          <gmd:code>
            <gco:CharacterString>4326</gco:CharacterString>
          </gmd:code>
          <gmd:codeSpace>
            <gco:CharacterString>EPSG</gco:CharacterString>
          </gmd:codeSpace>
        </gmd:RS_Identifier>
      </gmd:referenceSystemIdentifier>
    </gmd:MD_ReferenceSystem>
  </gmd:referenceSystemInfo>
  <gmd:identificationInfo>
    <gmd:MD_DataIdentification>
      <gmd:abstract>
        <gco:CharacterString>${INDICADOR}</gco:CharacterString>
      </gmd:abstract>
      <gmd:descriptiveKeywords>
        <gmd:MD_Keywords>
          <gmd:keyword>
            <gmx:Anchor xlink:type="simple" xlink:href="http://vocab.nerc.ac.uk/collection/P13/current/GTER0033/">Drought/Precipitation Indices</gmx:Anchor>
          </gmd:keyword>
          <gmd:keyword>
            <gmx:Anchor xlink:type="simple" xlink:href="http://vocab.nerc.ac.uk/collection/P14/current/GVAR0916/">Vegetation Index</gmx:Anchor>
          </gmd:keyword>
          <gmd:thesaurusName>
            <gmd:CI_Citation>
              <gmd:title>
                <gco:CharacterString>Global Change Master Directory Science Keyword terms</gco:CharacterString>
              </gmd:title>
              <gmd:date>
                <gmd:CI_Date>
                  <gmd:date>
                    <gco:Date>2007-04-18</gco:Date>
                  </gmd:date>
                  <gmd:dateType>
                    <gmd:CI_DateTypeCode codeList="http://standards.iso.org/ittf/PubliclyAvailableStandards/ISO_19139_Schemas/resources/Codelist/ML_gmxCodelists.xml#CI_DateTypeCode" codeListValue="revision">revision</gmd:CI_DateTypeCode>
                  </gmd:dateType>
                </gmd:CI_Date>
              </gmd:date>
              <gmd:edition>
                <gco:CharacterString>4</gco:CharacterString>
              </gmd:edition>
            </gmd:CI_Citation>
          </gmd:thesaurusName>
        </gmd:MD_Keywords>
		</gmd:descriptiveKeywords>
      <gmd:descriptiveKeywords>
        <gmd:MD_Keywords>
          <gmd:keyword>
            <gmx:Anchor xlink:type="simple" xlink:href="http://vocab.nerc.ac.uk/collection/P14/current/GVAR0459/">Land Use Classes</gmx:Anchor>
          </gmd:keyword>
          <gmd:keyword>
            <gmx:Anchor xlink:type="simple" xlink:href="http://vocab.nerc.ac.uk/collection/P14/current/GVAR0451/">Land Cover</gmx:Anchor>
          </gmd:keyword>
          <gmd:thesaurusName>
            <gmd:CI_Citation>
              <gmd:title>
                <gco:CharacterString>Global Change Master Directory Science Keyword variables</gco:CharacterString>
              </gmd:title>
              <gmd:date>
                <gmd:CI_Date>
                  <gmd:date>
                    <gco:Date>2007-04-18</gco:Date>
                  </gmd:date>
                  <gmd:dateType>
                    <gmd:CI_DateTypeCode codeList="http://standards.iso.org/ittf/PubliclyAvailableStandards/ISO_19139_Schemas/resources/Codelist/ML_gmxCodelists.xml#CI_DateTypeCode" codeListValue="revision">revision</gmd:CI_DateTypeCode>
                  </gmd:dateType>
                </gmd:CI_Date>
              </gmd:date>
              <gmd:edition>
                <gco:CharacterString>4</gco:CharacterString>
              </gmd:edition>
            </gmd:CI_Citation>
          </gmd:thesaurusName>
        </gmd:MD_Keywords>
      </gmd:descriptiveKeywords>
      <gmd:descriptiveKeywords>
        <gmd:MD_Keywords>
          <gmd:keyword>
            <gmx:Anchor xlink:type="simple" xlink:href="http://vocab.nerc.ac.uk/collection/P13/current/GTER0061/">Land Use/Land Cover</gmx:Anchor>
          </gmd:keyword>
          <gmd:thesaurusName>
            <gmd:CI_Citation>
              <gmd:title>
                <gco:CharacterString>Global Change Master Directory Science Keyword terms</gco:CharacterString>
              </gmd:title>
              <gmd:date>
                <gmd:CI_Date>
                  <gmd:date>
                    <gco:Date>2007-04-18</gco:Date>
                  </gmd:date>
                  <gmd:dateType>
                    <gmd:CI_DateTypeCode codeList="http://standards.iso.org/ittf/PubliclyAvailableStandards/ISO_19139_Schemas/resources/Codelist/ML_gmxCodelists.xml#CI_DateTypeCode" codeListValue="revision">revision</gmd:CI_DateTypeCode>
                  </gmd:dateType>
                </gmd:CI_Date>
              </gmd:date>
              <gmd:edition>
                <gco:CharacterString>4</gco:CharacterString>
              </gmd:edition>
            </gmd:CI_Citation>
          </gmd:thesaurusName>
        </gmd:MD_Keywords>
      </gmd:descriptiveKeywords>			
      <gmd:spatialResolution>
        <gmd:MD_Resolution>
          <gmd:distance>
            <gco:Distance uom="urn:ogc:def:uom:EPSG::9001">${resolution_metre}</gco:Distance>
          </gmd:distance>
        </gmd:MD_Resolution>
      </gmd:spatialResolution>
      <gmd:language>
        <gmd:LanguageCode codeList="http://www.loc.gov/standards/iso639-2/php/code_list.php" codeListValue="eng">eng</gmd:LanguageCode>
      </gmd:language>
      <gmd:language>
        <gmd:LanguageCode codeList="http://www.loc.gov/standards/iso639-2/php/code_list.php" codeListValue="por">por</gmd:LanguageCode>
      </gmd:language>
      <gmd:topicCategory>
        <gmd:MD_TopicCategoryCode>biota</gmd:MD_TopicCategoryCode>
      </gmd:topicCategory>
      <gmd:topicCategory>
        <gmd:MD_TopicCategoryCode>climatologyMeteorologyAtmosphere</gmd:MD_TopicCategoryCode>
      </gmd:topicCategory>
      <gmd:topicCategory>
        <gmd:MD_TopicCategoryCode>environment</gmd:MD_TopicCategoryCode>
      </gmd:topicCategory>
      <gmd:topicCategory>
        <gmd:MD_TopicCategoryCode>geoscientificInformation</gmd:MD_TopicCategoryCode>
      </gmd:topicCategory>
      <gmd:extent>
        <gmd:EX_Extent>
          <gmd:geographicElement>
            <gmd:EX_GeographicBoundingBox>
              <gmd:westBoundLongitude>
                <gco:Decimal>${ulx}</gco:Decimal>
              </gmd:westBoundLongitude>
              <gmd:eastBoundLongitude>
                <gco:Decimal>${lrx}</gco:Decimal>
              </gmd:eastBoundLongitude>
              <gmd:southBoundLatitude>
                <gco:Decimal>${lry}</gco:Decimal>
              </gmd:southBoundLatitude>
              <gmd:northBoundLatitude>
                <gco:Decimal>${uly}</gco:Decimal>
              </gmd:northBoundLatitude>
            </gmd:EX_GeographicBoundingBox>
          </gmd:geographicElement>
          <gmd:temporalElement>
            <gmd:EX_TemporalExtent>
              <gmd:extent>
                <gml:TimePeriod gml:id="_2eb51d83-1845-4dd6-adfb-3ac6e814c6db">
                  <gml:beginPosition>${y1}</gml:beginPosition>
                  <gml:endPosition>${y2}</gml:endPosition>
                </gml:TimePeriod>
              </gmd:extent>
            </gmd:EX_TemporalExtent>
          </gmd:temporalElement>
        </gmd:EX_Extent>
      </gmd:extent>
    </gmd:MD_DataIdentification>
  </gmd:identificationInfo>
  <gmd:distributionInfo>
    <gmd:MD_Distribution>
      <gmd:distributionFormat>
        <gmd:MD_Format>
          <gmd:name>
            <gco:CharacterString>TIFF</gco:CharacterString>
          </gmd:name>
          <gmd:version>
            <gco:CharacterString>01</gco:CharacterString>
          </gmd:version>
        </gmd:MD_Format>
      </gmd:distributionFormat>
      <gmd:transferOptions>
        <gmd:MD_DigitalTransferOptions>
          <gmd:onLine>
            <gmd:CI_OnlineResource>
              <gmd:linkage>
                <gmd:URL>http://melodiesproject.eu/node/36</gmd:URL>
              </gmd:linkage>
              <gmd:function>
                <gmd:CI_OnLineFunctionCode codeList="http://standards.iso.org/ittf/PubliclyAvailableStandards/ISO_19139_Schemas/resources/Codelist/gmxCodelists.xml#CI_OnLineFunctionCode" codeListValue="information">information</gmd:CI_OnLineFunctionCode>
              </gmd:function>
            </gmd:CI_OnlineResource>
          </gmd:onLine>
        </gmd:MD_DigitalTransferOptions>
      </gmd:transferOptions>
    </gmd:MD_Distribution>
  </gmd:distributionInfo>
  <gmd:dataQualityInfo>
    <gmd:DQ_DataQuality>
      <gmd:scope>
        <gmd:DQ_Scope>
          <gmd:level>
            <gmd:MD_ScopeCode codeList="http://standards.iso.org/ittf/PubliclyAvailableStandards/ISO_19139_Schemas/resources/codelist/gmxCodelists.xml#MD_ScopeCode" codeListValue="dataset">dataset</gmd:MD_ScopeCode>
          </gmd:level>
        </gmd:DQ_Scope>
      </gmd:scope>
      <gmd:lineage>
        <gmd:LI_Lineage>
          <gmd:statement>
            <gco:CharacterString>n/a</gco:CharacterString>
          </gmd:statement>
        </gmd:LI_Lineage>
      </gmd:lineage>
    </gmd:DQ_DataQuality>
  </gmd:dataQualityInfo>
</gmd:MD_Metadata>
EOF`

echo $metadata_BVDI > $ZDIR/INFO_${INISD0}.xml

ciop-publish -m $ZDIR/INFO_${INISD0}.xml

#-------------------------------------------------------------------------------------# 
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
file = os.environ['INISD3']
print file
stfile = os.path.join(tdir,'BISD.sld') 

# get the geoserver access point
username = os.environ['username_geoserver']
passw = 'changeme'
host = os.environ['host_geoserver']
print host
workspace = os.environ['workspace_geoserver']
gfile =os.environ['INISD0']
style='BISD_class'

jobid=os.environ['jobid']

subprocess.call("curl -v -u \""+username+":"+passw+"\" -XPUT -H \"Content-type:image/tiff\" --data-binary @"+file+" "+host+"/workspaces/"+workspace+"/coveragestores/"+jobid+"--"+gfile+"/file.geotiff", shell=True)
subprocess.call("curl -v -u \""+username+":"+passw+"\" -XPUT -H \"Content-type:application/xml\" -d \"<coverage><title>"+gfile+"</title><enabled>true</enabled><advertised>true</advertised></coverage>\" "+host+"/workspaces/"+workspace+"/coveragestores/"+jobid+"--"+gfile+"/coverages/"+jobid+"--"+gfile+".xml", shell=True)
subprocess.call("curl -v -u \""+username+":"+passw+"\" -XPUT -H \"Content-type:application/xml\" -d \"<layer><defaultStyle><name>"+workspace+":"+style+"</name></defaultStyle><enabled>false</enabled><styles><style><name>raster</name></style><style><name>raster</name></style></styles><advertised>true</advertised></layer>\" "+host+"/layers/"+jobid+"--"+gfile+".xml", shell=True)

EOF


#-------------------------------------------------------------------------------------#

rm -rf /data/outDIR/ISD/ISD000

#-------------------------------------------------------------------------------------#
ciop-log "INFO" "Step01: isd_vx001.sh" 
#-------------------------------------------------------------------------------------#
echo "DONE"
echo 0
