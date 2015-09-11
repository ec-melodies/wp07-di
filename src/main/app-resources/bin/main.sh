#!/bin/sh
#-------------------------------------------------------------------------------------# 
# PURPOSE: Order
#-------------------------------------------------------------------------------------#
# variaveis de ambiente e pastas 
#-------------------------------------------------------------------------------------#  
chmod 777 ~/wp07-di/src/main/app-resources/bin/ini.sh
~/wp07-di/src/main/app-resources/bin/ini.sh
#-------------------------------------------------------------------------------------# 
#importar dados climaticos 
#-------------------------------------------------------------------------------------# 
chmod 777 ~/wp07-di/src/main/app-resources/bin/ISD1_CxDx/climatic_dataset_000001.sh
~/wp07-di/src/main/app-resources/bin/ISD1_CxDx/climatic_dataset_000001.sh
#-------------------------------------------------------------------------------------# 
# obter Cx.tif global
#-------------------------------------------------------------------------------------# 
chmod 777 ~/wp07-di/src/main/app-resources/bin/ISD1_CxDx/climatic_dataset_001001.sh
~/wp07-di/src/main/app-resources/bin/ISD1_CxDx/climatic_dataset_001001.sh 
#-------------------------------------------------------------------------------------# 
# CROP: Cx_i.tif, SPOT (NDV), LULC em VX
#-------------------------------------------------------------------------------------# 
chmod 777 ~/wp07-di/src/main/app-resources/bin/ISD0_crop/resample_crop_aoi_00100101.sh
~/wp07-di/src/main/app-resources/bin/ISD0_crop/resample_crop_aoi_00100101.sh
#-------------------------------------------------------------------------------------# 
# CROP: Cx_i.tif, SPOT (NIR, RED), LULC em SX
#-------------------------------------------------------------------------------------# 
chmod 777 ~/wp07-di/src/main/app-resources/bin/ISD0_crop/resample_crop_aoi_00100102.sh
~/wp07-di/src/main/app-resources/bin/ISD0_crop/resample_crop_aoi_00100102.sh
#-------------------------------------------------------------------------------------# 
# Cx_i.tif > Cx_i.dat 
# PURPOSE: Local static degradation CS(x)
#-------------------------------------------------------------------------------------# 
chmod 777 ~/wp07-di/src/main/app-resources/bin/ISD1_CxDx/climatic_dataset_001002.sh
~/wp07-di/src/main/app-resources/bin/ISD1_CxDx/climatic_dataset_001002.sh
#-------------------------------------------------------------------------------------# 
# obter Dx.tif global
#-------------------------------------------------------------------------------------# 
chmod 777 ~/wp07-di/src/main/app-resources/bin/ISD1_CxDx/climatic_dataset_002001.sh
~/wp07-di/src/main/app-resources/bin/ISD1_CxDx/climatic_dataset_002001.sh
#-------------------------------------------------------------------------------------# 
# CROP: Dx_i.tif 
#-------------------------------------------------------------------------------------# 
chmod 777 ~/wp07-di/src/main/app-resources/bin/ISD0_crop/resample_crop_aoi_00100201.sh
~/wp07-di/src/main/app-resources/bin/ISD0_crop/resample_crop_aoi_00100201.sh
#-------------------------------------------------------------------------------------# 
# Dx_i.tif > Dx_i.dat
#-------------------------------------------------------------------------------------# 
chmod 777 ~/wp07-di/src/main/app-resources/bin/ISD1_CxDx/climatic_dataset_002002.sh
~/wp07-di/src/main/app-resources/bin/ISD1_CxDx/climatic_dataset_002002.sh
#-------------------------------------------------------------------------------------# 
#Bx - Biophysic Component (Soft data)
#-------------------------------------------------------------------------------------#  
# LULC_i.tif _VX
#-------------------------------------------------------------------------------------# 
chmod 777 ~/wp07-di/src/main/app-resources/bin/ISD2_Vx/vgt_to_geoms_00001.sh
~/wp07-di/src/main/app-resources/bin/ISD2_Vx/vgt_to_geoms_00001.sh
#-------------------------------------------------------------------------------------# 
# LULC_i.tif _SX
#-------------------------------------------------------------------------------------# 
chmod 777 ~/wp07-di/src/main/app-resources/bin/ISD2_Vx/vgt_to_geoms_00002.sh
~/wp07-di/src/main/app-resources/bin/ISD2_Vx/vgt_to_geoms_00002.sh
#-------------------------------------------------------------------------------------#
#-------------------------------------------------------------------------------------# 
# Vx_i.tif 
#-------------------------------------------------------------------------------------# 
chmod 777 ~/wp07-di/src/main/app-resources/bin/ISD2_Vx/vgt_to_geoms_001.sh
~/wp07-di/src/main/app-resources/bin/ISD2_Vx/vgt_to_geoms_001.sh
#-------------------------------------------------------------------------------------#
# Sx_i.tif
#-------------------------------------------------------------------------------------#
chmod 777 ~/wp07-di/src/main/app-resources/bin/ISD2_Vx/vgt_to_geoms_002.sh
~/wp07-di/src/main/app-resources/bin/ISD2_Vx/vgt_to_geoms_002.sh
#-------------------------------------------------------------------------------------#
#-------------------------------------------------------------------------------------#
# Bx_i.tif > Bx_i.dat
#-------------------------------------------------------------------------------------#
chmod 777 ~/wp07-di/src/main/app-resources/bin/ISD2_Vx/vgt_to_geoms_003.sh
~/wp07-di/src/main/app-resources/bin/ISD2_Vx/vgt_to_geoms_003.sh
#-------------------------------------------------------------------------------------#
#-------------------------------------------------------------------------------------#
# COR_i.tif > COR_i.dat
#-------------------------------------------------------------------------------------#
chmod 777 ~/wp07-di/src/main/app-resources/bin/ISD2_Vx/vgt_to_geoms_004.sh
~/wp07-di/src/main/app-resources/bin/ISD2_Vx/vgt_to_geoms_004.sh
#-------------------------------------------------------------------------------------#
#-------------------------------------------------------------------------------------#
chmod 777 ~/wp07-di/src/main/app-resources/bin/ISD6_ISD/isd_cx001.sh
~/wp07-di/src/main/app-resources/bin/ISD6_ISD/isd_cx001.sh
#-------------------------------------------------------------------------------------#
chmod 777 ~/wp07-di/src/main/app-resources/bin/ISD6_ISD/isd_cx002.sh
~/wp07-di/src/main/app-resources/bin/ISD6_ISD/isd_cx002.sh
#-------------------------------------------------------------------------------------#
