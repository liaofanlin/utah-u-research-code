#!/bin/csh -x
#
	#set echo

	# Basic time information
	set WPS_START_DATE			= 2018071100
	set WPS_END_DATE				= 2018072900
	set GSI_ENKF_CYCLE_FREQ		= 24		# now I would initial the forecast every 24 hours
	
	# Ensemble member size
	set GSI_ENKF_NANALS			= 40
	
	# Program for the da_advance_time.exe
	set PROGRAM_DIR				= /uufs/chpc.utah.edu/common/home/u6013926/zpu-group10/installation/11_install
	set WRF_3DVAR_EXE_VERSION	= WRFDA3.9_3dvar_dm
	set ADV_TIME_EXE 				= ${PROGRAM_DIR}/wrfda/${WRF_3DVAR_EXE_VERSION}/var/build/da_advance_time.exe
	
	set WORKPATH					= `pwd`
	
#################################################################

set DA_START_TIME 		= ${WPS_START_DATE}
set DA_END_TIME 			= `${ADV_TIME_EXE} ${DA_START_TIME} ${GSI_ENKF_CYCLE_FREQ}`

while ( ${DA_END_TIME} <= ${WPS_END_DATE} )


	# GSI Analysis Time Details
	set yyyy1 = `echo $DA_START_TIME | cut -c1-4`
	set   mm1 = `echo $DA_START_TIME | cut -c5-6`
	set   dd1 = `echo $DA_START_TIME | cut -c7-8`
	set   hh1 = `echo $DA_START_TIME | cut -c9-10`

	# Copy the case
	rm -rf ./gsi_enkf/${DA_START_TIME}/08_wrf_72h_fcst
	cp -ir ./gsi_enkf/${DA_START_TIME}/07_wrf_6h_fcst ./gsi_enkf/${DA_START_TIME}/08_wrf_72h_fcst
	
	# ----------------------------------------------------------------------
	# Process for each member
	set ENS_MEM_ITER = 1

	while ( ${ENS_MEM_ITER} <= ${GSI_ENKF_NANALS})

		# 1.1. Set up member id string (only for member number < 100)
		if ($ENS_MEM_ITER<10) then
			set ENS_MEM_STR = 00${ENS_MEM_ITER}
		else
			set ENS_MEM_STR = 0${ENS_MEM_ITER}
		endif

		# 1.2. Enter the folder
		cd ./gsi_enkf/${DA_START_TIME}/08_wrf_72h_fcst/mem${ENS_MEM_STR}

		# 1.3. Clean files
		rm rsl.*
		rm wrfout_*
		rm wrfvar_input_*
		rm namelist.input
		
		# 1.4. Link the name list for 72 hour forecasts
		ln -sf ../../../../real/${DA_START_TIME}/namelist.input .
		
		# 1.5. Run the wrf.exe
		mpirun -np $SLURM_NTASKS ./wrf.exe

		# 1.6. Clear wrfvar files
		rm wrfvar_input_*
		
		# 1.7. Go back the workspace
		cd ../../../..
	
		# 1.8. Repeat for the next ensemble member
		set ENS_MEM_ITER = `expr ${ENS_MEM_ITER} + 1`	

	end
	# ----------------------------------------------------------------------
	# Set up time iteration
	set DA_START_TIME 	= `${ADV_TIME_EXE} ${DA_START_TIME} ${GSI_ENKF_CYCLE_FREQ}`
	set DA_END_TIME 		= `${ADV_TIME_EXE} ${DA_END_TIME} 	${GSI_ENKF_CYCLE_FREQ}`
	
end	

