#!/bin/csh
#

# Note
# 2015.01.28: This file is not updated and used

set echo
echo "-------------------------------------------------------------------------"
echo "--- Here is the gen_be_wps.csh ------------------------------------------"
echo "-------------------------------------------------------------------------"

set WPS_LON						= $1
set WPS_LAT						= $2
set DXDY_D01					= $3
set E_WE_D01					= $4
set E_SN_D01					= $5
set WPS_START_DATE			= $6
set WPS_END_DATE				= $7
set PROGRAM_DIR				= $8
set WPS_FNL_DIR				= $9
set MAX_DOM						= 1


mkdir gen_be/wps
cd gen_be/wps

# Process of date
# ---------------
	set yyyy1 = `echo $WPS_START_DATE | cut -c1-4`
	set   mm1 = `echo $WPS_START_DATE | cut -c5-6`
	set   dd1 = `echo $WPS_START_DATE | cut -c7-8`
	set   hh1 = `echo $WPS_START_DATE | cut -c9-10`
	
	set yyyy2 = `echo $WPS_END_DATE | cut -c1-4`
	set   mm2 = `echo $WPS_END_DATE | cut -c5-6`
	set   dd2 = `echo $WPS_END_DATE | cut -c7-8`
	set   hh2 = `echo $WPS_END_DATE | cut -c9-10`

ln -sf ${PROGRAM_DIR}/wps/WPSV3.4/geogrid .
ln -sf ${PROGRAM_DIR}/wps/WPSV3.4/metgrid .
ln -sf ${PROGRAM_DIR}/wps/WPSV3.4/ungrib .
ln -sf ./geogrid/src/geogrid.exe .
ln -sf ./ungrib/src/ungrib.exe .
ln -sf ./metgrid/src/metgrid.exe .
cp ${PROGRAM_DIR}/wps/WPSV3.4/link_grib.csh .
cp ${PROGRAM_DIR}/wps/WPSV3.4/util/plotgrids.ncl .
ln -sf ./ungrib/Variable_Tables/Vtable.GFS Vtable

cat >! namelist.wps << EOF
 &share
 wrf_core = 'ARW',
 max_dom = 1,
 start_date = '${yyyy1}-${mm1}-${dd1}_${hh1}:00:00','${yyyy1}-${mm1}-${dd1}_${hh1}:00:00','2000-01-01_00:00:00',
 end_date   = '${yyyy2}-${mm2}-${dd2}_${hh2}:00:00','${yyyy2}-${mm2}-${dd2}_${hh2}:00:00','2000-01-06_00:00:00',
 interval_seconds = 21600
 io_form_geogrid = 2,
 /

 &geogrid
 parent_id         =   1,    1,     2,
 parent_grid_ratio =   1,    3,     3,
 i_parent_start    =   1,   
 j_parent_start    =   1,   
 e_we              =  ${E_WE_D01}, 
 e_sn              =  ${E_SN_D01}, 
 geog_data_res     =  '2m',
 dx = ${DXDY_D01},
 dy = ${DXDY_D01},
 map_proj = 'mercator',
 ref_lat   = ${WPS_LAT},
 ref_lon   = ${WPS_LON},
 truelat1  = ${WPS_LAT},
 truelat2  = 0.0,
 stand_lon = 0.0,
 geog_data_path = '${PROGRAM_DIR}/wps/geog/geog'
 /

 &ungrib
 out_format = 'WPS',
 prefix = 'FILE',
 /

 &metgrid
 fg_name = 'FILE'
 io_form_metgrid = 2, 
 /
EOF

./link_grib.csh ${WPS_FNL_DIR}/${yyyy1}/${mm1}/fnl_${yyyy1}${mm1}*

./ungrib.exe
./geogrid.exe
./metgrid.exe

cd ../..

echo "-------------------------------"
echo "---   Done gen_be_wps.csh   ---"
echo "-------------------------------"
