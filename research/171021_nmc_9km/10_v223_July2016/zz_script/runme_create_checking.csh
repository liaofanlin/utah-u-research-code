#!/bin/csh -x

	set WPS_START_DATE 			= $1
	set WPS_END_DATE   			= $2
	set FORECAST_INI_FREQ		= $3
	set ADV_TIME_EXE 				= $4
	
	set GEN_BE_NL_CV_OPTIONS	= $5
	set GEN_BE_BIN_TYPE			= $6
	
	# -----------------------------------

	# How to perform the basic math
	# 	http://stackoverflow.com/questions/1430395/how-to-perform-a-basic-arithmetics-from-unix-csh-tcsh-shell



cat >! zz_checking.csh << EOF
#!/bin/csh -x

	set WPS_START_DATE 			= $1
	set WPS_END_DATE   			= $2
	set FORECAST_INI_FREQ		= $3
	set ADV_TIME_EXE 				= $4
	
	set GEN_BE_NL_CV_OPTIONS	= $5
	set GEN_BE_BIN_TYPE			= $6

	# gen_be count
	# ------------
		set DA_START_DATE = \${WPS_START_DATE}
		set DA_END_DATE   = \`\${ADV_TIME_EXE} \${DA_START_DATE} 6\`

		set gen_be_count = 0

		while ( \${DA_END_DATE} <= \${WPS_END_DATE} )

			set gen_be_count = \`expr \${gen_be_count} + 1\`

			set DA_START_DATE = \`\${ADV_TIME_EXE} \${DA_START_DATE} 6\`
			set DA_END_DATE 	= \`\${ADV_TIME_EXE} \${DA_END_DATE} 6\`

		end
		
	# opl_count
	# ---------
		set DA_START_DATE = \${WPS_START_DATE}
		set DA_END_DATE   = \`\${ADV_TIME_EXE} \${DA_START_DATE} 6\`

		set opl_count    	= 0
		set opl_count_12h	= 0
		set opl_count_24h	= 0
		
		while ( \${DA_END_DATE} <= \${WPS_END_DATE} )

			set FINAL_TIME = \`\${ADV_TIME_EXE} \${DA_START_DATE} \${FORECAST_INI_FREQ}\`	
			set FINAL_TIME12 	= \`\${ADV_TIME_EXE} \${DA_START_DATE} 12\`	
			set FINAL_TIME24 	= \`\${ADV_TIME_EXE} \${DA_START_DATE} 24\`	
			
			# Process of date
			# ---------------
				set yyyy1 = \`echo \$FINAL_TIME | cut -c1-4\`
				set   mm1 = \`echo \$FINAL_TIME | cut -c5-6\`
				set   dd1 = \`echo \$FINAL_TIME | cut -c7-8\`
				set   hh1 = \`echo \$FINAL_TIME | cut -c9-10\`
				
				set yyyy12 = \`echo \$FINAL_TIME12 | cut -c1-4\`
				set   mm12 = \`echo \$FINAL_TIME12 | cut -c5-6\`
				set   dd12 = \`echo \$FINAL_TIME12 | cut -c7-8\`
				set   hh12 = \`echo \$FINAL_TIME12 | cut -c9-10\`
				
				set yyyy24 = \`echo \$FINAL_TIME24 | cut -c1-4\`
				set   mm24 = \`echo \$FINAL_TIME24 | cut -c5-6\`
				set   dd24 = \`echo \$FINAL_TIME24 | cut -c7-8\`
				set   hh24 = \`echo \$FINAL_TIME24 | cut -c9-10\`
					
			set opl_count_temp 	= \`ls -l openloop/\${DA_START_DATE}/wrfout_d01_\${yyyy1}-\${mm1}-\${dd1}_\${hh1}:00:00 | wc -l\`
			set opl_count 			= \`expr \${opl_count} \+ \${opl_count_temp}\`
			
			set opl_count_temp 	= \`ls -l openloop/\${DA_START_DATE}/wrfout_d01_\${yyyy12}-\${mm12}-\${dd12}_\${hh12}:00:00 | wc -l\`
			set opl_count_12h 	= \`expr \${opl_count_12h} \+ \${opl_count_temp}\`
			
			set opl_count_temp 	= \`ls -l openloop/\${DA_START_DATE}/wrfout_d01_\${yyyy24}-\${mm24}-\${dd24}_\${hh24}:00:00 | wc -l\`
			set opl_count_24h 	= \`expr \${opl_count_24h} \+ \${opl_count_temp}\`

			set DA_START_DATE = \`\${ADV_TIME_EXE} \${DA_START_DATE} 6\`
			set DA_END_DATE 	= \`\${ADV_TIME_EXE} \${DA_END_DATE} 6\`

		end		
		

	# wrfda_count (4dvar)
	# -------------------
		set DA_START_DATE = \${WPS_START_DATE}
		set DA_END_DATE   = \`\${ADV_TIME_EXE} \${DA_START_DATE} 6\`
		
		set wrfda_count  = 0
		
		while ( \${DA_END_DATE} <= \${WPS_END_DATE} )
				
			set wrfda_count_temp = \`ls -l 4dvar/\${DA_START_DATE}/prda/wrfvar_output | wc -l\`
			set wrfda_count = \`expr \${wrfda_count} + \${wrfda_count_temp}\`

			set DA_START_DATE = \`\${ADV_TIME_EXE} \${DA_START_DATE} 6\`
			set DA_END_DATE 	= \`\${ADV_TIME_EXE} \${DA_END_DATE} 6\`

		end				


	# wrfda_count (3dvar)
	# -------------------
		set DA_START_DATE = \${WPS_START_DATE}
		set DA_END_DATE   = \`\${ADV_TIME_EXE} \${DA_START_DATE} 6\`
		
		set wrfda_count_3dvar  = 0
		
		while ( \${DA_END_DATE} <= \${WPS_END_DATE} )
				
			set wrfda_count_3dvar_temp = \`ls -l 3dvar/\${DA_START_DATE}/3dvar/wrfvar_output | wc -l\`
			set wrfda_count_3dvar = \`expr \${wrfda_count_3dvar} + \${wrfda_count_3dvar_temp}\`

			set DA_START_DATE = \`\${ADV_TIME_EXE} \${DA_START_DATE} 6\`
			set DA_END_DATE 	= \`\${ADV_TIME_EXE} \${DA_END_DATE} 6\`

		end	
	
	# wrfout after WRFDA (4dvar)
	# ---------------	---------

		set DA_START_DATE = \${WPS_START_DATE}
		set DA_END_DATE   = \`\${ADV_TIME_EXE} \${DA_START_DATE} 6\`

		set da_wrf_count = 0
		
		while ( \${DA_END_DATE} <= \${WPS_END_DATE} )

			set FINAL_TIME 	= \`\${ADV_TIME_EXE} \${DA_START_DATE} ${FORECAST_INI_FREQ}\`	
			
			# Process of date
			# ---------------
				set yyyy1 = \`echo \$FINAL_TIME | cut -c1-4\`
				set   mm1 = \`echo \$FINAL_TIME | cut -c5-6\`
				set   dd1 = \`echo \$FINAL_TIME | cut -c7-8\`
				set   hh1 = \`echo \$FINAL_TIME | cut -c9-10\`
				
					
			set da_wrf_count_temp = \`ls -l 4dvar/\${DA_START_DATE}/wrf/wrfout_d01_\${yyyy1}-\${mm1}-\${dd1}_\${hh1}:00:00 | wc -l\`
			set da_wrf_count = \`expr \${da_wrf_count} + \${da_wrf_count_temp}\`

			set DA_START_DATE = \`\${ADV_TIME_EXE} \${DA_START_DATE} 6\`
			set DA_END_DATE 	= \`\${ADV_TIME_EXE} \${DA_END_DATE} 6\`

		end

	# wrfout after WRFDA (3dvar)
	# ---------------	---------

		set DA_START_DATE = \${WPS_START_DATE}
		set DA_END_DATE   = \`\${ADV_TIME_EXE} \${DA_START_DATE} 6\`

		set da_wrf_count_3dvar = 0
		
		while ( \${DA_END_DATE} <= \${WPS_END_DATE} )

			set FINAL_TIME = \`\${ADV_TIME_EXE} \${DA_START_DATE} 6\`	
			
			# Process of date
			# ---------------
				set yyyy1 = \`echo \$FINAL_TIME | cut -c1-4\`
				set   mm1 = \`echo \$FINAL_TIME | cut -c5-6\`
				set   dd1 = \`echo \$FINAL_TIME | cut -c7-8\`
				set   hh1 = \`echo \$FINAL_TIME | cut -c9-10\`
					
			set da_wrf_count_3dvar_temp = \`ls -l 3dvar/\${DA_START_DATE}/wrf/wrfout_d01_\${yyyy1}-\${mm1}-\${dd1}_\${hh1}:00:00 | wc -l\`
			set da_wrf_count_3dvar = \`expr \${da_wrf_count_3dvar} + \${da_wrf_count_3dvar_temp}\`

			set DA_START_DATE = \`\${ADV_TIME_EXE} \${DA_START_DATE} 6\`
			set DA_END_DATE 	= \`\${ADV_TIME_EXE} \${DA_END_DATE} 6\`

		end
		
	# matlab_St4_count
	# ---------------	

		set DA_START_DATE = \${WPS_START_DATE}
		set DA_END_DATE   = \`\${ADV_TIME_EXE} \${DA_START_DATE} 6\`

		set matlab_st4_d01_count = 0
		set matlab_st4_d02_count = 0
		set matlab_st4_d03_count = 0
		
		while ( \${DA_END_DATE} <= \${WPS_END_DATE} )

			set FINAL_TIME = \`\${ADV_TIME_EXE} \${DA_START_DATE} ${FORECAST_INI_FREQ}\`	
			
			# Process of date
			# ---------------
				set yyyy1 = \`echo \$FINAL_TIME | cut -c1-4\`
				set   mm1 = \`echo \$FINAL_TIME | cut -c5-6\`
				set   dd1 = \`echo \$FINAL_TIME | cut -c7-8\`
				set   hh1 = \`echo \$FINAL_TIME | cut -c9-10\`
					
			set matlab_st4_d01_count_temp = \`ls -l matlab_post/\${DA_START_DATE}/process/st4/d01/st4-1h_atgr_nc/st4_rain_valid_\${yyyy1}\${mm1}\${dd1}\${hh1}.nc | wc -l\`
			set matlab_st4_d01_count = \`expr \${matlab_st4_d01_count} + \${matlab_st4_d01_count_temp}\`

			set matlab_st4_d02_count_temp = \`ls -l matlab_post/\${DA_START_DATE}/process/st4/d02/st4-1h_atgr_nc/st4_rain_valid_\${yyyy1}\${mm1}\${dd1}\${hh1}.nc | wc -l\`
			set matlab_st4_d02_count = \`expr \${matlab_st4_d02_count} + \${matlab_st4_d02_count_temp}\`
			
			set matlab_st4_d03_count_temp = \`ls -l matlab_post/\${DA_START_DATE}/process/st4/d03/st4-1h_atgr_nc/st4_rain_valid_\${yyyy1}\${mm1}\${dd1}\${hh1}.nc | wc -l\`
			set matlab_st4_d03_count = \`expr \${matlab_st4_d03_count} + \${matlab_st4_d03_count_temp}\`

			set DA_START_DATE = \`\${ADV_TIME_EXE} \${DA_START_DATE} 6\`
			set DA_END_DATE 	= \`\${ADV_TIME_EXE} \${DA_END_DATE} 6\`

		end

		
	# matlab_da_count
	# ---------------	

		set DA_START_DATE = \${WPS_START_DATE}
		set DA_END_DATE   = \`\${ADV_TIME_EXE} \${DA_START_DATE} 6\`

		set matlab_da_count = 0
		
		while ( \${DA_END_DATE} <= \${WPS_END_DATE} )

			set FINAL_TIME = \`\${ADV_TIME_EXE} \${DA_START_DATE} ${FORECAST_INI_FREQ}\`	
			
			# Process of date
			# ---------------
				set yyyy1 = \`echo \$FINAL_TIME | cut -c1-4\`
				set   mm1 = \`echo \$FINAL_TIME | cut -c5-6\`
				set   dd1 = \`echo \$FINAL_TIME | cut -c7-8\`
				set   hh1 = \`echo \$FINAL_TIME | cut -c9-10\`
					
			set matlab_da_count_temp = \`ls -l matlab_post/\${DA_START_DATE}/wrfout-process/atgr-fig_darun/darun_rain_atgr_\${yyyy1}\${mm1}\${dd1}\${hh1}_D01.jpg | wc -l\`
			set matlab_da_count = \`expr \${matlab_da_count} + \${matlab_da_count_temp}\`

			set DA_START_DATE = \`\${ADV_TIME_EXE} \${DA_START_DATE} 6\`
			set DA_END_DATE 	= \`\${ADV_TIME_EXE} \${DA_END_DATE} 6\`

		end
		

	# matlab_opl_count
	# ---------------	

		set DA_START_DATE = \${WPS_START_DATE}
		set DA_END_DATE   = \`\${ADV_TIME_EXE} \${DA_START_DATE} 6\`

		set matlab_opl_count = 0
		
		while ( \${DA_END_DATE} <= \${WPS_END_DATE} )

			set FINAL_TIME = \`\${ADV_TIME_EXE} \${DA_START_DATE} ${FORECAST_INI_FREQ}\`	
			
			# Process of date
			# ---------------
				set yyyy1 = \`echo \$FINAL_TIME | cut -c1-4\`
				set   mm1 = \`echo \$FINAL_TIME | cut -c5-6\`
				set   dd1 = \`echo \$FINAL_TIME | cut -c7-8\`
				set   hh1 = \`echo \$FINAL_TIME | cut -c9-10\`
					
			set matlab_opl_count_temp = \`ls -l matlab_post/\${DA_START_DATE}/wrfout-process/atgr-fig_openwrf/openwrf_rain_atgr_\${yyyy1}\${mm1}\${dd1}\${hh1}_D01.jpg | wc -l\`
			set matlab_opl_count = \`expr \${matlab_opl_count} + \${matlab_opl_count_temp}\`

			set DA_START_DATE = \`\${ADV_TIME_EXE} \${DA_START_DATE} 6\`
			set DA_END_DATE 	= \`\${ADV_TIME_EXE} \${DA_END_DATE} 6\`

		end
		
	# ---------------------------------------------------------------------------------------
		echo "------------"
		echo "---OUTPUT---"
		echo "------------"
		echo "The number of cycles is (the same number of be.dat should be created) =  \${gen_be_count}"

	# How to count file numbers: 
	# 	http://linuxcommando.blogspot.com/2008/07/how-to-count-number-of-files-in.html

		set gen_be_output = \`ls -l gen_be/*/gen_be\${GEN_BE_BIN_TYPE}_cv\${GEN_BE_NL_CV_OPTIONS}/be.dat | wc -l\`
		echo "Current be.dat files number = \${gen_be_output}"	
		
		echo "Current successful OPL cycles = \${opl_count}"
		
		echo "Current successful OPL 12h Forecast = \${opl_count_12h}"

		echo "Current successful OPL 24h Forecast = \${opl_count_24h}"
		
		echo "Current successful WRFDA cycles at 4D-Var PrDA = \${wrfda_count}"
		
		echo "Current successful WRF run after WRF 4D-Var = \${da_wrf_count}"
		
		echo "Current successful WRFDA cycles at 3D-Var = \${wrfda_count_3dvar}"
		
		echo "Current successful WRF run after WRF 3D-Var = \${da_wrf_count_3dvar}"	

		echo "Current successful MATLAB ST4 D01 process = \${matlab_st4_d01_count}"

		echo "Current successful MATLAB ST4 D02 process = \${matlab_st4_d02_count}"
		
		echo "Current successful MATLAB ST4 D03 process = \${matlab_st4_d03_count}"
		
		echo "Current successful MATLAB DA process = \${matlab_da_count}"
		
		echo "Current successful MATLAB OpL process = \${matlab_opl_count}"
		

EOF
