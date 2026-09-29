#!/bin/csh
#

set echo
echo "-------------------------------------------------------------------------"
echo "--- Running the runme_matlab.csh --------------------- ------------------"
echo "-------------------------------------------------------------------------"


set WPS_START_DATE			= $1
set WPS_END_DATE 				= $2
set PROGRAM_DIR				= $3
set CASENUM						= $4
set FORECAST_HOURS 			= $5
set FORECAST_INI_FREQ 		= $6
set MAX_DOM 					= $7

set ADV_TIME_EXE 				= ${PROGRAM_DIR}/wrfda/WRFDA3.4_4dvar_dm/var/build/da_advance_time.exe
set WORKPATH               = `pwd`



####################################################################################################

	# Use this command in order to use nco library
	# 	http://nco.sourceforge.net/nco.html#xmp_ncks
	#  use "ncks" to extract soil moisture variable from wrfout files.
		source ~/setup.txt

		mkdir matlab_post/wrfout
		mkdir matlab_post/wrfout_sm

		set DA_START_DATE 		= ${WPS_START_DATE}
		set DA_END_DATE   		= `${ADV_TIME_EXE} ${DA_START_DATE} ${FORECAST_INI_FREQ}`
		set FORECAST_END_TIME 	= `${ADV_TIME_EXE} ${DA_START_DATE} ${FORECAST_HOURS}`

while ( ${FORECAST_END_TIME} <= ${WPS_END_DATE} )

		set yyyy1 = `echo $DA_START_DATE | cut -c1-4`
		set   mm1 = `echo $DA_START_DATE | cut -c5-6`
		set   dd1 = `echo $DA_START_DATE | cut -c7-8`
		set   hh1 = `echo $DA_START_DATE | cut -c9-10`
		
		set SECOND_TIME	= `${ADV_TIME_EXE} ${DA_START_DATE} ${FORECAST_INI_FREQ}`
		
		set yyyy2 = `echo $SECOND_TIME | cut -c1-4`
		set   mm2 = `echo $SECOND_TIME | cut -c5-6`
		set   dd2 = `echo $SECOND_TIME | cut -c7-8`
		set   hh2 = `echo $SECOND_TIME | cut -c9-10`

		set THIRD_TIME	= `${ADV_TIME_EXE} ${DA_START_DATE} ${FORECAST_HOURS}`

		set yyyy3 = `echo $THIRD_TIME | cut -c1-4`
		set   mm3 = `echo $THIRD_TIME | cut -c5-6`
		set   dd3 = `echo $THIRD_TIME | cut -c7-8`
		set   hh3 = `echo $THIRD_TIME | cut -c9-10`

	# Process of directories
	# ----------------------


		mkdir matlab_post/wrfout/${DA_START_DATE}
		mkdir matlab_post/wrfout_sm/${DA_START_DATE}

	# Linking of files
	# ----------------
		ln -sf ${WORKPATH}/openloop/${DA_START_DATE}/wrfout_* matlab_post/wrfout/${DA_START_DATE}/
		
		
		# if statement example
		# 	http://parallel.vub.ac.be/documentation/linux/unixdoc_download/Scripts.html
		if ($DA_START_DATE == $WPS_START_DATE) then
		
			echo $MAX_DOM
			
			if ($MAX_DOM == '3') then
				ncks -v XLONG,XLAT ./matlab_post/wrfout/${DA_START_DATE}/wrfout_d01_${yyyy3}-${mm3}-${dd3}_${hh3}:00:00 \
			   	                ./matlab_post/wrfout_sm/${DA_START_DATE}/wrfout_d01_${yyyy3}-${mm3}-${dd3}_${hh3}_latlon.nc
				ncks -v XLONG,XLAT ./matlab_post/wrfout/${DA_START_DATE}/wrfout_d02_${yyyy3}-${mm3}-${dd3}_${hh3}:00:00 \
										 ./matlab_post/wrfout_sm/${DA_START_DATE}/wrfout_d02_${yyyy3}-${mm3}-${dd3}_${hh3}_latlon.nc
				ncks -v XLONG,XLAT ./matlab_post/wrfout/${DA_START_DATE}/wrfout_d03_${yyyy3}-${mm3}-${dd3}_${hh3}:00:00 \
									    ./matlab_post/wrfout_sm/${DA_START_DATE}/wrfout_d03_${yyyy3}-${mm3}-${dd3}_${hh3}_latlon.nc
		   endif
		   
		   if ($MAX_DOM == 1) then
				ncks -v XLONG,XLAT ./matlab_post/wrfout/${DA_START_DATE}/wrfout_d01_${yyyy3}-${mm3}-${dd3}_${hh3}:00:00 \
			   	                ./matlab_post/wrfout_sm/${DA_START_DATE}/wrfout_d01_${yyyy3}-${mm3}-${dd3}_${hh3}_latlon.nc		   
		   
		   endif
				
								    
		endif
			
		if ($MAX_DOM == 3) then
			ncks -v SMOIS,RAINNC,RAINC ./matlab_post/wrfout/${DA_START_DATE}/wrfout_d01_${yyyy1}-${mm1}-${dd1}_${hh1}:00:00 \
							  					./matlab_post/wrfout_sm/${DA_START_DATE}/wrfout_d01_${yyyy1}-${mm1}-${dd1}_${hh1}_smois.nc
			ncks -v SMOIS,RAINNC,RAINC ./matlab_post/wrfout/${DA_START_DATE}/wrfout_d02_${yyyy1}-${mm1}-${dd1}_${hh1}:00:00 \
							  					./matlab_post/wrfout_sm/${DA_START_DATE}/wrfout_d02_${yyyy1}-${mm1}-${dd1}_${hh1}_smois.nc
			ncks -v SMOIS,RAINNC,RAINC ./matlab_post/wrfout/${DA_START_DATE}/wrfout_d03_${yyyy1}-${mm1}-${dd1}_${hh1}:00:00 \
							  					./matlab_post/wrfout_sm/${DA_START_DATE}/wrfout_d03_${yyyy1}-${mm1}-${dd1}_${hh1}_smois.nc
		
			ncks -v SMOIS,RAINNC,RAINC ./matlab_post/wrfout/${DA_START_DATE}/wrfout_d01_${yyyy2}-${mm2}-${dd2}_${hh2}:00:00 \
							  					./matlab_post/wrfout_sm/${DA_START_DATE}/wrfout_d01_${yyyy2}-${mm2}-${dd2}_${hh2}_smois.nc
			ncks -v SMOIS,RAINNC,RAINC ./matlab_post/wrfout/${DA_START_DATE}/wrfout_d02_${yyyy2}-${mm2}-${dd2}_${hh2}:00:00 \
							  					./matlab_post/wrfout_sm/${DA_START_DATE}/wrfout_d02_${yyyy2}-${mm2}-${dd2}_${hh2}_smois.nc
			ncks -v SMOIS,RAINNC,RAINC ./matlab_post/wrfout/${DA_START_DATE}/wrfout_d03_${yyyy2}-${mm2}-${dd2}_${hh2}:00:00 \
							  					./matlab_post/wrfout_sm/${DA_START_DATE}/wrfout_d03_${yyyy2}-${mm2}-${dd2}_${hh2}_smois.nc

			ncks -v SMOIS,RAINNC,RAINC ./matlab_post/wrfout/${DA_START_DATE}/wrfout_d01_${yyyy3}-${mm3}-${dd3}_${hh3}:00:00 \
							  					./matlab_post/wrfout_sm/${DA_START_DATE}/wrfout_d01_${yyyy3}-${mm3}-${dd3}_${hh3}_smois.nc
			ncks -v SMOIS,RAINNC,RAINC ./matlab_post/wrfout/${DA_START_DATE}/wrfout_d02_${yyyy3}-${mm3}-${dd3}_${hh3}:00:00 \
							  					./matlab_post/wrfout_sm/${DA_START_DATE}/wrfout_d02_${yyyy3}-${mm3}-${dd3}_${hh3}_smois.nc
			ncks -v SMOIS,RAINNC,RAINC ./matlab_post/wrfout/${DA_START_DATE}/wrfout_d03_${yyyy3}-${mm3}-${dd3}_${hh3}:00:00 \
							  					./matlab_post/wrfout_sm/${DA_START_DATE}/wrfout_d03_${yyyy3}-${mm3}-${dd3}_${hh3}_smois.nc
		endif
		
		if ($MAX_DOM == 1) then
			ncks -v SMOIS,RAINNC,RAINC ./matlab_post/wrfout/${DA_START_DATE}/wrfout_d01_${yyyy1}-${mm1}-${dd1}_${hh1}:00:00 \
							  					./matlab_post/wrfout_sm/${DA_START_DATE}/wrfout_d01_${yyyy1}-${mm1}-${dd1}_${hh1}_smois.nc
			ncks -v SMOIS,RAINNC,RAINC ./matlab_post/wrfout/${DA_START_DATE}/wrfout_d01_${yyyy2}-${mm2}-${dd2}_${hh2}:00:00 \
							  					./matlab_post/wrfout_sm/${DA_START_DATE}/wrfout_d01_${yyyy2}-${mm2}-${dd2}_${hh2}_smois.nc		
			ncks -v SMOIS,RAINNC,RAINC ./matlab_post/wrfout/${DA_START_DATE}/wrfout_d01_${yyyy3}-${mm3}-${dd3}_${hh3}:00:00 \
							  					./matlab_post/wrfout_sm/${DA_START_DATE}/wrfout_d01_${yyyy3}-${mm3}-${dd3}_${hh3}_smois.nc
		endif




	# For next step
	# -------------
		set DA_START_DATE 		= `${ADV_TIME_EXE} ${DA_START_DATE} ${FORECAST_INI_FREQ}`
		set DA_END_DATE 			= `${ADV_TIME_EXE} ${DA_END_DATE} ${FORECAST_INI_FREQ}`
		set FORECAST_END_TIME 	= `${ADV_TIME_EXE} ${DA_START_DATE} ${FORECAST_HOURS}`
	
end



echo "-------------------------------------------------------------------------"
echo "--- Finishing the runme_matlab.csh --------------------------------------"
echo "-------------------------------------------------------------------------"


