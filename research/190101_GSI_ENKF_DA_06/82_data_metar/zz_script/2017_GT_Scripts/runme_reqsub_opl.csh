#!/bin/csh -x
#

# Readme
# ------
	# 1. Example (run it at workspace): $ csh zz_script/runme_reqsub_opl.csh 2013071600 2013072600 6 module_20150205.txt ~/data/apurimac_02 WRFDA3.6.1_4dvar_dm
	
	set WPS_START_DATE      = $1
   set WPS_END_DATE        = $2
   set FORECAST_HOURS      = $3
   set MODULE_FILE			  = $4
   set PROGRAM_DIR			  = $5
   set WRFDA_EXE_VERSION	  = $6
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

         set opl_count_temp = `ll openloop/${DA_START_DATE}/wrfout_d01_${yyyy1}-${mm1}-${dd1}_${hh1}:00:00 | wc -l`

         if ($opl_count_temp == 1) then
            echo "$DA_START_DATE is fine"
         else
            cd openloop/$DA_START_DATE
            qsub zz_runpbs.pbs
            cd ../..
         endif

         set DA_START_DATE = `${ADV_TIME_EXE} ${DA_START_DATE} 6`
         set DA_END_DATE         = `${ADV_TIME_EXE} ${DA_END_DATE} 6`

      end
