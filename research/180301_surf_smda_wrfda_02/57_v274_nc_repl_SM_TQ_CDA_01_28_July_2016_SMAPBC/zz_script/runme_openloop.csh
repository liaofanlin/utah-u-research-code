#!/bin/csh
#
set echo

echo "-------------------------------------------------------------------------"
echo "--- Beginning of runme_openloop.csh -------------------------------------"
echo "-------------------------------------------------------------------------"

# (2018.02.06)
#	- The main difference between runme_openloop.csh and runme_spinup.csh is 
#		* section 1.99.  There is no Section 1.99 in runme_openloop.csh.
#		* Variables RUN_DIR and JOBNAME

# (2018.02.06) 
# 	- To make this script very similar to runme_spinup.csh, I set the following variable
	set RUN_DIR								= openloop	# openloop or spinup
	set JOBNAME 							= WRF_OPL	# WRF_OPL or SPINUP

# (2017.08.24) Make the arguments same as those in 
#		-runme_openloop_cycling.csh
#		-runme_openloop.csh
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

		# Folder preparation
		rm -rf ./${RUN_DIR}/${DA_START_TIME}
		mkdir  ./${RUN_DIR}/${DA_START_TIME}

		cd 	 ./${RUN_DIR}/${DA_START_TIME}

		# Time string preparation (for the current time)
		set yyyy1 = `echo $DA_START_TIME | cut -c1-4`
		set   mm1 = `echo $DA_START_TIME | cut -c5-6`
		set   dd1 = `echo $DA_START_TIME | cut -c7-8`
		set   hh1 = `echo $DA_START_TIME | cut -c9-10`		

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
		ln -sf ../../real/${DA_START_TIME}/wrfbdy_d01 .
		ln -sf ../../real/${DA_START_TIME}/namelist.input .
		
		# Link to wrfinput from the previous 6h spin-up runs!!!
		ln -sf ../../spinup/${DA_PREVIOUS_6H_TIME}/wrfvar_input_d01_${yyyy1}-${mm1}-${dd1}_${hh1}:00:00 wrfinput_d01
		ln -sf ../../spinup/${DA_PREVIOUS_6H_TIME}/wrfvar_input_d02_${yyyy1}-${mm1}-${dd1}_${hh1}:00:00 wrfinput_d02


		cd ../..

		# Set the iteration variables
		set DA_START_TIME 		= `${ADV_TIME_EXE} ${DA_START_TIME} ${FORECAST_INI_FREQ}`
		set DA_PREVIOUS_6H_TIME = `${ADV_TIME_EXE} ${DA_START_TIME} -6`
		set DA_END_TIME 			= `${ADV_TIME_EXE} ${DA_START_TIME} ${FORECAST_INI_FREQ}`
		set FORECAST_END_TIME 	= `${ADV_TIME_EXE} ${DA_START_TIME} ${FORECAST_HOURS}`

	end
	
	
# ========================================================================
# 3. Generate the PBS or SBATCH script
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

		cd ${DA_START_TIME}
		set WORKSPACE		= `pwd`

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

		cd ..

		# Set up time iteration
		set DA_START_TIME 		= `${ADV_TIME_EXE} ${DA_START_TIME} ${FORECAST_INI_FREQ}`
		set DA_PREVIOUS_6H_TIME = `${ADV_TIME_EXE} ${DA_START_TIME} -6`
		set DA_END_TIME 			= `${ADV_TIME_EXE} ${DA_START_TIME} ${FORECAST_INI_FREQ}`
		set FORECAST_END_TIME 	= `${ADV_TIME_EXE} ${DA_START_TIME} ${FORECAST_HOURS}`
	
	end


echo "------------------------------------------------------------------"
echo "--- End of runme_openloop.csh ------------------------------------"
echo "------------------------------------------------------------------"

