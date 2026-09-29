#!/bin/csh -x
#

# ===============================
# Readme
# ===============================
	# 2018.04.05: 
	#	- This script so far can be used for 
	
	# EXPERIMENT		| JOBNAME
	# -----------------------
	# spinup				| SPINUP
	# openloop			| WRF_OPL
	# uou_cda			| UOU_CDA
	# 3dvar				| WRF_3DVAR
	# uou_cda_cycling	| UOU_CC_WRF
	
	
	# 	- Example (run it at workspace):  
	# 		* ONE LINE VERSION: 
	# 		  csh zz_script/runme_reqsub_job.csh 2016050300 2016092700 6 WRFDA3.9.1_3dvar_dm SBATCH_CHPC 12 true spinup account=zpu account=zpu partition=kingspeak partition=ember ntasks=16 ntasks=12 SPINUP
	# 
	# * DECOMPOSED VERSION (cannot be used...):
	#csh zz_script/runme_reqsub_job.csh \
	#	2016070106 								\ WPS_START_DATE
	#	2016070206 								\ WPS_END_DATE 
	#	12 										\ FORECAST_HOURS
	#  WRFDA3.9.1_3dvar_dm 					\ WRFDA_EXE_VERSION
	#	SBATCH_CHPC								\ QUEUE_TYPE
	#	12											\ FORECAST_INI_FREQ
	#	false										\ QUEUE_REPLACEMENT
	# 	openloop									\ EXPERIMENT
	#	account=zpu								\ SBATCH_ACC_ORI
	#	account=zpu								\ SBATCH_ACC_NEW
	#	partition=kingspeak					\ SBATCH_PARTITION_ORI
	# 	partition=ember 						\ SBATCH_PARTITION_NEW
	#	ntasks=16 								\ SBATCH_NTASKS_ORI
	#	ntasks=12								\ SBATCH_NTASKS_NEW
	#	WRF_OPL									\ JOBNAME

# ===============================
# Parameters
# ===============================
	# Parameters: Date and hours 
	set WPS_START_DATE      	= 2016063018
   set WPS_END_DATE        	= 2016070700
   set FORECAST_HOURS      	= 6
	set FORECAST_INI_FREQ		= 6
   
	# Paramenters: Experiment
	set EXPERIMENT					= spinup
	set JOBNAME						= SPINUP
	
	# Sbatch script editing
	set QUEUE_REPLACEMENT		= true
	set SBATCH_ACC_ORI			= account=zpu-np
	set SBATCH_ACC_NEW			= account=zpu
	set SBATCH_PARTITION_ORI	= partition=zpu-np
	set SBATCH_PARTITION_NEW	= partition=ember
	set SBATCH_NTASKS_ORI		= ntasks=32
	set SBATCH_NTASKS_NEW		= ntasks=12
	set SBATCH_NODES_ORI			= nodes=1
	set SBATCH_NODES_NEW			= nodes=1
	set SBATCH_TIME_ORI			= time=12
	set SBATCH_TIME_NEW			= time=12

	# Parameters that do not change much
	set QUEUE_TYPE				 	= SBATCH_CHPC
	set WRFDA_EXE_VERSION	 	= WRFDA3.9.1_3dvar_dm
	set PROGRAM_DIR				= ~/zpu-group10/installation/12_install 

   set ADV_TIME_EXE           = ${PROGRAM_DIR}/wrfda/${WRFDA_EXE_VERSION}/var/build/da_advance_time.exe

#################################################################

	set DA_START_DATE = ${WPS_START_DATE}
   set DA_END_DATE   = `${ADV_TIME_EXE} ${DA_START_DATE} ${FORECAST_INI_FREQ}`

	while ( ${DA_END_DATE} <= ${WPS_END_DATE} )
					
		# --------------------------------------------			
	   # 1. Process of date
      # --------------------------------------------	
		set FINAL_TIME = `${ADV_TIME_EXE} ${DA_START_DATE} ${FORECAST_HOURS}`
		
      set yyyy1 = `echo $FINAL_TIME | cut -c1-4`
      set   mm1 = `echo $FINAL_TIME | cut -c5-6`
      set   dd1 = `echo $FINAL_TIME | cut -c7-8`
      set   hh1 = `echo $FINAL_TIME | cut -c9-10`

		# --------------------------------------------	
		# 2. Check the existence of the last WRF output
		# --------------------------------------------	
		if ((${EXPERIMENT} == 'spinup') | (${EXPERIMENT} == 'openloop')) then
			set exp_count_temp = `ls -l ${EXPERIMENT}/${DA_START_DATE}/wrfout_d01_${yyyy1}-${mm1}-${dd1}_${hh1}:00:00 | wc -l`
		endif
		
		if ((${EXPERIMENT} == 'uou_cda') | (${EXPERIMENT} == '3dvar' )) then
			set exp_count_temp = `ls -l ${EXPERIMENT}/${DA_START_DATE}/wrf/wrfout_d01_${yyyy1}-${mm1}-${dd1}_${hh1}:00:00 | wc -l`
		endif
		
		if ( (${EXPERIMENT} == 'uou_cda_cycling') ) then
			set exp_count_temp = `ls -l ${EXPERIMENT}/${WPS_START_DATE}/${DA_START_DATE}/04_wrf_full/wrfout_d01_${yyyy1}-${mm1}-${dd1}_${hh1}:00:00 | wc -l`
		endif
		
		# --------------------------------------------	
		# 3. Display if the run is finished or not
		# --------------------------------------------			
         if ($exp_count_temp == 1) then
            echo "$DA_START_DATE is fine"
         else

		# --------------------------------------------	
		# 4. Going into the folder
		# --------------------------------------------						
			if ((${EXPERIMENT} == 'spinup') | (${EXPERIMENT} == 'openloop') | (${EXPERIMENT} == '3dvar')) then
				cd ${EXPERIMENT}/$DA_START_DATE
			endif

			if (${EXPERIMENT} == 'uou_cda') then
				cd ${EXPERIMENT}/$DA_START_DATE/wrf
			endif
			
			if (${EXPERIMENT} == 'uou_cda_cycling') then
				cd ${EXPERIMENT}/${WPS_START_DATE}/${DA_START_DATE}/04_wrf_full
			endif

		# --------------------------------------------	
		# 5. Resubmit the pbs or sbatch scripts
		# --------------------------------------------	
			# 5.1. For PBS 
			# -------------------------
      	if (${QUEUE_TYPE} == 'PBS' ) then
				qsub zz_runpbs.pbs
			endif
					
			# 5.2. For SBATCH 
			# -------------------------
			if (${QUEUE_TYPE} == 'SBATCH_CHPC' ) then
			
				if (${QUEUE_REPLACEMENT} == 'true' ) then
					sed -i "s/${SBATCH_ACC_ORI}/${SBATCH_ACC_NEW}/g"     				zz_runsbatch.slurm
					sed -i "s/${SBATCH_PARTITION_ORI}/${SBATCH_PARTITION_NEW}/g" 	zz_runsbatch.slurm
					sed -i "s/${SBATCH_NTASKS_ORI}/${SBATCH_NTASKS_NEW}/g" 			zz_runsbatch.slurm
					sed -i "s/${SBATCH_NODES_ORI}/${SBATCH_NODES_NEW}/g" 				zz_runsbatch.slurm
					sed -i "s/${SBATCH_TIME_ORI}/${SBATCH_TIME_NEW}/g"					zz_runsbatch.slurm
				endif
			
				sbatch zz_runsbatch.slurm | sed 's/Submitted batch job //g' >& temp.txt # This is used for UofU
			endif         

		# --------------------------------------------	
		# 6. To Create a file that inform the job ID 
		# --------------------------------------------		
			# Remove zz_jobID.txt if the file exists
			if (-f zz_jobID.txt) then
				rm zz_jobID.txt
			endif
		
			set JOB_ID = `cat temp.txt`
					
cat >! zz_jobID.txt << EOF
${JOBNAME}.o${JOB_ID}
EOF
			rm temp.txt

		# --------------------------------------------	
		# 7. Leaving into the folder
		# --------------------------------------------						
			if ((${EXPERIMENT} == 'spinup') | (${EXPERIMENT} == 'openloop') | (${EXPERIMENT} == '3dvar')) then
				cd ../..
			endif

			if (${EXPERIMENT} == 'uou_cda') then
				cd ../../..
			endif	
					
			if (${EXPERIMENT} == 'uou_cda_cycling') then
				cd ../../../..
			endif	
				
      endif

		# Time operation for the next iteration
      set DA_START_DATE = `${ADV_TIME_EXE} ${DA_START_DATE} ${FORECAST_INI_FREQ}`
      set DA_END_DATE   = `${ADV_TIME_EXE} ${DA_END_DATE} ${FORECAST_INI_FREQ}`

   end
