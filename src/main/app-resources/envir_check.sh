#### JOB1
## Environment settings for a grass 

export GRASSDB=/data/GRASSdb_ISD/
export LOCATION=World
export MAPSET=Europe
export RES=$1   
 
echo "LOCATION_NAME: $LOCATION"    >  $HOME/.grassrc6_$$
echo "MAPSET: $MAPSET"             >> $HOME/.grassrc6_$$
echo "DIGITIZER: none"             >> $HOME/.grassrc6_$$
echo "GRASS_GUI: text"             >> $HOME/.grassrc6_$$
echo "GISDBASE: $GRASSDB"          >> $HOME/.grassrc6_$$
 
#   path to GRASS binaries and libraries:
export GISBASE=/usr/lib64/grass-6.4.4
export PATH=$PATH:$GISBASE/bin:$GISBASE/scripts
export LD_LIBRARY_PATH="$GISBASE/lib"
export GISRC=~/.grassrc6_$$
export GIS_LOCK=$$  
