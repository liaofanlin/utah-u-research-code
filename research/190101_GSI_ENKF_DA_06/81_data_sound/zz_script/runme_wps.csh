#!/bin/csh
#
# Note (2018.04.17) 
#	- I set up the WPS paths here rather than at the zz_runme.csh

set echo
echo "-------------------------------------------------------------------------"
echo "--- Running the runme_wps.csh -------------------------------------------"
echo "-------------------------------------------------------------------------"

set WPS_LON 					= $1
set WPS_LAT 					= $2
set WPS_START_DATE			= $3
set WPS_END_DATE				= $4

set PROGRAM_DIR				= $5
set WPS_FNL_DIR				= $6		# Note (2018.04.17) this variable is useless
set MAX_DOM						= $7
set DXDY_D01					= $8

set E_WE_D01					= $9
set E_SN_D01					= $10
set E_WE_D02					= $11
set E_SN_D02					= $12

set DXDY_D02					= $13
set I_PARENT_START_D02		= $14
set J_PARENT_START_D02		= $15
set PARENT_GRID_RATIO_D02  = $16

set E_WE_D03					= $17
set E_SN_D03					= $18
set DXDY_D03					= $19
set I_PARENT_START_D03		= $20

set J_PARENT_START_D03		= $21
set PARENT_GRID_RATIO_D03 	= $22
set WPS_GEN_END_DATE			= $23
set WPS_EXE_VERSION			= $24

set WPS_GEOG_PATH				= $25
set WRF_4DVAR_EXE_VERSION	= $26
set WRF_3DVAR_EXE_VERSION	= $27
set WPS_DATA_TYPE				= $28

set WPS_GEOG_DATA_RES		= $29
set WPS_MAP_PROJ				= $30
set WPS_TRUELAT1				= $31
set WPS_TRUELAT2				= $32

set WPS_STAND_LON				= $33


set ADV_TIME_EXE 				= ${PROGRAM_DIR}/wrfda/${WRF_3DVAR_EXE_VERSION}/var/build/da_advance_time.exe

###########################################################################################
# 1. Decide what type of data to be linked
# ========================================
	# Note (2018.04.17) See various datasets supported by WRF at 
	#	- http://www2.mmm.ucar.edu/wrf/users/download/free_data.html
	
	# NCEP 1-degree FNL Analysis 
	if (${WPS_DATA_TYPE} == 'NCEP_FNL_1_degree') then
		set WPS_DATA_PATH = /uufs/chpc.utah.edu/common/home/zpu-group10/pu02/data/fnl_1degree_ncar
		set VTABLE_NAME = Vtable.GFS
	endif

	# NCEP 0.25-degree FNL Analysis 
	if (${WPS_DATA_TYPE} == 'NCEP_FNL_0p25_degree') then
		set WPS_DATA_PATH = /uufs/chpc.utah.edu/common/home/zpu-group10/pu02/data/fnl_0p25_ncar
		set VTABLE_NAME = Vtable.GFS
	endif
	
	# NCEP 12-km NAM Analysis (North America Only)
	if (${WPS_DATA_TYPE} == 'NCEP_NAM_12_km') then
		set WPS_DATA_PATH = /uufs/chpc.utah.edu/common/home/zpu-group10/pu02/data/nam_12km_ncar_ds609_0
		set VTABLE_NAME = Vtable.NAM
	endif	

# 2. Process of date
# ========================================
	set yyyy1 = `echo $WPS_START_DATE | cut -c1-4`
	set   mm1 = `echo $WPS_START_DATE | cut -c5-6`
	set   dd1 = `echo $WPS_START_DATE | cut -c7-8`
	set   hh1 = `echo $WPS_START_DATE | cut -c9-10`
	
	set yyyy2 = `echo $WPS_GEN_END_DATE | cut -c1-4`
	set   mm2 = `echo $WPS_GEN_END_DATE | cut -c5-6`
	set   dd2 = `echo $WPS_GEN_END_DATE | cut -c7-8`
	set   hh2 = `echo $WPS_GEN_END_DATE | cut -c9-10`

# 3. Link and execute
# ========================================
	cd ./wps

	ln -sf ${PROGRAM_DIR}/wps/${WPS_EXE_VERSION}/geogrid .
	ln -sf ${PROGRAM_DIR}/wps/${WPS_EXE_VERSION}/metgrid .
	ln -sf ${PROGRAM_DIR}/wps/${WPS_EXE_VERSION}/ungrib .
	ln -sf ./geogrid/src/geogrid.exe .
	ln -sf ./ungrib/src/ungrib.exe .
	ln -sf ./metgrid/src/metgrid.exe .
	cp ${PROGRAM_DIR}/wps/${WPS_EXE_VERSION}/link_grib.csh .
	cp ${PROGRAM_DIR}/wps/${WPS_EXE_VERSION}/util/plotgrids.ncl .
	cp ${PROGRAM_DIR}/wps/${WPS_EXE_VERSION}/util/plotgrids_new.ncl .
	ln -sf ./ungrib/Variable_Tables/${VTABLE_NAME} Vtable

# 4. Create the name list
# ========================================
cat >! namelist.wps << EOF
 &share
 wrf_core = 'ARW',
 max_dom = ${MAX_DOM},
 start_date = '${yyyy1}-${mm1}-${dd1}_${hh1}:00:00','${yyyy1}-${mm1}-${dd1}_${hh1}:00:00','${yyyy1}-${mm1}-${dd1}_${hh1}:00:00',
 end_date   = '${yyyy2}-${mm2}-${dd2}_${hh2}:00:00','${yyyy2}-${mm2}-${dd2}_${hh2}:00:00','${yyyy2}-${mm2}-${dd2}_${hh2}:00:00',
 interval_seconds = 21600
 io_form_geogrid = 2,
 /

 &geogrid
 parent_id         =   1,    						1,     							2,
 parent_grid_ratio =   1,    						${PARENT_GRID_RATIO_D02},  ${PARENT_GRID_RATIO_D03},
 i_parent_start    =   1,   						${I_PARENT_START_D02},    	${I_PARENT_START_D03},
 j_parent_start    =   1,   						${J_PARENT_START_D02},    	${J_PARENT_START_D03},
 e_we              =  ${E_WE_D01},  			${E_WE_D02},   			  	${E_WE_D03},
 e_sn              =  ${E_SN_D01},  			${E_SN_D02},   				${E_SN_D03},
 geog_data_res     =  '${WPS_GEOG_DATA_RES}','${WPS_GEOG_DATA_RES}',		'${WPS_GEOG_DATA_RES}',
 dx = ${DXDY_D01},
 dy = ${DXDY_D01},
 map_proj = '${WPS_MAP_PROJ}',
 ref_lat   = ${WPS_LAT},
 ref_lon   = ${WPS_LON},
 truelat1  = ${WPS_TRUELAT1},
 truelat2  = ${WPS_TRUELAT2},
 stand_lon = ${WPS_STAND_LON},
 geog_data_path = '${WPS_GEOG_PATH}'
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

# 5. Link Forcing Data and run ungrib.exe
# ========================================
	set DA_START_DATE = ${WPS_START_DATE}

	while ( ${DA_START_DATE} <= ${WPS_GEN_END_DATE} )

		# Time operation
			set yyyy0 = `echo $DA_START_DATE | cut -c1-4`
			set   mm0 = `echo $DA_START_DATE | cut -c5-6`
			set   dd0 = `echo $DA_START_DATE | cut -c7-8`
			set   hh0 = `echo $DA_START_DATE | cut -c9-10`

		# Link and process a single dataset file
			if ( ${WPS_DATA_TYPE} == 'NCEP_FNL_1_degree' ) then
				./link_grib.csh ${WPS_DATA_PATH}/${yyyy0}/${mm0}/fnl_${yyyy0}${mm0}${dd0}_${hh0}*
			endif

			if ( ${WPS_DATA_TYPE} == 'NCEP_FNL_0p25_degree' ) then
				./link_grib.csh ${WPS_DATA_PATH}/${yyyy0}/${mm0}/gdas1.fnl0p25.${yyyy0}${mm0}${dd0}${hh0}.*
			endif
			
			if ( ${WPS_DATA_TYPE} == 'NCEP_NAM_12_km' ) then
				# Note (2018.10.29): The file name was changed on 2017.03.21.  You can see why the logics below.
				#	- Before 2017.03.21, the file name is ***.awphys00.grb2.tm00
				#	- After  2017.03.21, the file name is ***.awphys00.tm00.grb2
				./link_grib.csh ${WPS_DATA_PATH}/${yyyy0}/${mm0}/${yyyy0}${mm0}${dd0}.nam.t${hh0}z.awphys00.*
			endif
					
			./ungrib.exe
			
		# while loop operation
			set DA_START_DATE = `${ADV_TIME_EXE} ${DA_START_DATE} 6`
	
	end

# 6. Running geogrid.exe and metgrid.exe
# ========================================
	./geogrid.exe
	./metgrid.exe

	# Go back the original directory
	cd ..

echo "-------------------------------------------------------------------------"
echo "--- Finishing the runme_wps.csh -----------------------------------------"
echo "-------------------------------------------------------------------------"
