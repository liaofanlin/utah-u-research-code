#!/bin/csh -x
#

# Readme
# ------
	# 1. Example (run it at workspace): $ csh zz_script/runme_reqsub_opl.csh 2016070100 2016072800 6 ~/zpu-group10/installation/12_install WRFDA3.9.1_3dvar_dm SBATCH_CHPC  
	set echo
	
	set WPS_START_DATE      	= $1
   set WPS_END_DATE        	= $2
   set FORECAST_HOURS      	= $3
   set PROGRAM_DIR			 	= $4
   set WRFDA_EXE_VERSION	 	= $5
	set QUEUE_TYPE				 	= $6

   set ADV_TIME_EXE                = ${PROGRAM_DIR}/wrfda/${WRFDA_EXE_VERSION}/var/build/da_advance_time.exe

   # opl_count
   # ---------------

 	  set DA_START_DATE = ${WPS_START_DATE}
     set DA_END_DATE   = `${ADV_TIME_EXE} ${DA_START_DATE} 6`

		while ( ${DA_END_DATE} <= ${WPS_END_DATE} )
					
			set FINAL_TIME = `${ADV_TIME_EXE} ${DA_START_DATE} 6`

	      # Process of date
   	   # ---------------
	         set yyyy1 = `echo $FINAL_TIME | cut -c1-4`
            set   mm1 = `echo $FINAL_TIME | cut -c5-6`
            set   dd1 = `echo $FINAL_TIME | cut -c7-8`
            set   hh1 = `echo $FINAL_TIME | cut -c9-10`

         set opl_count_temp = `ls -l openloop/${DA_START_DATE}/wrfout_d01_${yyyy1}-${mm1}-${dd1}_${hh1}:00:00 | wc -l`

         if ($opl_count_temp == 1) then
            echo "$DA_START_DATE is fine"
         else
            cd openloop/$DA_START_DATE

            	if (${QUEUE_TYPE} == 'PBS' ) then
						qsub zz_runpbs.pbs
					endif
					if (${QUEUE_TYPE} == 'SBATCH_CHPC' ) then
						sbatch zz_runsbatch.slurm
					endif            

				cd ../..
         endif

         set DA_START_DATE = `${ADV_TIME_EXE} ${DA_START_DATE} 6`
         set DA_END_DATE         = `${ADV_TIME_EXE} ${DA_END_DATE} 6`

      end
