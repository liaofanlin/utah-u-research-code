#!/bin/csh
#

	set echo
	
	set PROGRAM_DIR 			= $1
	set DA_START_DATE 			= $2
	set SMDA_EXE_PATH 			= $3
	set SMDA_NX					= $4
		
	set SMDA_NY					= $5
	set SMDA_NZ					= $6
	set SMDA_WRFINPUT_FILE 		= $7
	set SMDA_BEC_PATH			= $8
	
	set SMDA_BEC_FILENAME		= $9
	set SMDA_OBS_FILENAME		= $10
	set SMDA_OBS_FILEPATH		= $11
	set CYCLING_MODE			= $12
	
	set WPS_START_DATE			= $13
	set FORECAST_INI_FREQ		= $14
	set SMDA_DA_STRATEGY		= $15
	set WRF_4DVAR_SWITCH		= $16
	
	set WRF_3DVAR_EXE_VERSION	= $17
	set DA_SPECIAL_MODE01		= $18
	set NC_REPL_PATH			= $19
	
	set ADV_TIME_EXE 			= ${PROGRAM_DIR}/wrfda/${WRF_3DVAR_EXE_VERSION}/var/build/da_advance_time.exe

	set WORKPATH               	= `pwd`

	# Process of date
	# ---------------
		set yyyy1 = `echo $DA_START_DATE | cut -c1-4`
		set   mm1 = `echo $DA_START_DATE | cut -c5-6`
		set   dd1 = `echo $DA_START_DATE | cut -c7-8`
		set   hh1 = `echo $DA_START_DATE | cut -c9-10`

	cd smda

	# ========================================================================================
	# 1. Link of wrfinput files!
	# ==========================
		# 1.1. Only SMDA run
		# ===================
		if (${WRF_4DVAR_SWITCH} == 'false') then

			# Link and process of wrfinput file
			# ----------------------------------
				# Strategy 1: (cycling) For the first cycle, the wrfinput_ori is also from real
					if      ( (${CYCLING_MODE} == 'true') && (${DA_START_DATE} == ${WPS_START_DATE}) ) then
						ln -sf ../../../real/${DA_START_DATE}/wrfinput_d01 wrfinput_ori			
				
				# Strategy 2: (cycling) For the rest of the cycles, the wrfinput is from previously 6h forecasts		
					else if ( (${CYCLING_MODE} == 'true') && (${DA_START_DATE} != ${WPS_START_DATE}) && ($DA_SPECIAL_MODE01 == false) ) then
						set PREVIOUS_DATE = `${ADV_TIME_EXE} ${DA_START_DATE} -${FORECAST_INI_FREQ}`
						ln -sf ../../${PREVIOUS_DATE}/wrf/wrfvar_input_d01_${yyyy1}-${mm1}-${dd1}_${hh1}:00:00 wrfinput_ori		
					
				# Strategy 3: (cycling) For the rest of the cycles, the wrfinput is from real.  However, the SMOIS is from previously 6h forecasts 			
					else if ( (${CYCLING_MODE} == 'true') && (${DA_START_DATE} != ${WPS_START_DATE}) && ($DA_SPECIAL_MODE01 == true) ) then
						set PREVIOUS_DATE = `${ADV_TIME_EXE} ${DA_START_DATE} -${FORECAST_INI_FREQ}`
						ln -sf ../../${PREVIOUS_DATE}/wrf/wrfvar_input_d01_${yyyy1}-${mm1}-${dd1}_${hh1}:00:00 wrfout_previous_cycle
						ln -sf ../../../real/${DA_START_DATE}/wrfinput_d01 wrfinput_d01_no_repl
						cp wrfinput_d01_no_repl wrfinput_d01
						ln -sf ${NC_REPL_PATH}/nc_repl.exe .
						./nc_repl.exe wrfinput_d01 wrfout_previous_cycle SMOIS ${SMDA_NX} ${SMDA_NY} ${SMDA_NZ}
					
				# Strategy 4: (non-cycling) the wrfinput_ori is from real		
					else if   (${CYCLING_MODE} == 'true') then
						ln -sf ../../../real/${DA_START_DATE}/wrfinput_d01 wrfinput_ori	
					
				# Other other unwanted cases...		
					else
						echo "Error in darun_smda.csh"
					endif
			
			
			# Because the SMDA will change content inside wrfinput file, we copy it.
			cp wrfinput_ori wrfinput_d01
			
			# Link of wrfbdy file
			ln -sf ../../../real/${DA_START_DATE}/wrfbdy_d01 .		
			
		endif
		
		# 1.2. PrDA and SMDA run
		# -----------------
		if (${WRF_4DVAR_SWITCH} == 'true') then
			if (${CYCLING_MODE} == 'true') then
				ln -sf ../update_bdy/wrfvar_output .
			endif

			if (${CYCLING_MODE} == 'false') then
				echo 'This should not happen (liaofan)'
			endif
			
			# Because the SMDA will change content inside wrfinput file, we copy it.
			cp wrfvar_output wrfinput_d01
			
			# Link of wrfbdy file
			ln -sf ../update_bdy/wrfbdy_d01 .		
			
		endif

		

	# 2. Background Error Covariance
	# -----------------------------
		ln -sf ${SMDA_BEC_PATH}/${SMDA_BEC_FILENAME} .

	# 3. Link smda.exe file
	# ------------------
		ln -sf ${SMDA_EXE_PATH}/smda.exe .


	# 4. SMDA DA STRATEGY
	# --------------------------------------------------	
		# 4.1. SMDA DA STRATEGY 01 (Used for SMOS Observation)
		# ---------------------------------------------------
		if (${SMDA_DA_STRATEGY} == '01') then
			if (${hh1} == '00' ) then
				ln -sf ${SMDA_OBS_FILEPATH}/ncout_1D_25km_descending/${yyyy1}/${mm1}/smos_descending_from_${yyyy1}${mm1}${dd1}.nc smos_obs.nc
			else if (${hh1} == '06' ) then	
				
			else if (${hh1} == '12' ) then
				ln -sf ${SMDA_OBS_FILEPATH}/ncout_1D_25km_ascending/${yyyy1}/${mm1}/smos_ascending_from_${yyyy1}${mm1}${dd1}.nc smos_obs.nc

			else if (${hh1} == '18' ) then		
				
			else
		
			endif
		endif		

		# 4.2. SMDA DA STRATEGY 01 (Used for SMAP L2 Version 4 Observation)
		# -----------------------------------------------------------------	
		if (${SMDA_DA_STRATEGY} == '02') then
			if (${hh1} == '00' ) then
				ln -sf ${SMDA_OBS_FILEPATH}/${yyyy1}/${mm1}/SMAP_L2SMP_ascending_00UTC_${yyyy1}${mm1}${dd1}.nc sm_obs.nc
			else if (${hh1} == '06' ) then	
				
			else if (${hh1} == '12' ) then
				ln -sf ${SMDA_OBS_FILEPATH}/${yyyy1}/${mm1}/SMAP_L2SMP_descending_12UTC_${yyyy1}${mm1}${dd1}.nc sm_obs.nc
			else if (${hh1} == '18' ) then		
				
			else
		
			endif
		endif				
		
		
	
		# 4.10. SMDA DA STRATEGY 99 (old one; Not used)
		# -------------------------------
		if (${SMDA_DA_STRATEGY} == '99') then
			if (${hh1} == '00' ) then
				ln -sf ${SMDA_OBS_FILEPATH}/ncout_1D_25km_descending/${yyyy1}/${mm1}/smos_descending_from_${yyyy1}${mm1}${dd1}.nc smos_obs.nc
			else if (${hh1} == '06' ) then
				ln -sf ${SMDA_OBS_FILEPATH}/ncout_1D_25km_ascending/${yyyy1}/${mm1}/smos_ascending_from_${yyyy1}${mm1}${dd1}.nc smos_obs.nc
			else if (${hh1} == '12' ) then
				ln -sf ${SMDA_OBS_FILEPATH}/ncout_1D_25km_descending/${yyyy1}/${mm1}/smos_descending_from_${yyyy1}${mm1}${dd1}.nc smos_obs.nc
			else if (${hh1} == '18' ) then
				ln -sf ${SMDA_OBS_FILEPATH}/ncout_1D_25km_ascending/${yyyy1}/${mm1}/smos_ascending_from_${yyyy1}${mm1}${dd1}.nc smos_obs.nc 
			else
		
			endif
		endif

	# 6. If the observation file do not exist, do not run smda.exe
	# ------------------------------------------------------------
		# 
		if (-f smos_obs.nc) then
			./smda.exe ${DA_START_DATE} ${SMDA_NX} ${SMDA_NY} ${SMDA_NZ} ${SMDA_WRFINPUT_FILE} ${SMDA_BEC_FILENAME}  ${SMDA_OBS_FILENAME} >& smda_log.txt	
		endif
		if (-f sm_obs.nc) then
			./smda.exe ${DA_START_DATE} ${SMDA_NX} ${SMDA_NY} ${SMDA_NZ} ${SMDA_WRFINPUT_FILE} ${SMDA_BEC_FILENAME}  ${SMDA_OBS_FILENAME} >& smda_log.txt	
		endif


	cd ..
