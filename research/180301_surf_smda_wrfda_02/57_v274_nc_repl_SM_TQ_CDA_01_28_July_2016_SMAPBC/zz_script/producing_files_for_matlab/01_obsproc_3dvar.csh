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
echo "Linking OBSPROC 3DVAR Data: "

rm -rf matlab_sp/obsproc
mkdir  matlab_sp/obsproc

cd matlab_sp/obsproc

set DA_START_DATE    = ${WPS_START_DATE}
set DA_END_DATE      = `${ADV_TIME_EXE} ${DA_START_DATE} ${FORECAST_INI_FREQ}`

while ( ${DA_END_DATE} <= ${WPS_END_DATE} )

	echo "  - Processing ",${DA_START_DATE}

	# Process of Extrating WRF Output
	# -------------------------------
		mkdir ${DA_START_DATE}

		cd ${DA_START_DATE}

		# Process of date
		# ---------------
			set yyyy1 = `echo $DA_START_DATE | cut -c1-4`
			set   mm1 = `echo $DA_START_DATE | cut -c5-6`
			set   dd1 = `echo $DA_START_DATE | cut -c7-8`
			set   hh1 = `echo $DA_START_DATE | cut -c9-10`

			cp ${WORKPATH}/obsproc/${DA_START_DATE}/obs_gts_${yyyy1}-${mm1}-${dd1}_${hh1}:00:00.3DVAR .

		cd ..

	# For next step
	set DA_START_DATE = `${ADV_TIME_EXE} ${DA_START_DATE} ${FORECAST_INI_FREQ}`
	set DA_END_DATE   = `${ADV_TIME_EXE} ${DA_END_DATE} ${FORECAST_INI_FREQ}`

end # end of while loop for ( ${DA_END_DATE} <= ${WPS_END_DATE} )

cd ../..
