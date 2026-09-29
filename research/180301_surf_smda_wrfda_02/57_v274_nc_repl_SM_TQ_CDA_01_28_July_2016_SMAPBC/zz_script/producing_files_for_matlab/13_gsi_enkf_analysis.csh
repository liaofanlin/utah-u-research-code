#!/bin/csh -x
#

# Note (2018.09.28): This has not been updated for a while
set echo

set WPS_START_DATE		= $1
set WPS_END_DATE			= $2
set ADV_TIME_EXE			= $3
set WORKPATH				= $4

set FORECAST_INI_FREQ	= $5
set WRF_OUT_TIME_FREQ	= $6
set FORECAST_LEAD_TIME	= $7
set ENS_MEMBER_NUM		= $8
#######################################################################################

echo "Linking OBSPROC GSI-EnKF Analysis Data:"

rm -rf matlab_sp/gsi_enkf_analysis
mkdir  matlab_sp/gsi_enkf_analysis

cd 	 matlab_sp/gsi_enkf_analysis

set DA_START_DATE    = ${WPS_START_DATE}
set DA_END_DATE      = `${ADV_TIME_EXE} ${DA_START_DATE} ${FORECAST_INI_FREQ}`

while ( ${DA_END_DATE} <= ${WPS_END_DATE} )

	echo "  - Processing ",${DA_START_DATE}

	# Process of Extrating WRF Output
	# -------------------------------
		mkdir ${DA_START_DATE}

		cd ${DA_START_DATE}

		pwd
		
		# Process of date
		# ---------------
			set yyyy1 = `echo $DA_START_DATE | cut -c1-4`
			set   mm1 = `echo $DA_START_DATE | cut -c5-6`
			set   dd1 = `echo $DA_START_DATE | cut -c7-8`
			set   hh1 = `echo $DA_START_DATE | cut -c9-10`

			# Obtain the number of ensemble member
			set COUNT = 1
			
			while ( ${COUNT} <= ${ENS_MEMBER_NUM} )
			
				# Set up member string (only for member size <100)
				if (${COUNT}<10) then
					set mem_str = "mem00"${COUNT}
				else
					set mem_str = "mem0"${COUNT}
				endif
						
				# Extract wrfout variables	
				ncks -v XLAT,XLONG,XLAT_U,XLONG_U,XLAT_V,XLONG_V,SMOIS,T,U,V,QVAPOR,P,PB,MU \
					${WORKPATH}/gsi_enkf/${DA_START_DATE}/06_enkf/analysis.${mem_str} \
					wrf_analysis_${yyyy1}_${mm1}_${dd1}_${hh1}_${mem_str}.nc

				# Count 
				set COUNT = `expr ${COUNT} + 1`

			end
		cd ..

	# For next step
	set DA_START_DATE = `${ADV_TIME_EXE} ${DA_START_DATE} ${FORECAST_INI_FREQ}`
	set DA_END_DATE   = `${ADV_TIME_EXE} ${DA_END_DATE} ${FORECAST_INI_FREQ}`

end # end of while loop for ( ${DA_END_DATE} <= ${WPS_END_DATE} )

cd ../..

