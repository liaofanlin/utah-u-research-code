#!/bin/csh -x
#

# set echo
echo "-------------------------------------------------------------------------"
echo "--- Beginning of runme_gsi_enkf.csh -------------------------------------"
echo "-------------------------------------------------------------------------"

# Note (2018.09.23): The following parameters part should be the same for 
#	- runme_gsi_enkf.csh
#	- runme_gsi_enkf_cycling.csh
	set PROGRAM_DIR						= $1
	set WRF_3DVAR_EXE_VERSION			= $2
	set WPS_START_DATE					= $3
	set WPS_END_DATE						= $4
	
	set GSI_ENKF_DIAG_READ_PROCESS 	= $5
	set GSI_ENKF_NLONS					= $6
	set GSI_ENKF_NLATS					= $7
	set GSI_ENKF_NLEVS					= $8
	
	set WRF_EXE_VERSION					= $9
	set GSI_ENKF_WRF_MEM_NPROC			= $10
	set GSI_ENKF_CYCLING_MODE			= $11
	set SBATCH_CHPC_TIME					= $12
	
	set SBATCH_CHPC_NODES				= $13
	set SBATCH_CHPC_NTASKS				= $14
	set SBATCH_CHPC_ACCOUNT				= $15
	set SBATCH_CHPC_PARTITION			= $16
	
	set MODULE_FILE						= $17
	
	set GSI_ENKF_NANALS					= 10	# Number of ensemble members
	set GSI_ENKF_CYCLE_FREQ 			= 6	# Hours between each cycle
	set GSI_ENKF_CONV_OBS_PATH 		= ~/zpu-group10/data/ncar_ds337_conventional_dataset
	set GSI_ENKF_EXE_VERSION			= comGSIv3.6_EnKFv1.2_prog08
	set GSI_ENKF_ROOT						= ${PROGRAM_DIR}/gsi/${GSI_ENKF_EXE_VERSION}
	

	set ADV_TIME_EXE 						= ${PROGRAM_DIR}/wrfda/${WRF_3DVAR_EXE_VERSION}/var/build/da_advance_time.exe

# =======================================================================================================

# Note (2018.09.20):  If the ensemble member is 10. The $WPS_START_DATE = 2016070106.  
#	The following calculation make sure the GSI-EnKF starts at 60 + 6 hours later.
#	The latter 6 hours are for the spinup time.  
set GSI_ENKF_ADVANCE_HOURS = `expr ${GSI_ENKF_NANALS} \* 6 + 6`
set EXP_START_TIME 		= `${ADV_TIME_EXE} ${WPS_START_DATE} ${GSI_ENKF_ADVANCE_HOURS}`
set DA_START_TIME 		= ${EXP_START_TIME}
set DA_END_TIME 			= `${ADV_TIME_EXE} ${DA_START_TIME} ${GSI_ENKF_CYCLE_FREQ}`

while ( ${DA_END_TIME} <= ${WPS_END_DATE} )

	mkdir ./gsi_enkf/${DA_START_TIME}
	
	# GSI Analysis Time Details
	set yyyy1 = `echo $DA_START_TIME | cut -c1-4`
	set   mm1 = `echo $DA_START_TIME | cut -c5-6`
	set   dd1 = `echo $DA_START_TIME | cut -c7-8`
	set   hh1 = `echo $DA_START_TIME | cut -c9-10`
	
	
# =========================================================
# 01. Process ensemble members
# =========================================================
	# Create the folders.
	mkdir ./gsi_enkf/${DA_START_TIME}/01_ens_process
	mkdir ./gsi_enkf/${DA_START_TIME}/01_ens_process/data_at_ana_time
	mkdir ./gsi_enkf/${DA_START_TIME}/01_ens_process/computing_ens_mean
	
	# Link ensemble members
	set ENS_MEM_ITER = 1
	
	cd ./gsi_enkf/${DA_START_TIME}/01_ens_process/data_at_ana_time
	
	while ( ${ENS_MEM_ITER} <= ${GSI_ENKF_NANALS})
		set ENS_MEM_ITER_HOUR01 = `expr ${GSI_ENKF_NANALS} - ${ENS_MEM_ITER} + 1`
		set ENS_MEM_ITER_HOUR02 = `expr ${ENS_MEM_ITER_HOUR01} \* 6`		
		
		set ENS_MEM_ITER_TIME = `${ADV_TIME_EXE} ${DA_START_TIME} -${ENS_MEM_ITER_HOUR02}`
		
		# Set up member id string (only for member number < 100)
		if ($ENS_MEM_ITER<10) then
			set ENS_MEM_STR = 00${ENS_MEM_ITER}
		else
			set ENS_MEM_STR = 0${ENS_MEM_ITER}
		endif
		
		# Link files
		ln -sf ../../../../openloop/${ENS_MEM_ITER_TIME}/wrfvar_input_d01_${yyyy1}-${mm1}-${dd1}_${hh1}:00:00 \
			    wrfarw.mem${ENS_MEM_STR}
		
		set ENS_MEM_ITER = `expr ${ENS_MEM_ITER} + 1`
	
	end
	
	cd ../../../..
	
	# Compute ensemble mean
	cd ./gsi_enkf/${DA_START_TIME}/01_ens_process/computing_ens_mean
		cp ../../../../zz_script/gsi_enkf/gsi_enkf_compute_ensmean.csh .
		csh gsi_enkf_compute_ensmean.csh
	cd ../../../..
		
# =========================================================
# 02. Link the background and obs. files
# =========================================================
	# Create the folders.
	mkdir ./gsi_enkf/${DA_START_TIME}/02_arw_${DA_START_TIME}
	mkdir ./gsi_enkf/${DA_START_TIME}/02_arw_${DA_START_TIME}/bk
	mkdir ./gsi_enkf/${DA_START_TIME}/02_arw_${DA_START_TIME}/obs
	
	# Link the background files
	cd ./gsi_enkf/${DA_START_TIME}/02_arw_${DA_START_TIME}/bk
		ln -sf ../../01_ens_process/data_at_ana_time/wrfarw* .
		ln -sf ../../01_ens_process/computing_ens_mean/wrfarw* .
	cd ../../../..

	# Link the observation files
	cd ./gsi_enkf/${DA_START_TIME}/02_arw_${DA_START_TIME}/obs
		ln -sf ${GSI_ENKF_CONV_OBS_PATH}/${yyyy1}/${yyyy1}${mm1}${dd1}.nr/prepbufr.gdas.${yyyy1}${mm1}${dd1}.t${hh1}z.nr \
			gdas1.t${hh1}z.prepbufr.nr
	cd ../../../..

# =========================================================
# 03. Pre-Processing of some files, including convinfor
# =========================================================
	# Create the folders for 03, 04, and 06
	mkdir ./gsi_enkf/${DA_START_TIME}/03_pre_process
	mkdir ./gsi_enkf/${DA_START_TIME}/04_gsidiag
	mkdir ./gsi_enkf/${DA_START_TIME}/06_enkf
	
	# Process the convinfo file
	# --------------------------
	cd ./gsi_enkf/${DA_START_TIME}/03_pre_process
		
		# Copy the original file
		cp ${GSI_ENKF_ROOT}/fix/global_convinfo.txt convinfo
		
		# Revise the convinfor for my experiment purpose
		# ----------------------------------------------
		# Convert use_flag=1 to -1 for ps data
		#sed -i -- 's/ps       120    0    1/ps       120    0   -1/g' convinfo
		#sed -i -- 's/ps       187    0    1/ps       187    0   -1/g' convinfo
	
		# Convert use_flag=1 to -1 for q data
		#sed -i -- 's/q        120    0    1/q        120    0   -1/g' convinfo
	
		# Convert use_flag=1 to -1 for uv data
		#sed -i -- 's/uv       220    0    1/uv       220    0   -1/g' convinfo		
		#sed -i -- 's/uv       224    0    1/uv       224    0   -1/g' convinfo			

	cd ../../..
	
	# Link the convinfo file for gsi and enkf
	cd ./gsi_enkf/${DA_START_TIME}/04_gsidiag
		ln -sf ../03_pre_process/convinfo .
	cd ../../..
	
	cd ./gsi_enkf/${DA_START_TIME}/06_enkf
		ln -sf ../03_pre_process/convinfo .
	cd ../../..	

# =========================================================
# 04. GSI for producing diagnostic files (need enough CPUs)
# =========================================================
	# Generate run_gsi_regional.ksh
	csh zz_script/gsi_enkf/gsi_enkf_create_run_gsi_regional.csh \
	${DA_START_TIME}		${GSI_ENKF_ROOT}	${PROGRAM_DIR}	${WRF_3DVAR_EXE_VERSION} \
	${GSI_ENKF_NANALS}

	mv run_gsi_regional.ksh ./gsi_enkf/${DA_START_TIME}/
	
	# Run run_gsi_regional.ksh
	cd ./gsi_enkf/${DA_START_TIME}
		ksh run_gsi_regional.ksh
	cd ../..
	
# =========================================================
# 05. Post-processing of diag files
# =========================================================
	# Create the folders 
	mkdir ./gsi_enkf/${DA_START_TIME}/05_post_process_diag
	
	# Perform post-processing of diag files
	csh ./zz_script/gsi_enkf/gsi_enkf_post_process_diag.csh \
		${GSI_ENKF_DIAG_READ_PROCESS} 	${DA_START_TIME}	${GSI_ENKF_NANALS} 
	
# =========================================================
# 06. EnKF for performing analysis (need enough CPUs)
# =========================================================	
	# Generate run_enkf_wrf.ksh
	csh ./zz_script/gsi_enkf/gsi_enkf_create_run_enkf_regional.csh \
		${DA_START_TIME}	${GSI_ENKF_ROOT}	${GSI_ENKF_NANALS}	${GSI_ENKF_NLONS} \
		${GSI_ENKF_NLATS}	${GSI_ENKF_NLEVS}
		
	mv run_enkf_regional.ksh ./gsi_enkf/${DA_START_TIME}/
	
	# Run run_enkf_regional.ksh
	cd ./gsi_enkf/${DA_START_TIME}
		ksh run_enkf_regional.ksh
	cd ../..
	
	# Move some of my liaofan coding files
	mkdir ./gsi_enkf/${DA_START_TIME}/06_enkf/coding_output
	mv ./gsi_enkf/${DA_START_TIME}/06_enkf/liaofan_ENKF_taperv_nf2_* \
		./gsi_enkf/${DA_START_TIME}/06_enkf/coding_output/
	mv ./gsi_enkf/${DA_START_TIME}/06_enkf/liaofan_MPI_READOBS_variables_after_calling_get_convobs_data_* \
		./gsi_enkf/${DA_START_TIME}/06_enkf/coding_output/	
	
# =========================================================
# 07. WRF Forecasts (need enough CPUs)
# =========================================================	
#	# Create a folder
#	mkdir ./gsi_enkf/${DA_START_TIME}/07_wrf_6h_fcst
#
#	csh ./zz_script/gsi_enkf/gsi_enkf_wrf_6h_fcst.csh \
#		${DA_START_TIME}		${PROGRAM_DIR}					${WRF_3DVAR_EXE_VERSION}	${GSI_ENKF_NANALS} \
#		${WRF_EXE_VERSION}	${GSI_ENKF_WRF_MEM_NPROC}
#	
# =========================================================
	# Set up time iteration
	set DA_START_TIME 	= `${ADV_TIME_EXE} ${DA_START_TIME} ${GSI_ENKF_CYCLE_FREQ}`
	set DA_END_TIME 		= `${ADV_TIME_EXE} ${DA_END_TIME} 	${GSI_ENKF_CYCLE_FREQ}`
end


echo "------------------------------------------------------------------"
echo "--- End of runme_gsi_enkf.csh ------------------------------------"
echo "------------------------------------------------------------------"


