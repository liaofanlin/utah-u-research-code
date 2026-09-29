#!/bin/csh -x
#

# Readme (GT PACE)
# ----------------
	# 1. EXAMPLE (run it at wordspace): $ csh zz_script/runme_job_del.csh 2009061018 2009061518 gen_be gen_be ~/data2/installation/04_install/wrfda/WRFDA3.7.1_4dvar_dm
	# 2. Need to manually specify the text string in the sed function!! 
	# 
	#
	
	
	
# Readme (UU CHPC)
# ----------------
	 # 1. EXAMPLE: 
	 #		$ csh zz_script/runme_job_del.csh 2016050300 2016092800 spinup 12 SPINUP ~/zpu-group10/installation/12_install/wrfda/WRFDA3.9.1_3dvar_dm 
	 #		$ csh zz_script/runme_job_del.csh 2016060106 2016082900 openloop 6 WRF_OPL ~/zpu-group10/installation/12_install/wrfda/WRFDA3.9.1_3dvar_dm 
	 #		$ csh zz_script/runme_job_del.csh 2016060106 2016062900 uou_cda 6 UOU_CDA ~/zpu-group10/installation/12_install/wrfda/WRFDA3.9.1_3dvar_dm 
	 
	 #	2. Combination for JOB_DIR and JOB_NAME
	 # ---------------------------------------
	 #		JOB_DIR	| JOB_NAME
	 #		-------------------
	 #		spinup	| SPINUP
	 #		openloop	| WRF_OPL
	 # 	uou_cda	| UOU_CDA

set echo

set WPS_START_DATE 		= $1
set WPS_END_DATE			= $2
set JOB_DIR					= $3	# JOB_DIR CAN BE: darun (if non-cycling), openloop (if non-cycling), and matlab_post
set FORECAST_INI_FREQ 	= $4

set JOB_NAME 				= $5
set WRFDA_DIR				= $6


set ADV_TIME_EXE 		= ${WRFDA_DIR}/var/build/da_advance_time.exe

# ----------------------------------------------------------------------------------------------------------------------

# Job cancellation
# ----------------

	set DA_START_DATE = ${WPS_START_DATE}
	set DA_END_DATE   = `${ADV_TIME_EXE} ${DA_START_DATE} ${FORECAST_INI_FREQ}`

	while ( ${DA_END_DATE} <= ${WPS_END_DATE} )

		# For spinup and openloop
		if ((${JOB_NAME} == 'SPINUP') || (${JOB_NAME} == 'WRF_OPL')) then
			cd ${JOB_DIR}/${DA_START_DATE}	
			set JOBID = `head -n 1 zz_jobID.txt | sed "s/${JOB_NAME}.o//g"`
			
			scancel ${JOBID}	
		
			cd ../..	
		endif
		
		# For uou_cda wrf runs
		if (${JOB_NAME} == 'UOU_CDA') then
			cd ${JOB_DIR}/${DA_START_DATE}/wrf
			set JOBID = `head -n 1 zz_jobID.txt | sed "s/${JOB_NAME}.o//g"`
			
			scancel ${JOBID}	
		
			cd ../../..	
		endif		
		
		
		set DA_START_DATE = `${ADV_TIME_EXE} ${DA_START_DATE} ${FORECAST_INI_FREQ}`
		set DA_END_DATE 	= `${ADV_TIME_EXE} ${DA_END_DATE} ${FORECAST_INI_FREQ}`	
	end
