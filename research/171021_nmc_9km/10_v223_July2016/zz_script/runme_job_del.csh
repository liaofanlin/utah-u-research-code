#!/bin/csh -x
#

# Readme
# ------
	# 1. EXAMPLE (run it at wordspace): $ csh zz_script/runme_job_del.csh 2009061018 2009061518 gen_be gen_be ~/data2/installation/04_install/wrfda/WRFDA3.7.1_4dvar_dm
	# 2. Need to manually specify the text string in the sed function!! 
	# 

set echo

set WPS_START_DATE 	= $1
set WPS_END_DATE		= $2
set JOB_DIR				= $3	# JOB_DIR CAN BE: darun (if non-cycling), openloop (if non-cycling), and matlab_post
set JOB_NAME 			= $4
set WRFDA_DIR			= $5


set ADV_TIME_EXE 		= ${WRFDA_DIR}/var/build/da_advance_time.exe

# ----------------------------------------------------------------------------------------------------------------------

# Job cancellation
# ----------------

	set DA_START_DATE = ${WPS_START_DATE}
	set DA_END_DATE   = `${ADV_TIME_EXE} ${DA_START_DATE} 6`

	while ( ${DA_END_DATE} <= ${WPS_END_DATE} )

		cd ${JOB_DIR}/${DA_START_DATE}	
		set JOBID = `head -n 1 zz_jobID.txt | sed "s/${JOB_NAME}.o//g" | sed 's/.shared-sched.pace.gatech.edu//g'`
			
		canceljob ${JOBID}	
		cd ../..	
		set DA_START_DATE = `${ADV_TIME_EXE} ${DA_START_DATE} 6`
		set DA_END_DATE 	= `${ADV_TIME_EXE} ${DA_END_DATE} 6`	
	end
