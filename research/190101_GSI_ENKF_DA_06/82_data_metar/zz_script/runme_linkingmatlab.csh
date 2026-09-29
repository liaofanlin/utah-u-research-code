#~/bin/csh -x
#
# Example: csh zz_script/runme_linkingmatlab.csh ~/data/apurimac 2013070200 2013072700

	set PROGRAM_DIR				= $1
	set WPS_START_DATE			= $2
	set WPS_END_DATE			= $3
	set WRF_3DVAR_EXE_VERSION	= $4

	set ADV_TIME_EXE        	= ${PROGRAM_DIR}/wrfda/${WRF_3DVAR_EXE_VERSION}/var/build/da_advance_time.exe
	
	
# ------------------------------------------------------------------------------------------
	
	rm -rf matlab_linking
	mkdir matlab_linking
	
	cd matlab_linking	

	set DA_START_DATE = ${WPS_START_DATE}
	set DA_END_DATE   = `${ADV_TIME_EXE} ${DA_START_DATE} 6`

	while ( ${DA_END_DATE} <= ${WPS_END_DATE} )
	
		mkdir ${DA_START_DATE}
		cd ${DA_START_DATE}
		
		echo "Linking for ${DA_START_DATE}"
		
      # Process of date
      # ---------------
      	set yyyy1 = `echo $DA_START_DATE | cut -c1-4`
      	set   mm1 = `echo $DA_START_DATE | cut -c5-6`
         set   dd1 = `echo $DA_START_DATE | cut -c7-8`
         set   hh1 = `echo $DA_START_DATE | cut -c9-10`

			mkdir opl
			mkdir 4dvar
			mkdir st4
			mkdir smobs
			
			cd opl
				ln -sf ../../../matlab_post/${DA_START_DATE}/wrfout/opl_sp/wrfout*.nc .
			cd ..
			
			cd 4dvar
				ln -sf ../../../matlab_post/${DA_START_DATE}/wrfout/4dvar_sp/wrfout*.nc .
			cd ..
			
			cd st4
				mkdir d01 d02 d03
				cd d01
					ln -sf ../../../../matlab_post/${DA_START_DATE}/process/st4/d01/st4-1h_atgr_nc/st4_rain_valid* .
				cd ../d02
					ln -sf ../../../../matlab_post/${DA_START_DATE}/process/st4/d02/st4-1h_atgr_nc/st4_rain_valid* .
				cd ../d03
					ln -sf ../../../../matlab_post/${DA_START_DATE}/process/st4/d03/st4-1h_atgr_nc/st4_rain_valid* .
			cd ../.. # back to DA_START_DATE
			
			cd smobs
				ln -sf ../../../matlab_post/${DA_START_DATE}/data/obs_sm/*nc .
			cd ..
			
		cd .. # leave DA_START_DATE
		
      set DA_START_DATE = `${ADV_TIME_EXE} ${DA_START_DATE} 6`
      set DA_END_DATE   = `${ADV_TIME_EXE} ${DA_END_DATE} 6`							
	end # end of while loop
	
	cd .. # back to workspace
		
		
