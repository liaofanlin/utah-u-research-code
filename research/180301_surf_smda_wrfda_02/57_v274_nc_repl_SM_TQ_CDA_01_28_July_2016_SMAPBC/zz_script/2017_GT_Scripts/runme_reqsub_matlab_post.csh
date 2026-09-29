#!/bin/csh -x
#

# Readme
# ------
	# 1. Example (run it at workspace): $ csh zz_script/runme_reqsub_matlab_post.csh 2013070300 2013072600 6 ~/data2/installation/04_install/wrfda/WRFDA3.7.1_4dvar_dm
	
        set WPS_START_DATE      = $1
        set WPS_END_DATE        = $2
        set FORECAST_HOURS      = $3
        set WRFDA_DIR			  = $4
        set ADV_TIME_EXE        = ${WRFDA_DIR}/var/build/da_advance_time.exe


        # matlab_St4_count
        # ---------------

                set DA_START_DATE = ${WPS_START_DATE}
                set DA_END_DATE   = `${ADV_TIME_EXE} ${DA_START_DATE} 6`

                set matlab_st4_d01_count = 0
                set matlab_st4_d02_count = 0
                set matlab_st4_d03_count = 0

                while ( ${DA_END_DATE} <= ${WPS_END_DATE} )

                        set FINAL_TIME = `${ADV_TIME_EXE} ${DA_START_DATE} 6`

                        # Process of date
                        
                        # ---------------
                                set yyyy1 = `echo $FINAL_TIME | cut -c1-4`
                                set   mm1 = `echo $FINAL_TIME | cut -c5-6`
                                set   dd1 = `echo $FINAL_TIME | cut -c7-8`
                                set   hh1 = `echo $FINAL_TIME | cut -c9-10`

                        set matlab_st4_d01_count_temp = `ll matlab_post/${DA_START_DATE}/process/st4/d01/st4-1h_atgr_nc/st4_rain_valid_${yyyy1}${mm1}${dd1}${hh1}.nc | wc -l`

                        if ($matlab_st4_d01_count_temp == 1) then
                                echo "$DA_START_DATE is fine"
                        else
                                cd matlab_post/$DA_START_DATE
                                qsub zz_runpbs.pbs
                                cd ../..
                        endif

                        set DA_START_DATE = `${ADV_TIME_EXE} ${DA_START_DATE} 6`
                        set DA_END_DATE         = `${ADV_TIME_EXE} ${DA_END_DATE} 6`

                end
