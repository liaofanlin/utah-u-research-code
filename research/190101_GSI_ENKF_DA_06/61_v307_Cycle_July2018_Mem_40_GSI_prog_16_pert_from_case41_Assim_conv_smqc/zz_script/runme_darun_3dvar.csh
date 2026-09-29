#!/bin/csh
#

set echo
echo "-------------------------------------------------------------------------"
echo "--- Beginning of runme_darun_3dvar.csh ----------------------------------"
echo "-------------------------------------------------------------------------"

	# 2017.08.24: The arguments have to be the same as those files of
	#	- runme_darun_3dvar.csh
	#	- runme_darun_4dvar.csh
	#	- runme_darun_4dvar_cycling.csh
	set PROGRAM_DIR						= $1
	set CASENUM								= $2
	set WPS_LON								= $3
	set WPS_LAT								= $4
	
	set WPS_START_DATE					= $5
	set WPS_END_DATE						= $6
	set WPS_GEN_END_DATE					= $7 	# Not used (2013.09.03)
	set WPS_FNL_DIR						= $8
		
	set WRF_SF_SURFACE_PHYSICS			= $9
	set WRF_NUM_SOIL_LAYERS				= $10
	set WRF_MP_PHYSICS					= $11
	set WRF_RA_SW_PHYSICS				= $12
	
	set GEN_BE_NL_CV_OPTIONS			= $13
	set GEN_BE_BIN_TYPE					= $14
	set WRFDA_CHECK_MAX_IV				= $15
	set WRFDA_USE_AMSUBOBS				= $16
	
	set WRFDA_USE_RAINOBS				= $17	
	set WRFDA_THIN_MESH_CONV			= "$18"
	set WRFDA_ST4_DIR						= $19
	set WRFDA_RAIN_DIR_DA				= $20
	
	set DXDY_D01							= $21
	set WRF_TIMESTEP						= $22
	set E_VERT								= $23
	set E_WE_D01							= $24
	
	set E_SN_D01							= $25
	set MAX_DOM								= $26
	set E_WE_D02							= $27
	set E_SN_D02							= $28
	
	set DXDY_D02							= $29
	set I_PARENT_START_D02				= $30
	set J_PARENT_START_D02				= $31
	set WRFDA_TIME_STEP					= $32
	
	set WRFDA_LEN_SCALING				= $33
	set E_WE_D03							= $34
	set E_SN_D03							= $35
	set DXDY_D03							= $36
	
	set I_PARENT_START_D03				= $37
	set J_PARENT_START_D03				= $38
	set PBS_QUEUE							= $39
	set WRFDA_CODE							= $40	# Not used (2017.08.25)
		
	set PBS_MEM 							= $41
	set PBS_PPN								= $42
	set PBS_WALLTIME						= $43
	set WRFDA_MAX_ERROR_RAIN			= $44
		
	set WRFDA_RAIN_DA_TYPE 				= $45
	set WRF_4DVAR_SWITCH					= $46
	set SMDA_SWITCH						= $47
	set WRFDA_LEN04_SCALING				= $48

	set SMDA_EXE_PATH 					= $49
	set SMDA_NX								= $50
	set SMDA_NY								= $51
	set SMDA_NZ								= $52

	set SMDA_WRFINPUT_FILE				= $53
	set SMDA_BEC_PATH						= $54
	set SMDA_BEC_FILENAME				= $55
	set SMDA_OBS_FILENAME				= $56
	
	set SMDA_OBS_FILEPATH				= $57
	set CYCLING_MODE						= $58
	set FORECAST_INI_FREQ				= $59
	set SMDA_DA_STRATEGY					= $60
	
	set PBS_NODES							= $61
	set WRF_EXE_VERSION					= $62
	set WRF_3DVAR_EXE_VERSION			= $63
	set WRF_4DVAR_EXE_VERSION			= $64
	
	set WRFPLUS_EXE_VERSION				= $65
	set MODULE_FILE						= $66
	set WRFDA_I_PARENT_START			= $67
	set WRFDA_J_PARENT_START			= $68
	
	set DA_SPECIAL_MODE01				= $69
	set WRF_RA_LW_PHYSICS				= $70
	set WRF_BL_PBL_PHYSICS				= $71
	set WRF_CU_PHYSICS_D01				= $72
	
	set NC_REPL_PATH						= $73
	set QUEUE_TYPE							= $74
	set WRF_3DVAR_SWITCH					= $75
	set WRFDA_PSOT_SWITCH				= $76
	
	set SBATCH_CHPC_TIME					= $77
	set SBATCH_CHPC_NODES				= $78
	set SBATCH_CHPC_NTASKS				= $79
	set SBATCH_CHPC_ACCOUNT				= $80
	
	set SBATCH_CHPC_PARTITION			= $81
	set SBATCH_CHPC_NPROC				= $82
	set SBATCH_CHPC_TIME_SHORT			= $83
	set SBATCH_CHPC_NODES_SHORT		= $84

	set SBATCH_CHPC_NTASKS_SHORT		= $85
	set SBATCH_CHPC_ACCOUNT_SHORT		= $86
	set SBATCH_CHPC_PARTITION_SHORT	= $87
	set SBATCH_CHPC_NPROC_SHORT		= $88
	
	set NPROC								= $89
	set GEN_BE_CYCLE_SWITCH				= $90
	set GEN_BE_UNIVERSE_SWITCH			= $91
	set WRFDA_CLOUD_CV_OPTIONS			= $92
	
	set WRF_SF_SFCLAY_PHYSICS			= $93
	set WRFDA_OB_FORMAT					= $94
	set WRFDA_NCL_PLOTS_SWITCH			= $95
	set OBSPROC_WINDOW_HOUR				= $96
	
	set WRFDA_THIN_COV_ASCII			= $97
	set WRFDA_USE_SYNOPOBS				= $98
	set WRFDA_USE_SHIPSOBS				= $99
	set WRFDA_USE_METAROBS				= $100
	
	set WRFDA_USE_SOUNDOBS				= $101
	set WRFDA_USE_PILOTOBS				= $102
	set WRFDA_USE_AIREPOBS				= $103
	set WRFDA_USE_GEOAMVOBS				= $104
	
	set WRFDA_USE_POLARAMVOBS			= $105
	set WRFDA_USE_BOGUSOBS				= $106
	set WRFDA_USE_BUOYOBS				= $107
	set WRFDA_USE_PROFILEROBS			= $108
	
	set WRFDA_USE_SATEMOBS				= $109
	set WRFDA_USE_GPSPWOBS				= $110
	set WRFDA_USE_GPSZTDOBS				= $111
	set WRFDA_USE_GPSREFOBS				= $112
	
	set WRFDA_USE_QSCATOBS				= $113	
	set WRFDA_3DVAR_D01_SWITCH			= $114
	set WRFDA_3DVAR_D02_SWITCH			= $115
	set WRFDA_SFC_ASSI_OPTIONS			= $116

	set ADV_TIME_EXE 						= ${PROGRAM_DIR}/wrfda/${WRF_3DVAR_EXE_VERSION}/var/build/da_advance_time.exe

# =======================================================================================================
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


while ( ${DA_END_TIME} <= ${WPS_END_DATE} )

	rm -rf ./3dvar/${DA_START_TIME}
	mkdir  ./3dvar/${DA_START_TIME}
	
	mkdir  ./3dvar/${DA_START_TIME}/3dvar_d01
	mkdir  ./3dvar/${DA_START_TIME}/psot_d01
	mkdir  ./3dvar/${DA_START_TIME}/ncl_plots_d01

	mkdir  ./3dvar/${DA_START_TIME}/3dvar_d02
	mkdir  ./3dvar/${DA_START_TIME}/psot_d02
	mkdir  ./3dvar/${DA_START_TIME}/ncl_plots_d02

	mkdir ./3dvar/${DA_START_TIME}/zz_script
	cp zz_script/darun_3dvar.csh 		./3dvar/${DA_START_TIME}/zz_script/
	cp zz_script/darun_psot.csh 		./3dvar/${DA_START_TIME}/zz_script/
	cp zz_script/darun_ncl_plots.csh ./3dvar/${DA_START_TIME}/zz_script/
	cp zz_script/darun_3dvar_wrf.csh	./3dvar/${DA_START_TIME}/zz_script/

	cd ./3dvar/${DA_START_TIME}


# -------------------------------------------------------------------------------------------------
# ---------------Under DA_START_TIME --------------------------------------------------------------
# -------------------------------------------------------------------------------------------------
cat >! zz_runme_darun_3dvar.csh << EOF
#!/bin/csh
#

	set echo
	echo "-------------------------------------------------------------------------"
	echo "--- Running the runme_darun_3dvar.csh------------------------------------"
	echo "-------------------------------------------------------------------------"

	# 2017.08.25: Make the arguments the same as above
	set PROGRAM_DIR						= $1
	set CASENUM								= $2
	set WPS_LON								= $3
	set WPS_LAT								= $4
	
	set WPS_START_DATE					= $5
	set WPS_END_DATE						= $6
	set WPS_GEN_END_DATE					= $7 	# Not used (2013.09.03)
	set WPS_FNL_DIR						= $8
		
	set WRF_SF_SURFACE_PHYSICS			= $9
	set WRF_NUM_SOIL_LAYERS				= $10
	set WRF_MP_PHYSICS					= $11
	set WRF_RA_SW_PHYSICS				= $12
	
	set GEN_BE_NL_CV_OPTIONS			= $13
	set GEN_BE_BIN_TYPE					= $14
	set WRFDA_CHECK_MAX_IV				= $15
	set WRFDA_USE_AMSUBOBS				= $16
	
	set WRFDA_USE_RAINOBS				= $17	
	set WRFDA_THIN_MESH_CONV			= "$18"
	set WRFDA_ST4_DIR						= $19
	set WRFDA_RAIN_DIR_DA				= $20
	
	set DXDY_D01							= $21
	set WRF_TIMESTEP						= $22
	set E_VERT								= $23
	set E_WE_D01							= $24
	
	set E_SN_D01							= $25
	set MAX_DOM								= $26
	set E_WE_D02							= $27
	set E_SN_D02							= $28
	
	set DXDY_D02							= $29
	set I_PARENT_START_D02				= $30
	set J_PARENT_START_D02				= $31
	set WRFDA_TIME_STEP					= $32
	
	set WRFDA_LEN_SCALING				= $33
	set E_WE_D03							= $34
	set E_SN_D03							= $35
	set DXDY_D03							= $36
	
	set I_PARENT_START_D03				= $37
	set J_PARENT_START_D03				= $38
	set PBS_QUEUE							= $39
	set WRFDA_CODE							= $40	# Not used (2017.08.25)
		
	set PBS_MEM 							= $41
	set PBS_PPN								= $42
	set PBS_WALLTIME						= $43
	set WRFDA_MAX_ERROR_RAIN			= $44
		
	set WRFDA_RAIN_DA_TYPE 				= $45
	set WRF_4DVAR_SWITCH					= $46
	set SMDA_SWITCH						= $47
	set WRFDA_LEN04_SCALING				= $48

	set SMDA_EXE_PATH 					= $49
	set SMDA_NX								= $50
	set SMDA_NY								= $51
	set SMDA_NZ								= $52

	set SMDA_WRFINPUT_FILE				= $53
	set SMDA_BEC_PATH						= $54
	set SMDA_BEC_FILENAME				= $55
	set SMDA_OBS_FILENAME				= $56
	
	set SMDA_OBS_FILEPATH				= $57
	set CYCLING_MODE						= $58
	set FORECAST_INI_FREQ				= $59
	set SMDA_DA_STRATEGY					= $60
	
	set PBS_NODES							= $61
	set WRF_EXE_VERSION					= $62
	set WRF_3DVAR_EXE_VERSION			= $63
	set WRF_4DVAR_EXE_VERSION			= $64
	
	set WRFPLUS_EXE_VERSION				= $65
	set MODULE_FILE						= $66
	set WRFDA_I_PARENT_START			= $67
	set WRFDA_J_PARENT_START			= $68
	
	set DA_SPECIAL_MODE01				= $69
	set WRF_RA_LW_PHYSICS				= $70
	set WRF_BL_PBL_PHYSICS				= $71
	set WRF_CU_PHYSICS_D01				= $72
	
	set NC_REPL_PATH						= $73
	set QUEUE_TYPE							= $74
	set WRF_3DVAR_SWITCH					= $75
	set WRFDA_PSOT_SWITCH				= $76
	
	set SBATCH_CHPC_TIME					= $77
	set SBATCH_CHPC_NODES				= $78
	set SBATCH_CHPC_NTASKS				= $79
	set SBATCH_CHPC_ACCOUNT				= $80
	
	set SBATCH_CHPC_PARTITION			= $81
	set SBATCH_CHPC_NPROC				= $82
	set SBATCH_CHPC_TIME_SHORT			= $83
	set SBATCH_CHPC_NODES_SHORT		= $84

	set SBATCH_CHPC_NTASKS_SHORT		= $85
	set SBATCH_CHPC_ACCOUNT_SHORT		= $86
	set SBATCH_CHPC_PARTITION_SHORT	= $87
	set SBATCH_CHPC_NPROC_SHORT		= $88
	
	set NPROC								= $89
	set GEN_BE_CYCLE_SWITCH				= $90
	set GEN_BE_UNIVERSE_SWITCH			= $91
	set WRFDA_CLOUD_CV_OPTIONS			= $92
	
	set WRF_SF_SFCLAY_PHYSICS			= $93
	set WRFDA_OB_FORMAT					= $94
	set WRFDA_NCL_PLOTS_SWITCH			= $95
	set OBSPROC_WINDOW_HOUR				= $96
	
	set WRFDA_THIN_COV_ASCII			= $97
	set WRFDA_USE_SYNOPOBS				= $98
	set WRFDA_USE_SHIPSOBS				= $99
	set WRFDA_USE_METAROBS				= $100
	
	set WRFDA_USE_SOUNDOBS				= $101
	set WRFDA_USE_PILOTOBS				= $102
	set WRFDA_USE_AIREPOBS				= $103
	set WRFDA_USE_GEOAMVOBS				= $104
	
	set WRFDA_USE_POLARAMVOBS			= $105
	set WRFDA_USE_BOGUSOBS				= $106
	set WRFDA_USE_BUOYOBS				= $107
	set WRFDA_USE_PROFILEROBS			= $108
	
	set WRFDA_USE_SATEMOBS				= $109
	set WRFDA_USE_GPSPWOBS				= $110	
	set WRFDA_USE_GPSZTDOBS				= $111
	set WRFDA_USE_GPSREFOBS				= $112
	
	set WRFDA_USE_QSCATOBS				= $113
	set WRFDA_3DVAR_D01_SWITCH			= $114
	set WRFDA_3DVAR_D02_SWITCH			= $115
	set WRFDA_SFC_ASSI_OPTIONS			= $116
	
	set ADV_TIME_EXE 						= ${PROGRAM_DIR}/wrfda/${WRF_3DVAR_EXE_VERSION}/var/build/da_advance_time.exe

	# Other Setup
	set DA_START_TIME 	= ${DA_START_TIME}
	set DA_END_TIME 		= ${DA_END_TIME}
# --------------------------------------------------------------------------------------------------------------



	echo "Current DA_START_TIME = " ${DA_START_TIME}
	echo "Current path is at:" `pwd`

	# ===============================
	# Determine which domain where I will run WRFDA
	# ===============================
	if (\${WRFDA_3DVAR_D01_SWITCH} == 'true' & \${WRFDA_3DVAR_D02_SWITCH} == 'true') then
		set FORLOOP_STR = "d01 d02"
	else if (\${WRFDA_3DVAR_D01_SWITCH} == 'true' & \${WRFDA_3DVAR_D02_SWITCH} == 'false') then
		set FORLOOP_STR = "d01"
	else if (\${WRFDA_3DVAR_D01_SWITCH} == 'false' & \${WRFDA_3DVAR_D02_SWITCH} == 'true') then
		set FORLOOP_STR = "d02"
	endif

	echo "FORLOOP_STR=",\${FORLOOP_STR}

	# ===============================
	# 2. For loop
	# ===============================
	
	foreach WRFDA_DOMAIN (\${FORLOOP_STR})
	
		# 2.1 WRF 3DVAR
		# --------------
		# Note (2018.09.20): I am forcing 3DVAR to use the following modules!!
		source ~/zpu-group10/installation/module_12_20170818.txt
		
			if (\${WRF_3DVAR_SWITCH} == 'true') then
				time csh ./zz_script/darun_3dvar.csh \
				\${WRF_SF_SURFACE_PHYSICS} 	\${WRF_NUM_SOIL_LAYERS} 	\${WRF_MP_PHYSICS} 			\${GEN_BE_NL_CV_OPTIONS} \
				\${GEN_BE_BIN_TYPE}				\${WRFDA_CHECK_MAX_IV}		\${DXDY_D01}					\${WRF_TIMESTEP} \
				\${WRFDA_USE_AMSUBOBS}	 		\${WRFDA_USE_RAINOBS}		"\${WRFDA_THIN_MESH_CONV}" \${E_VERT} \
				\${WRF_RA_SW_PHYSICS} 			\${E_WE_D01}					\${E_SN_D01}					\${DA_START_TIME} \
				\${DA_END_TIME} 					\${PROGRAM_DIR} 				\${WRFDA_ST4_DIR} 			\${WRFDA_RAIN_DIR_DA} \
				\${WRFDA_TIME_STEP}				\${WRFDA_LEN_SCALING}		\${WRFDA_CODE}					\${WRFDA_MAX_ERROR_RAIN} \
				\${WRFDA_RAIN_DA_TYPE}			\${WRFDA_LEN04_SCALING}		\${CYCLING_MODE}				\${WPS_START_DATE} \
				\${WRF_4DVAR_EXE_VERSION}		\${WRFPLUS_EXE_VERSION}		\${WRFDA_I_PARENT_START}	\${WRFDA_J_PARENT_START} \
				\${DA_SPECIAL_MODE01}			\${SMDA_NX}						\${SMDA_NY}						\${SMDA_NZ} \
				\${WRF_RA_LW_PHYSICS}			\${WRF_BL_PBL_PHYSICS}		\${WRF_CU_PHYSICS_D01}		\${NC_REPL_PATH} \
				\${QUEUE_TYPE}						\${WRF_3DVAR_EXE_VERSION}	\${NPROC}						\${GEN_BE_CYCLE_SWITCH} \
				\${GEN_BE_UNIVERSE_SWITCH}		\${WRFDA_CLOUD_CV_OPTIONS}	\${WRF_SF_SFCLAY_PHYSICS}	\${WRFDA_OB_FORMAT} \
				\${OBSPROC_WINDOW_HOUR}			\${WRFDA_THIN_COV_ASCII}	\${WRFDA_USE_SYNOPOBS}		\${WRFDA_USE_SHIPSOBS} \
				\${WRFDA_USE_METAROBS}			\${WRFDA_USE_SOUNDOBS}		\${WRFDA_USE_PILOTOBS}		\${WRFDA_USE_AIREPOBS} \
				\${WRFDA_USE_GEOAMVOBS}			\${WRFDA_USE_POLARAMVOBS}	\${WRFDA_USE_BOGUSOBS}		\${WRFDA_USE_BUOYOBS} \
				\${WRFDA_USE_PROFILEROBS} 		\${WRFDA_USE_SATEMOBS}		\${WRFDA_USE_GPSPWOBS}		\${WRFDA_USE_GPSZTDOBS} \
				\${WRFDA_USE_GPSREFOBS}			\${WRFDA_USE_QSCATOBS}		\${WRFDA_DOMAIN}				\${E_WE_D02} \
				\${E_SN_D02}						\${DXDY_D02}					\${WRFDA_SFC_ASSI_OPTIONS}
			endif

		# 2.2 PSOT
		# --------
			if (\${WRFDA_PSOT_SWITCH} == 'true') then
				csh ./zz_script/darun_psot.csh \
				\${WRFDA_DOMAIN}

			endif
		
		# 2.3 NCL PLOT
		# -------------
			if (\${WRFDA_NCL_PLOTS_SWITCH} == 'true' ) then
				csh ./zz_script/darun_ncl_plots.csh \
				\${DA_START_TIME}	\${WRFDA_DOMAIN}
		
			endif
	
		# 2.4 WRF
		# -------------
		# NOTE: I skip the update_bdy step!	
		# Note (2018.09.20): This use the default source modules
		source ~/${MODULE_FILE}
		
			csh ./zz_script/darun_3dvar_wrf.csh \
				\${NPROC}				\${PROGRAM_DIR}	\${DA_START_TIME}		\${SMDA_SWITCH} \
				\${WRF_EXE_VERSION}	\${QUEUE_TYPE}
			


	end
EOF


set WORKSPACE		= `pwd`
set JOBNAME 		= WRF_3DVAR

## 4. Loading module and submitting pbs
## ---------------------------------

# 4.1. Create a pbs script
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
time csh zz_runme_darun_3dvar.csh

EOF

qsub zz_runpbs.pbs | sed 's/.repace.pace.gatech.edu//g' >& temp.txt	# This is used for GT
endif
## ----------------------------------------------------------------------------------------
## 4.2. Create a sbatch script
if (${QUEUE_TYPE} == 'SBATCH_CHPC') then
cat >! zz_runsbatch.slurm <<EOF
#!/bin/csh
#SBATCH --time=${SBATCH_CHPC_TIME}:00:00
#SBATCH --nodes=${SBATCH_CHPC_NODES}
#SBATCH --ntasks=${SBATCH_CHPC_NTASKS}
#SBATCH --account=${SBATCH_CHPC_ACCOUNT}
#SBATCH --partition=${SBATCH_CHPC_PARTITION}
#SBATCH -o slurm-%j.out-%N
#SBATCH -J ${JOBNAME}

source ~/${MODULE_FILE}

cd ${WORKSPACE}
time csh zz_runme_darun_3dvar.csh

exit 0
EOF

sbatch zz_runsbatch.slurm | sed 's/Submitted batch job //g' >& temp.txt # This is used for UofU

endif
## ---------------------------------------------------------------------------------------
# To Create a file that informs the job ID --------
set JOB_ID = `cat temp.txt`

cat >! zz_jobID.txt << EOF
${JOBNAME}.o${JOB_ID}
EOF

rm temp.txt
## ------------------------------------------------


	cd ../..

# --------------------------------------------------------------------------------
	
	# Set up time iteration
	set DA_START_TIME 		= `${ADV_TIME_EXE} ${DA_START_TIME} ${FORECAST_INI_FREQ}`
	set DA_PREVIOUS_6H_TIME = `${ADV_TIME_EXE} ${DA_START_TIME} -6`
	set DA_END_TIME 			= `${ADV_TIME_EXE} ${DA_START_TIME} ${FORECAST_INI_FREQ}`
	
end


echo "------------------------------------------------------------------"
echo "--- End of runme_darun_3dvar.csh ---------------------------------"
echo "------------------------------------------------------------------"



