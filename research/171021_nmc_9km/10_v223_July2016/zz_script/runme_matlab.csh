#!/bin/csh
#

set echo
echo "-------------------------------------------------------------------------"
echo "--- Beginning of runme_matlab.csh ---------------------------------------"
echo "-------------------------------------------------------------------------"
# Note (2017.09.12): Make the arguement same for all scenarios

set WPS_START_DATE							= $1
set WPS_END_DATE 								= $2
set PROGRAM_DIR								= $3

set CASENUM										= $4
set FORECAST_HOURS 							= $5
set FORECAST_INI_FREQ						= $6

set MAX_DOM										= $7
set PBS_PPN_MATLAB							= $8
set PBS_MEM_MATLAB							= $9

set PBS_WALLTIME_MATLAB						= $10
set PBS_QUEUE_MATLAB							= $11
set WRFDA_ST4_DIR								= $12

set WRFDA_RAIN_DIR_DA 						= $13
set WRFDA_RAIN_DA_TYPE						= $14
set MATLAB_SCENARIO_01						= $15

set MATLAB_SCENARIO_02						= $16 
set WPS_GEN_END_DATE 						= $17
set MATLAB_SPECIAL_WRFOUT_EXTRACTION	= $18

set SMDA_OBS_FILEPATH						= $19
set WRF_HISTORY_INTERVAL_D01				= $20
set WRF_3DVAR_EXE_VERSION					= $21

set MODULE_FILE								= $22
set MATLAB_SCENARIO_03			 			= $23
set MATLAB_SCENARIO_05						= $24

set MATLAB_SCENARIO_LOC_STR				= $25
set MATLAB_SCENARIO_06						= $26
set HYDRO_AGGFACTRT							= $27

set QUEUE_TYPE									= $28
set SBATCH_CHPC_TIME_SHORT					= $29
set SBATCH_CHPC_NODES_SHORT				= $30

set SBATCH_CHPC_NTASKS_SHORT				= $31
set SBATCH_CHPC_ACCOUNT_SHORT				= $32
set SBATCH_CHPC_PARTITION_SHORT			= $33

set SBATCH_CHPC_NPROC_SHORT				= $34

set ADV_TIME_EXE 								= ${PROGRAM_DIR}/wrfda/${WRF_3DVAR_EXE_VERSION}/var/build/da_advance_time.exe
set WORKPATH               				= `pwd`

####################################################################################################

## Scenario 01: classical interpolation switch
## --------------------------------------------
	# Note (2017.09.12): Not updated for CHPC
	if ( ${MATLAB_SCENARIO_01} == true ) then
	
		csh zz_script/matlab_scenario_01.csh \
		${WPS_START_DATE}					${WPS_END_DATE}					${PROGRAM_DIR} \
		${CASENUM}							${FORECAST_HOURS}					${FORECAST_INI_FREQ} \
		${MAX_DOM}							${PBS_PPN_MATLAB}					${PBS_MEM_MATLAB} \
		${PBS_WALLTIME_MATLAB}			${PBS_QUEUE_MATLAB}				${WRFDA_ST4_DIR} \
		${WRFDA_RAIN_DIR_DA}				${WRFDA_RAIN_DA_TYPE}			${MATLAB_SCENARIO_01} \
		${MATLAB_SCENARIO_02}			${WPS_GEN_END_DATE}				${MATLAB_SPECIAL_WRFOUT_EXTRACTION} \
		${SMDA_OBS_FILEPATH}				${WRF_HISTORY_INTERVAL_D01}	${WRF_3DVAR_EXE_VERSION} \
		${MODULE_FILE}						${MATLAB_SCENARIO_03} 
	
	endif # end of if-loop for ( ${MATLAB_SCENARIO_01} == true ) 

###################################################################################################################
## SCENARIO 02: 6h rainfall interpolation
## --------------------------------------
	# Note (2017.09.12): Not updated for CHPC
	if ( ${MATLAB_SCENARIO_02} == true ) then

		csh zz_script/matlab_scenario_02.csh \
		${WPS_START_DATE}					${WPS_END_DATE}					${PROGRAM_DIR} \
		${CASENUM}							${FORECAST_HOURS}					${FORECAST_INI_FREQ} \
		${MAX_DOM}							${PBS_PPN_MATLAB}					${PBS_MEM_MATLAB} \
		${PBS_WALLTIME_MATLAB}			${PBS_QUEUE_MATLAB}				${WRFDA_ST4_DIR} \
		${WRFDA_RAIN_DIR_DA}				${WRFDA_RAIN_DA_TYPE}			${MATLAB_SCENARIO_01} \
		${MATLAB_SCENARIO_02}			${WPS_GEN_END_DATE}				${MATLAB_SPECIAL_WRFOUT_EXTRACTION} \
		${SMDA_OBS_FILEPATH}				${WRF_HISTORY_INTERVAL_D01}	${WRF_3DVAR_EXE_VERSION} \
		${MODULE_FILE}						${MATLAB_SCENARIO_03} 

	endif

###################################################################################################################
## Scenario 03: 1h rainfall interpolation
## --------------------------------------

	if ( ${MATLAB_SCENARIO_03} == true ) then

		csh zz_script/matlab_scenario_03.csh \
		${WPS_START_DATE}					${WPS_END_DATE}					${PROGRAM_DIR} \
		${CASENUM}							${FORECAST_HOURS}					${FORECAST_INI_FREQ} \
		${MAX_DOM}							${PBS_PPN_MATLAB}					${PBS_MEM_MATLAB} \
		${PBS_WALLTIME_MATLAB}			${PBS_QUEUE_MATLAB}				${WRFDA_ST4_DIR} \
		${WRFDA_RAIN_DIR_DA}				${WRFDA_RAIN_DA_TYPE}			${MATLAB_SCENARIO_01} \
		${MATLAB_SCENARIO_02}			${WPS_GEN_END_DATE}				${MATLAB_SPECIAL_WRFOUT_EXTRACTION} \
		${SMDA_OBS_FILEPATH}				${WRF_HISTORY_INTERVAL_D01}	${WRF_3DVAR_EXE_VERSION} \
		${MODULE_FILE}						${MATLAB_SCENARIO_03}			${MATLAB_SCENARIO_05} \
		${MATLAB_SCENARIO_LOC_STR}		${MATLAB_SCENARIO_06}			${HYDRO_AGGFACTRT} \
		${QUEUE_TYPE}						${SBATCH_CHPC_TIME_SHORT}		${SBATCH_CHPC_NODES_SHORT} \
		${SBATCH_CHPC_NTASKS_SHORT}	${SBATCH_CHPC_ACCOUNT_SHORT}	${SBATCH_CHPC_PARTITION_SHORT} \
		${SBATCH_CHPC_NPROC_SHORT}
	endif

###################################################################################################################
## Scenario 05: 1h rainfall interpolation for WRF-Hydro simulations
## ----------------------------------------------------------------
	# Note (2017.09.12): Not updated for CHPC
	if ( ${MATLAB_SCENARIO_05} == true ) then

		csh zz_script/matlab_scenario_05.csh \
		${WPS_START_DATE}					${WPS_END_DATE}					${PROGRAM_DIR} \
		${CASENUM}							${FORECAST_HOURS}					${FORECAST_INI_FREQ} \
		${MAX_DOM}							${PBS_PPN_MATLAB}					${PBS_MEM_MATLAB} \
		${PBS_WALLTIME_MATLAB}			${PBS_QUEUE_MATLAB}				${WRFDA_ST4_DIR} \
		${WRFDA_RAIN_DIR_DA}				${WRFDA_RAIN_DA_TYPE}			${MATLAB_SCENARIO_01} \
		${MATLAB_SCENARIO_02}			${WPS_GEN_END_DATE}				${MATLAB_SPECIAL_WRFOUT_EXTRACTION} \
		${SMDA_OBS_FILEPATH}				${WRF_HISTORY_INTERVAL_D01}	${WRF_3DVAR_EXE_VERSION} \
		${MODULE_FILE}						${MATLAB_SCENARIO_03}			${MATLAB_SCENARIO_05} \
		${MATLAB_SCENARIO_LOC_STR}

	endif

###################################################################################################################
## Scenario 06: process ST4 rainfall for tRIBS (Turkey Basin)
## ----------------------------------------------------------------
	# Note (2017.09.12): Not updated for CHPC
	if ( ${MATLAB_SCENARIO_06} == true ) then

		csh zz_script/matlab_scenario_06.csh \
		${WPS_START_DATE}					${WPS_END_DATE}					${PROGRAM_DIR} \
		${CASENUM}							${FORECAST_HOURS}					${FORECAST_INI_FREQ} \
		${MAX_DOM}							${PBS_PPN_MATLAB}					${PBS_MEM_MATLAB} \
		${PBS_WALLTIME_MATLAB}			${PBS_QUEUE_MATLAB}				${WRFDA_ST4_DIR} \
		${WRFDA_RAIN_DIR_DA}				${WRFDA_RAIN_DA_TYPE}			${MATLAB_SCENARIO_01} \
		${MATLAB_SCENARIO_02}			${WPS_GEN_END_DATE}				${MATLAB_SPECIAL_WRFOUT_EXTRACTION} \
		${SMDA_OBS_FILEPATH}				${WRF_HISTORY_INTERVAL_D01}	${WRF_3DVAR_EXE_VERSION} \
		${MODULE_FILE}						${MATLAB_SCENARIO_03}			${MATLAB_SCENARIO_05} \
		${MATLAB_SCENARIO_LOC_STR}		${MATLAB_SCENARIO_06}			${HYDRO_AGGFACTRT}

	endif

echo "-------------------------------------------------------------------------"
echo "--- Finishing the runme_matlab.csh --------------------------------------"
echo "-------------------------------------------------------------------------"


