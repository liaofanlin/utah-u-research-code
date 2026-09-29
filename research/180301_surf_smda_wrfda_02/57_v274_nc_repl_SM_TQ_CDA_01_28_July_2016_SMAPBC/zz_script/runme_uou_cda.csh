#!/bin/csh -x
#
set echo

echo "-------------------------------------------------------------------------"
echo "--- Beginning of runme_uou_cda.csh --------------------------------------"
echo "-------------------------------------------------------------------------"


# (2018.02.06) 
	set RUN_DIR								= uou_cda	# openloop or spinup
	set JOBNAME 							= UOU_CDA	# WRF_OPL or SPINUP

# (2017.08.24) Make the arguments same as those in 
	set WPS_START_DATE					= $1
	set WPS_END_DATE 						= $2
	set NPROC      		   			= $3		# number of processors
	set PROGRAM_DIR						= $4
	
	set PBS_QUEUE							= $5
	set FORECAST_HOURS	    			= $6
	set PBS_MEM 							= $7
	set PBS_PPN								= $8
	
	set PBS_WALLTIME 						= $9
	set CASENUM 							= $10
	set FORECAST_INI_FREQ 				= $11
	set PBS_NODES							= $12

	set WRF_EXE_VERSION					= $13
	set WRF_3DVAR_EXE_VERSION			= $14
	set MODULE_FILE						= $15
	set DA_SPECIAL_MODE01				= $16

	set SMDA_NX								= $17
	set SMDA_NY								= $18
	set SMDA_NZ								= $19
	set NC_REPL_PATH						= $20

	set QUEUE_TYPE							= $21
	set SBATCH_CHPC_TIME					= $22
	set SBATCH_CHPC_NODES				= $23
	set SBATCH_CHPC_NTASKS				= $24

	set SBATCH_CHPC_ACCOUNT				= $25
	set SBATCH_CHPC_PARTITION			= $26
	set SBATCH_CHPC_NPROC				= $27
	set SBATCH_CHPC_TIME_SHORT			= $28

	set SBATCH_CHPC_NODES_SHORT		= $29
	set SBATCH_CHPC_NTASKS_SHORT		= $30
	set SBATCH_CHPC_ACCOUNT_SHORT		= $31
	set SBATCH_CHPC_PARTITION_SHORT	= $32
	
	set SBATCH_CHPC_NPROC_SHORT		= $33
	set WRFDA_SPINUP_SWITCH				= $34		# It is used in runme_openloop.csh or runme_openloop_cycling.csh 	
	set UOU_CDA_NX							= $35
	set UOU_CDA_NY							= $36 
	
	set UOU_CDA_EXE	 					= $37
	set UOU_CDA_EXE_PATH					= $38
	set UOU_CDA_SMOBS_ERROR				= $39
	set UOU_CDA_SMOBS_PATH				= $40
	
	set UOU_CDA_BEC_PATH					= $41
	
	set ADV_TIME_EXE 						= ${PROGRAM_DIR}/wrfda/${WRF_3DVAR_EXE_VERSION}/var/build/da_advance_time.exe
	set WORKPATH               		= `pwd`

	

####################################################################################################

# ========================================================================
# 1. Create $DATE folder and link files for WRF runs
# ========================================================================
	# Setting up the time interation
	# -------------------------------
	# Note (2018.02.08)
	# 	- From today, I set that all the OPL and 3DVAR experiments will all start with 6-h spin-up.  
	#	  This would mean that both the OPL and 3DVAR runs have to skip the first cycle, as they 
	#	  link to previous 6-h forecasts from the spin-up runs.  I would have the following times:
	#		* DA_START_TIME: 			The current time (initialization time)
	#		* DA_PREVIOUS_6H_TIME: 	The initialization time of the spin-up runs
	#		* DA_END_TIME:				The time for checking the end cycle (last cycle)
	#		* FORECAST_END_TIME:		(seems not used by the script here...)
	set EXP_START_TIME 		= `${ADV_TIME_EXE} ${WPS_START_DATE} ${FORECAST_INI_FREQ}`
	
	set DA_START_TIME 		= ${EXP_START_TIME}
	set DA_PREVIOUS_6H_TIME = `${ADV_TIME_EXE} ${DA_START_TIME} -6`
	set DA_END_TIME   		= `${ADV_TIME_EXE} ${DA_START_TIME} ${FORECAST_INI_FREQ}`
	set FORECAST_END_TIME	= `${ADV_TIME_EXE} ${DA_START_TIME} ${FORECAST_HOURS}`

	while ( ${DA_END_TIME} <= ${WPS_END_DATE} )

		# 1.1. Folder preparation
		rm -rf ./${RUN_DIR}/${DA_START_TIME}
		mkdir  ./${RUN_DIR}/${DA_START_TIME}
		
		mkdir ./${RUN_DIR}/${DA_START_TIME}/cda
		mkdir ./${RUN_DIR}/${DA_START_TIME}/wrf

		cd 	./${RUN_DIR}/${DA_START_TIME}

		# 1.2. Time string preparation (for the current time)
		set yyyy1 = `echo $DA_START_TIME | cut -c1-4`
		set   mm1 = `echo $DA_START_TIME | cut -c5-6`
		set   dd1 = `echo $DA_START_TIME | cut -c7-8`
		set   hh1 = `echo $DA_START_TIME | cut -c9-10`		
		
		# 1.3. Linking files for UOU CDA
		# ------------------------------
		cd cda
			
			# Link the uou_cda.exe
			ln -sf ${UOU_CDA_EXE_PATH}/${UOU_CDA_EXE} .
			
			# Link the SM BEC STD file 
			#	- (2018.03.22) Note that rather than using month-year BEC, here I choose
			#	  the 3-year average monthly error statistics.  See rn180321 for more details.
			ln -sf ${UOU_CDA_BEC_PATH}/nc_files/std_all_3Yavg_${mm1}.nc CDA_BEC_STD.nc
			
			# Link the first guess file (wrfinput from the previous 6h spin-up runs!!!)
			ln -sf ../../../spinup/${DA_PREVIOUS_6H_TIME}/wrfvar_input_d01_${yyyy1}-${mm1}-${dd1}_${hh1}:00:00 wrfinput_ori
			cp wrfinput_ori wrfinput_cda
			
			# Link the satellite SM Observation
			# 	- Link it only for 00 and 12 UTC
			if (${hh1} == 12) then
				ln -sf ${UOU_CDA_SMOBS_PATH}/SMAP_L2SMP_E_descending_12UTC_${yyyy1}${mm1}${dd1}.nc satellite_obs_sm.nc
			endif
			
			if (${hh1} == 00) then
				ln -sf ${UOU_CDA_SMOBS_PATH}/SMAP_L2SMP_E_ascending_00UTC_${yyyy1}${mm1}${dd1}.nc satellite_obs_sm.nc
			endif			
		
		cd ..

		# 1.4. Linking files for WRF
		# --------------------------
		cd wrf
		
			# Link Table and Data files
			ln -sf ${PROGRAM_DIR}/wrf/${WRF_EXE_VERSION}/run/*.TBL .
			ln -sf ${PROGRAM_DIR}/wrf/${WRF_EXE_VERSION}/run/RRTMG_SW_DATA .
			ln -sf ${PROGRAM_DIR}/wrf/${WRF_EXE_VERSION}/run/RRTMG_LW_DATA .
			ln -sf ${PROGRAM_DIR}/wrf/${WRF_EXE_VERSION}/run/RRTM_DATA .
			ln -sf ${PROGRAM_DIR}/wrf/${WRF_EXE_VERSION}/run/ETAMPNEW_DATA .
			ln -sf ${PROGRAM_DIR}/wrf/${WRF_EXE_VERSION}/run/CAM_AEROPT_DATA .
			ln -sf ${PROGRAM_DIR}/wrf/${WRF_EXE_VERSION}/run/CAM_ABS_DATA .
	
			# Link ozone data for RRTMG radiation
			#	- See rn170324
			ln -sf ${PROGRAM_DIR}/wrf/${WRF_EXE_VERSION}/run/ozone* .

			# Link data for the CLM Land surface model
			ln -sf ${PROGRAM_DIR}/wrf/${WRF_EXE_VERSION}/run/CLM_* .	
	
			# Link .exe, wrfbdy, and name list
			ln -sf ${PROGRAM_DIR}/wrf/${WRF_EXE_VERSION}/main/wrf.exe .
			ln -sf ../../../real/${DA_START_TIME}/wrfbdy_d01 .
			ln -sf ../../../real/${DA_START_TIME}/namelist.input .
		
			# Link to wrfinput from the previous 6h spin-up runs!!!
			# ln -sf ../../spinup/${DA_PREVIOUS_6H_TIME}/wrfvar_input_d01_${yyyy1}-${mm1}-${dd1}_${hh1}:00:00 wrfinput_d01

		cd ..
		
		
		

		# 1.5. Finish the TIME folder.  Move on to the next TIME
		# ------------------------------------------------------
		cd ../..

		# Set the iteration variables
		set DA_START_TIME 		= `${ADV_TIME_EXE} ${DA_START_TIME} ${FORECAST_INI_FREQ}`
		set DA_PREVIOUS_6H_TIME = `${ADV_TIME_EXE} ${DA_START_TIME} -6`
		set DA_END_TIME 			= `${ADV_TIME_EXE} ${DA_START_TIME} ${FORECAST_INI_FREQ}`
		set FORECAST_END_TIME 	= `${ADV_TIME_EXE} ${DA_START_TIME} ${FORECAST_HOURS}`



	end
	
# ========================================================================
# 2. Conduct UOU CDA Experiment
# ========================================================================

set DA_START_TIME 		= ${EXP_START_TIME}
set DA_PREVIOUS_6H_TIME = `${ADV_TIME_EXE} ${DA_START_TIME} -6`
set DA_END_TIME   		= `${ADV_TIME_EXE} ${DA_START_TIME} ${FORECAST_INI_FREQ}`
set FORECAST_END_TIME	= `${ADV_TIME_EXE} ${DA_START_TIME} ${FORECAST_HOURS}`

while ( ${DA_END_TIME} <= ${WPS_END_DATE} )

	cd ./${RUN_DIR}/${DA_START_TIME}
	cd cda
	
	# 2.1. Create the name list
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



	# 2.2. Run the uou_cda.exe
	# ------------------------
	# Time string preparation (for the current time)
	set yyyy1 = `echo $DA_START_TIME | cut -c1-4`
	set   mm1 = `echo $DA_START_TIME | cut -c5-6`
	set   dd1 = `echo $DA_START_TIME | cut -c7-8`
	set   hh1 = `echo $DA_START_TIME | cut -c9-10`		
	
	if ((${hh1} == 12) || (${hh1} == 00)) then
		./${UOU_CDA_EXE}
	endif

	# 2.3. Link the analysis for WRF
	#	- Note the wrfinput_cda is not updated for 06 or 18 UTC
	cd ../wrf
	ln -sf ../cda/wrfinput_cda wrfinput_d01
	cd ..

	# 2.4. Finish the TIME folder.  Move on to the next TIME
	# ------------------------------------------------------
	cd ../..

	# Set the iteration variables
	set DA_START_TIME 		= `${ADV_TIME_EXE} ${DA_START_TIME} ${FORECAST_INI_FREQ}`
	set DA_PREVIOUS_6H_TIME = `${ADV_TIME_EXE} ${DA_START_TIME} -6`
	set DA_END_TIME 			= `${ADV_TIME_EXE} ${DA_START_TIME} ${FORECAST_INI_FREQ}`
	set FORECAST_END_TIME 	= `${ADV_TIME_EXE} ${DA_START_TIME} ${FORECAST_HOURS}`


	echo ${DA_START_TIME}
	echo ${DA_PREVIOUS_6H_TIME}
	echo ${DA_END_TIME}
end


# ========================================================================
# 3. Generate the PBS or SBATCH script (for WRF)
# ========================================================================
	# TIME PROCESS (same as the last section)
	set EXP_START_TIME 		= `${ADV_TIME_EXE} ${WPS_START_DATE} ${FORECAST_INI_FREQ}`

	set DA_START_TIME 		= ${EXP_START_TIME}
	set DA_PREVIOUS_6H_TIME = `${ADV_TIME_EXE} ${DA_START_TIME} -6`
	set DA_END_TIME   		= `${ADV_TIME_EXE} ${DA_START_TIME} ${FORECAST_INI_FREQ}`
	set FORECAST_END_TIME	= `${ADV_TIME_EXE} ${DA_START_TIME} ${FORECAST_HOURS}`

	cd ${RUN_DIR}

	# THE MAIN WHILE LOOP!!!
	while ( ${DA_END_TIME} <= ${WPS_END_DATE} )

		cd ${DA_START_TIME}/wrf
		
		pwd
		echo "This is here"
		set WORKSPACE		= `pwd`
		echo ${WORKSPACE}

# 3.1. Create a pbs script
# ----------------------------------------------------------------------------------------
if (${QUEUE_TYPE} == 'PBS') then
cat >! zz_runpbs.pbs << EOF
### file:  
#PBS -N ${JOBNAME}_${CASENUM}
#PBS -l nodes=${PBS_NODES}:ppn=${PBS_PPN}
#PBS -l mem=${PBS_MEM}gb
#PBS -l walltime=${PBS_WALLTIME}:00:00
#PBS -q ${PBS_QUEUE}

source ~/${MODULE_FILE}

cd ${WORKSPACE}
mpirun -n ${NPROC} -f \$PBS_NODEFILE ./wrf.exe

EOF

qsub zz_runpbs.pbs | sed 's/.repace.pace.gatech.edu//g' >& temp.txt	# This is used for GT
endif
## ----------------------------------------------------------------------------------------
## 3.2. Create a sbatch script
if (${QUEUE_TYPE} == 'SBATCH_CHPC') then
cat >! zz_runsbatch.slurm <<EOF
#!/bin/csh
#SBATCH --time=${SBATCH_CHPC_TIME}:00:00
#SBATCH --nodes=${SBATCH_CHPC_NODES}
#SBATCH --ntasks=${SBATCH_CHPC_NTASKS}
#SBATCH --account=${SBATCH_CHPC_ACCOUNT}
#SBATCH --partition=${SBATCH_CHPC_PARTITION}
#SBATCH -o slurm-%j.out-%N
#SBATCH -e slurm-%j.err-%N
#SBATCH -J ${JOBNAME}

source ~/${MODULE_FILE}

cd ${WORKSPACE}
mpirun -np \$SLURM_NTASKS ./wrf.exe

exit 0
EOF

sbatch zz_runsbatch.slurm | sed 's/Submitted batch job //g' >& temp.txt # This is used for UofU

endif
## ---------------------------------------------------------------------------------------
# 3.3. To Create a file that informs the job ID --------
set JOB_ID = `cat temp.txt`

cat >! zz_jobID.txt << EOF
${JOBNAME}.o${JOB_ID}
EOF

rm temp.txt
## ------------------------------------------------

		cd ../..

		# Set up time iteration
		set DA_START_TIME 		= `${ADV_TIME_EXE} ${DA_START_TIME} ${FORECAST_INI_FREQ}`
		set DA_PREVIOUS_6H_TIME = `${ADV_TIME_EXE} ${DA_START_TIME} -6`
		set DA_END_TIME 			= `${ADV_TIME_EXE} ${DA_START_TIME} ${FORECAST_INI_FREQ}`
		set FORECAST_END_TIME 	= `${ADV_TIME_EXE} ${DA_START_TIME} ${FORECAST_HOURS}`
	
	end


echo "------------------------------------------------------------------"
echo "--- End of runme_uou_cda.csh ------------------------------------"
echo "------------------------------------------------------------------"

