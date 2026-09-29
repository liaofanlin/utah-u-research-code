#!/bin/csh -x
#
	#set echo

	set WORKSPACE					= `pwd`
	set DA_START_TIME				= $1
	set PROGRAM_DIR				= $2
	set WRF_3DVAR_EXE_VERSION	= $3
	set GSI_ENKF_NANALS			= $4
	
	set WRF_EXE_VERSION			= $5
	set GSI_ENKF_WRF_MEM_NPROC = $6
	set SBATCH_CHPC_TIME			= $7
	set SBATCH_CHPC_NODES		= $8
	
	set SBATCH_CHPC_NTASKS		= $9
	set SBATCH_CHPC_ACCOUNT		= $10
	set SBATCH_CHPC_PARTITION	= $11
	set MODULE_FILE				= $12
	
	set ADV_TIME_EXE				= $13
	
#################################################################


set ENS_MEM_ITER = 1

while ( ${ENS_MEM_ITER} <= ${GSI_ENKF_NANALS})

# =======================================================================
# 1. Pre-setup
# =======================================================================
	# 1.1. Set up member id string (only for member number < 100)
	if ($ENS_MEM_ITER<10) then
		set ENS_MEM_STR = 00${ENS_MEM_ITER}
	else
		set ENS_MEM_STR = 0${ENS_MEM_ITER}
	endif

	# 1.2. Create the working folder
	mkdir ./gsi_enkf/${DA_START_TIME}/07_wrf_6h_fcst/mem${ENS_MEM_STR}

# =======================================================================
# 2. Link Files
# =======================================================================	
	cd ./gsi_enkf/${DA_START_TIME}/07_wrf_6h_fcst/mem${ENS_MEM_STR}
		
		# 2.1. data, tables, and wrf.exe
		ln -sf ${PROGRAM_DIR}/wrf/${WRF_EXE_VERSION}/run/*.TBL .
		ln -sf ${PROGRAM_DIR}/wrf/${WRF_EXE_VERSION}/run/RRTMG_SW_DATA .
		ln -sf ${PROGRAM_DIR}/wrf/${WRF_EXE_VERSION}/run/RRTMG_LW_DATA .
		ln -sf ${PROGRAM_DIR}/wrf/${WRF_EXE_VERSION}/run/RRTM_DATA .
		ln -sf ${PROGRAM_DIR}/wrf/${WRF_EXE_VERSION}/run/ETAMPNEW_DATA .
		ln -sf ${PROGRAM_DIR}/wrf/${WRF_EXE_VERSION}/run/CAM_AEROPT_DATA .
		ln -sf ${PROGRAM_DIR}/wrf/${WRF_EXE_VERSION}/run/CAM_ABS_DATA .
		ln -sf ${PROGRAM_DIR}/wrf/${WRF_EXE_VERSION}/main/wrf.exe .	

		# 2.2. Link ozone data for RRTMG radiation
		#	- See rn170324
		ln -sf ${PROGRAM_DIR}/wrf/${WRF_EXE_VERSION}/run/ozone* .
	
		# 2.3. Link data for the CLM Land surface model
		ln -sf ${PROGRAM_DIR}/wrf/${WRF_EXE_VERSION}/run/CLM_* .	
		
		# 2.4 Link the wrfinput file
		ln -sf ../../06_enkf/analysis.mem${ENS_MEM_STR} wrfinput_d01
		
		# 2.5 Link the wrfbdy file
		#ln -sf ${WORKSPACE}/real/${DA_START_TIME}/wrfbdy_d01 .
		ln -sf ${WORKSPACE}/real_pert/wrfbdy/${DA_START_TIME}/mem${ENS_MEM_STR}/da_update_bc/wrfbdy_d01 .
		
		# 2.6. Linke the name list 
		ln -sf ${WORKSPACE}/real/${DA_START_TIME}/namelist.input_spinup namelist.input
		

	cd ../../../..
	
# =======================================================================
# 3. Run the job
# =======================================================================	
cd ./gsi_enkf/${DA_START_TIME}/07_wrf_6h_fcst/mem${ENS_MEM_STR}	
	
	# (2018.11.01) The following needs part 4
	#mpirun -np ${GSI_ENKF_WRF_MEM_NPROC} ./wrf.exe &
	
	# (2018.11.01) This line does not need part 4
	mpirun -np $SLURM_NTASKS ./wrf.exe
	
cd ../../../..	
# ----------------------------------------------------------------------

	# 4. Repeat for the next ensemble member
	set ENS_MEM_ITER = `expr ${ENS_MEM_ITER} + 1`

end	


# =======================================================================
# 4. Check if all the WRF jobs are finished
# =======================================================================	
#set WRFVAR_6H_TIME = `${ADV_TIME_EXE} ${DA_START_TIME} 6`
#
## GSI Analysis Time Details
#set yyyy1 = `echo $WRFVAR_6H_TIME | cut -c1-4`
#set   mm1 = `echo $WRFVAR_6H_TIME | cut -c5-6`
#set   dd1 = `echo $WRFVAR_6H_TIME | cut -c7-8`
#set   hh1 = `echo $WRFVAR_6H_TIME | cut -c9-10`
#
#
#set WRF_MIN_LAPSE = 0
#while (${WRF_MIN_LAPSE} < 86400) # Temporarily set to leave the loop after 600 seconds
#
#	# Remove the temporary check file
#	if (-e check_wrfvar.txt) rm check_wrfvar.txt
#		
#	# Check my job	
#	#	- Note (2018.09.27): The grep for $SBATCH_CHPC_TIME only works when I am using the a job longer than 
#	#	  24 hours for EnKF while jobs of less than 24 hours for WRF.
#	ls -l gsi_enkf/${DA_START_TIME}/07_wrf_6h_fcst/mem*/wrfvar_input_d01_${yyyy1}-${mm1}-${dd1}_${hh1}:00:00 | wc -l > check_wrfvar.txt
#	
#	sleep 2
#	
#	set NUM_WRFVAR_COMPLETION = `cat check_wrfvar.txt`
#	
#	# Check the content of the check file
#	# 	- If the completed file number is smaller than the ensemble size, continue
#	#	- If the completed file number is the same as the ensemble size, stop and break
#	if (${NUM_WRFVAR_COMPLETION} < ${GSI_ENKF_NANALS}) then
#		
#		sleep 60
#		set WRF_MIN_LAPSE = `expr ${WRF_MIN_LAPSE} + 60`
#		echo "WRF jobs for analyais time "${DA_START_TIME}" have lapsed for "${WRF_MIN_LAPSE}" seconds..."
#		
#	else
#		echo "WRF jobs have done! Sleep for 2 minutes..."
#		sleep 120
#		
#		break
#	endif	
#			
#end

