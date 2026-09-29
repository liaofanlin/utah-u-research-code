#!/bin/csh -x
#

# Note (2018.09.28): This has not been updated for a while

set WPS_START_DATE		= $1
set WPS_END_DATE			= $2
set ADV_TIME_EXE			= $3
set WORKPATH				= $4

set FORECAST_INI_FREQ	= $5
set WRF_OUT_TIME_FREQ	= $6
set FORECAST_LEAD_TIME	= $7
#######################################################################################
echo "Processing WRF Out Files in 3DVAR: "

rm -rf matlab_sp/3dvar_wrf
mkdir matlab_sp/3dvar_wrf

cd matlab_sp/3dvar_wrf

set DA_START_DATE    = ${WPS_START_DATE}
set DA_END_DATE      = `${ADV_TIME_EXE} ${DA_START_DATE} ${FORECAST_INI_FREQ}`

while ( ${DA_END_DATE} <= ${WPS_END_DATE} )

	echo "  - Processing ",${DA_START_DATE}

	mkdir ${DA_START_DATE}	
	cd    ${DA_START_DATE}

	set WRF_OUT_TIME 			= ${DA_START_DATE}
	set WRF_OUT_FINAL_TIME 	= `${ADV_TIME_EXE} ${DA_START_DATE} ${FORECAST_LEAD_TIME}`
		
		
	while (${WRF_OUT_TIME} <= ${WRF_OUT_FINAL_TIME})
	
		# Process of date
		# ---------------
			set yyyy1 = `echo $WRF_OUT_TIME | cut -c1-4`
			set   mm1 = `echo $WRF_OUT_TIME | cut -c5-6`
			set   dd1 = `echo $WRF_OUT_TIME | cut -c7-8`
			set   hh1 = `echo $WRF_OUT_TIME | cut -c9-10`			
		
		# Extract wrfout variables	
		ncks -v SMOIS,XLAT,XLONG,T2,Q2,HFX,LH \
			${WORKPATH}/3dvar/${DA_START_DATE}/wrf/wrfout_d01_${yyyy1}-${mm1}-${dd1}_${hh1}:00:00 \
			wrfout_d01_${yyyy1}_${mm1}_${dd1}_${hh1}_sp.nc
		
		# For next step
		set WRF_OUT_TIME = `${ADV_TIME_EXE} ${WRF_OUT_TIME} ${WRF_OUT_TIME_FREQ}`
		

	end
	
	cd ..
	
	# For next step
	set DA_START_DATE = `${ADV_TIME_EXE} ${DA_START_DATE} ${FORECAST_INI_FREQ}`
	set DA_END_DATE   = `${ADV_TIME_EXE} ${DA_END_DATE} ${FORECAST_INI_FREQ}`

end # end of while loop for ( ${DA_END_DATE} <= ${WPS_END_DATE} )

cd ../..
