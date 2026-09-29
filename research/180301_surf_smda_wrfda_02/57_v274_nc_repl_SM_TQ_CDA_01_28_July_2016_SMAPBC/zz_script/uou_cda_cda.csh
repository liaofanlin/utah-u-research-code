#!/bin/csh -x
#
set echo
echo "--------------------------------------------------------------------------------------------------------"
echo "--- Beginning of runme_uou_cda_cycling.csh --> zz_runme_uou_cda_cycling.csh --> uou_cda_cda.csh --------"
echo "--------------------------------------------------------------------------------------------------------"

	set CYCLING_START_TIME		= $1
	set UOU_CDA_BEC_PATH			= $2
	set UOU_CDA_SMOBS_PATH		= $3
	set UOU_CDA_SMOBS_ERROR 	= $4
	
	set PROGRAM_DIR				= $5
	set WRF_3DVAR_EXE_VERSION	= $6
	set UOU_CDA_CYCLING_OPTION	= $7
	set UOU_CDA_NX					= $8
	
	set UOU_CDA_NY					= $9
	set UOU_CDA_NZ					= $10
	set UOU_CDA_NZ_SOIL			= $11
	set UOU_CDA_KG_PATH			= $12
		
	set ADV_TIME_EXE 				= ${PROGRAM_DIR}/wrfda/${WRF_3DVAR_EXE_VERSION}/var/build/da_advance_time.exe

################################################
# 0. Go into the working folder
cd ${CYCLING_START_TIME}/02_cda


# 1. Decide to run SDA or CDA
# ----------------------------
	# Note (2018.04.15): need to report the error in CDA2 version 01.
	if ( ${UOU_CDA_CYCLING_OPTION} == 'SDA' || ${UOU_CDA_CYCLING_OPTION} == 'OPL' ) then
		set UOU_CDA_EXE	 					= uou_cda.exe
		set UOU_CDA_EXE_PATH					= ~/zpu-group10/coding/fortran/2018/180211_uou_cda_exe_development/v03
	endif
	
	if ( ${UOU_CDA_CYCLING_OPTION} == 'CDA' ) then
		set UOU_CDA_EXE	 					= uou_cda2.exe
		set UOU_CDA_EXE_PATH					= ~/zpu-group10/coding/fortran/2018/180411_uou_cda2_exe_development/v02
	endif			

# 2. Time string preparation 
# ----------------------------
	# (for the current time)
	set yyyy1 = `echo $CYCLING_START_TIME | cut -c1-4`
	set   mm1 = `echo $CYCLING_START_TIME | cut -c5-6`
	set   dd1 = `echo $CYCLING_START_TIME | cut -c7-8`
	set   hh1 = `echo $CYCLING_START_TIME | cut -c9-10`	

# 3. Linking files
# ------------------
	# Link the uou_cda.exe file
	ln -sf ${UOU_CDA_EXE_PATH}/${UOU_CDA_EXE} .
	
	# Link the SM BEC STD file (used for SDA)
	#	- (2018.03.22) Note that rather than using month-year BEC, here I choose
	#	  the 3-year average monthly error statistics.  See rn180321 for more details.
	ln -sf ${UOU_CDA_BEC_PATH}/nc_files/std_all_3Yavg_${mm1}.nc CDA_BEC_STD.nc	
	
	# Link the Kalman gain file (used for CDA)
	ln -sf ${UOU_CDA_KG_PATH}/nc_files/kg_all_3Yavg_${mm1}.nc CDA_KG.nc
	
	# Link the satellite SM Observation
	# 	- Link it only for 00 and 12 UTC
	if (${hh1} == 12) then
		ln -sf ${UOU_CDA_SMOBS_PATH}/SMAP_L2SMP_E_descending_12UTC_${yyyy1}${mm1}${dd1}.nc satellite_obs_sm.nc
	endif
	
	if (${hh1} == 00) then
		ln -sf ${UOU_CDA_SMOBS_PATH}/SMAP_L2SMP_E_ascending_00UTC_${yyyy1}${mm1}${dd1}.nc satellite_obs_sm.nc
	endif	

	# Link and process of the first guess file 
	ln -sf ../01_fg_repl/wrfinput_d01_nc_repl wrfinput_ori
	
	cp wrfinput_ori wrfinput_cda

# 4. Create the CDA and CDA2 name list 
# ------------------------------------

# Creating name list for SDA
cat >! namelist.cda << EOF
&cda
 NX=${UOU_CDA_NX},
 NY=${UOU_CDA_NY},
 NOAH_SOIL_LAYER=4,
 CDA_SMAP_OBS_ERROR=${UOU_CDA_SMOBS_ERROR},
 CDA_BEC_STD_FILE_NAME='CDA_BEC_STD.nc',
 CDA_SM_OBS_FILE_NAME='satellite_obs_sm.nc',
 CDA_WRF_FILE_NAME='wrfinput_cda',
 /
EOF

# Creating name list for CDA
#	- Note (2018.04.15): 
#	  CDA_Z_DA_LAYER decides to what atmospheric layer that I will update T and QVAPOR. 
#	  Now the default is 10.
cat >! namelist.cda2 << EOF
&cda2
 NX=${UOU_CDA_NX},
 NY=${UOU_CDA_NY},
 NZ=${UOU_CDA_NZ},
 CDA_Z_DA_LAYER=10,
 NOAH_SOIL_LAYER=4,
 CDA_SMAP_OBS_ERROR=${UOU_CDA_SMOBS_ERROR},
 CDA_KG_FILE_NAME='CDA_KG.nc',
 CDA_SM_OBS_FILE_NAME='satellite_obs_sm.nc',
 CDA_WRF_FILE_NAME='wrfinput_cda',
 /
EOF



# 5. Run DA depending on cases of SDA, CDA, or OPL
# -----------------------------------------------
	# Run Soil Moisture DA for both CDA and SDA
	if (${UOU_CDA_CYCLING_OPTION} == 'SDA' || ${UOU_CDA_CYCLING_OPTION} == 'CDA') then
		if ((${hh1} == 12) || (${hh1} == 00)) then
			./${UOU_CDA_EXE}
		endif
	endif

	# OPL: Do nothing for the first guess
	if (${UOU_CDA_CYCLING_OPTION} == 'OPL' ) then
		
	endif
		
	# For post-simulation check
	ncdiff -v XLONG,XLAT,SMOIS,T,QVAPOR wrfinput_cda wrfinput_ori wrfinput_diff	
		
	# Go back to the original folder
	cd ../..
		
echo "--------------------------------------------------------------------------------------------------------"
echo "--- End of runme_uou_cda_cycling.csh --> zz_runme_uou_cda_cycling.csh --> uou_cda_cda.csh --------------"
echo "--------------------------------------------------------------------------------------------------------"












