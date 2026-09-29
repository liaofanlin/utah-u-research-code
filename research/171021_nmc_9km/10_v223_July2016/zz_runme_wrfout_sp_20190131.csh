#!/bin/csh
#

# Example of Usage
# csh zz_runme_wrfout_sp_20190131.csh  

set echo 

set WPS_START_DATE			= 2016070100
set WPS_END_DATE				= 2016072900 
set PROGRAM_DIR				= /uufs/chpc.utah.edu/common/home/u6013926/zpu-group10/installation/12_install
set WRF_3DVAR_EXE_VERSION	= WRFDA3.9.1_3dvar_dm

set ADV_TIME_EXE				= ${PROGRAM_DIR}/wrfda/${WRF_3DVAR_EXE_VERSION}/var/build/da_advance_time.exe

set FORECAST_INI_FREQ		= 12	# Unit in hours
set WORKPATH					= `pwd`
#######################################################################################

	rm -rf matlab_sp_20190131
	mkdir  matlab_sp_20190131

	cd     matlab_sp_20190131
	
   set DA_START_DATE    = ${WPS_START_DATE}
   set DA_END_DATE      = `${ADV_TIME_EXE} ${DA_START_DATE} ${FORECAST_INI_FREQ}`
	
	while ( ${DA_END_DATE} <= ${WPS_END_DATE} )
	
		echo "Processing ",${DA_START_DATE}

		# Process of dates
		# -----------------
			set DA_TIME_00 	= `${ADV_TIME_EXE} ${DA_START_DATE} 0`
			set DA_TIME_01    = `${ADV_TIME_EXE} ${DA_START_DATE} 6`
			set DA_TIME_02    = `${ADV_TIME_EXE} ${DA_START_DATE} 12`			
		
         set yyyy0 = `echo ${DA_TIME_00} | cut -c1-4`
         set   mm0 = `echo ${DA_TIME_00} | cut -c5-6`
         set   dd0 = `echo ${DA_TIME_00} | cut -c7-8`
         set   hh0 = `echo ${DA_TIME_00} | cut -c9-10`

         set yyyy1 = `echo ${DA_TIME_01} | cut -c1-4`
         set   mm1 = `echo ${DA_TIME_01} | cut -c5-6`
         set   dd1 = `echo ${DA_TIME_01} | cut -c7-8`
         set   hh1 = `echo ${DA_TIME_01} | cut -c9-10`

         set yyyy2 = `echo ${DA_TIME_02} | cut -c1-4`
         set   mm2 = `echo ${DA_TIME_02} | cut -c5-6`
         set   dd2 = `echo ${DA_TIME_02} | cut -c7-8`
         set   hh2 = `echo ${DA_TIME_02} | cut -c9-10`

		# Process of Extrating WRF Output
		# - -----------------------------
			mkdir ${DA_START_DATE}
		
			cd ${DA_START_DATE}
		
				ln -sf ${WORKPATH}/openloop/${DA_START_DATE}/wrfout_d01_${yyyy0}-${mm0}-${dd0}_${hh0}:00:00 .
				ln -sf ${WORKPATH}/openloop/${DA_START_DATE}/wrfout_d01_${yyyy1}-${mm1}-${dd1}_${hh1}:00:00 .
				ln -sf ${WORKPATH}/openloop/${DA_START_DATE}/wrfout_d01_${yyyy2}-${mm2}-${dd2}_${hh2}:00:00 .			

				ncks -v SMOIS,XLAT,XLONG \
							wrfout_d01_${yyyy0}-${mm0}-${dd0}_${hh0}:00:00 \
							wrfout_d01_${yyyy0}-${mm0}-${dd0}_${hh0}_sp.nc
				ncks -v SMOIS,XLAT,XLONG \
							wrfout_d01_${yyyy1}-${mm1}-${dd1}_${hh1}:00:00 \
							wrfout_d01_${yyyy1}-${mm1}-${dd1}_${hh1}_sp.nc
				ncks -v SMOIS,XLAT,XLONG \
							wrfout_d01_${yyyy2}-${mm2}-${dd2}_${hh2}:00:00 \
							wrfout_d01_${yyyy2}-${mm2}-${dd2}_${hh2}_sp.nc
				rm *:00:00
	
			cd ..

		# For next step
		# -------------
		set DA_START_DATE = `${ADV_TIME_EXE} ${DA_START_DATE} ${FORECAST_INI_FREQ}`
		set DA_END_DATE   = `${ADV_TIME_EXE} ${DA_END_DATE} ${FORECAST_INI_FREQ}`
   
	end # end of while loop for ( ${DA_END_DATE} <= ${WPS_END_DATE} )

	cd ..


