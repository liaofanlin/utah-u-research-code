#!/bin/csh
#

set echo
echo "-------------------------------------------------------------------------"
echo "--- Running the matlab_scenario_03.csh --------------- ------------------"
echo "-------------------------------------------------------------------------"


set WPS_START_DATE							= $1
set WPS_END_DATE 							= $2
set PROGRAM_DIR								= $3

set CASENUM									= $4
set FORECAST_HOURS 							= $5
set FORECAST_INI_FREQ						= $6

set MAX_DOM									= $7
set PBS_PPN_MATLAB							= $8
set PBS_MEM_MATLAB							= $9

set PBS_WALLTIME_MATLAB						= $10
set PBS_QUEUE_MATLAB						= $11
set WRFDA_ST4_DIR							= $12

set WRFDA_RAIN_DIR_DA 						= $13
set WRFDA_RAIN_DA_TYPE						= $14
set MATLAB_SCENARIO_01						= $15

set MATLAB_SCENARIO_02						= $16 
set WPS_GEN_END_DATE 						= $17
set MATLAB_SPECIAL_WRFOUT_EXTRACTION		= $18

set SMDA_OBS_FILEPATH						= $19
set WRF_HISTORY_INTERVAL_D01				= $20
set WRF_3DVAR_EXE_VERSION					= $21

set MODULE_FILE								= $22
set MATLAB_SCENARIO_03			 			= $23
set MATLAB_SCENARIO_05						= $24

set MATLAB_SCENARIO_LOC_STR					= $25

set ADV_TIME_EXE 							= ${PROGRAM_DIR}/wrfda/${WRF_3DVAR_EXE_VERSION}/var/build/da_advance_time.exe
set WORKPATH               					= `pwd`

####################################################################################################


	mkdir matlab_post/all
	mkdir matlab_post/all/data

	set DA_START_DATE 	= ${WPS_START_DATE}
	set DA_END_DATE   	= `${ADV_TIME_EXE} ${DA_START_DATE} 6`

	while ( ${DA_END_DATE} <= ${WPS_END_DATE} )
	
		# Process of directories
		# ----------------------

			mkdir matlab_post/${DA_START_DATE}
	
			mkdir matlab_post/${DA_START_DATE}/data
			mkdir matlab_post/${DA_START_DATE}/data/st4
			mkdir matlab_post/${DA_START_DATE}/data/obs_sm
			mkdir matlab_post/${DA_START_DATE}/data/obs_pr
			
			mkdir matlab_post/${DA_START_DATE}/wrfout
			mkdir matlab_post/${DA_START_DATE}/wrfout/opl
			mkdir matlab_post/${DA_START_DATE}/wrfout/4dvar
			mkdir matlab_post/${DA_START_DATE}/wrfout/opl_sp
			mkdir matlab_post/${DA_START_DATE}/wrfout/4dvar_sp

			
			mkdir matlab_post/${DA_START_DATE}/wrfout/domain
			mkdir matlab_post/${DA_START_DATE}/wrfout/domain/d01
			mkdir matlab_post/${DA_START_DATE}/wrfout/domain/d02
			mkdir matlab_post/${DA_START_DATE}/wrfout/domain/d03
			
			mkdir matlab_post/${DA_START_DATE}/process
			mkdir matlab_post/${DA_START_DATE}/process/st4
			mkdir matlab_post/${DA_START_DATE}/process/st4/d01
			mkdir matlab_post/${DA_START_DATE}/process/st4/d02
			mkdir matlab_post/${DA_START_DATE}/process/st4/d03
			mkdir matlab_post/${DA_START_DATE}/process/wrfout
			mkdir matlab_post/${DA_START_DATE}/process/wrfout/d03

			cp -ir ./zz_script/matlab/scen05_* matlab_post/${DA_START_DATE}/


		# Link files that are not needed in a loop
		# ----------------------------------------
			# Data process
				set yyyy0 = `echo ${DA_START_DATE} | cut -c1-4`
				set   mm0 = `echo ${DA_START_DATE} | cut -c5-6`
				set   dd0 = `echo ${DA_START_DATE} | cut -c7-8`
				set   hh0 = `echo ${DA_START_DATE} | cut -c9-10`
		
		
			# For domain 
			ln -sf ${WORKPATH}/openloop/${yyyy0}${mm0}${dd0}${hh0}/wrfout_d01_${yyyy0}-${mm0}-${dd0}_${hh0}:00:00 matlab_post/${DA_START_DATE}/wrfout/domain/d01/wrfout_d01
			ln -sf ${WORKPATH}/openloop/${yyyy0}${mm0}${dd0}${hh0}/wrfout_d02_${yyyy0}-${mm0}-${dd0}_${hh0}:00:00 matlab_post/${DA_START_DATE}/wrfout/domain/d02/wrfout_d02
			ln -sf ${WORKPATH}/openloop/${yyyy0}${mm0}${dd0}${hh0}/wrfout_d03_${yyyy0}-${mm0}-${dd0}_${hh0}:00:00 matlab_post/${DA_START_DATE}/wrfout/domain/d03/wrfout_d03

			# For Assimilated SMOS data
			ln -sf ${WORKPATH}/4dvar/${DA_START_DATE}/smda/smos_obs.nc matlab_post/${DA_START_DATE}/data/obs_sm
				# ln -sf ${SMDA_OBS_FILEPATH}/ncout_1D_25km_descending/${yyyy1}/${mm1}/smos_descending_from_${yyyy1}${mm1}${dd1}.nc matlab_post/${DA_START_DATE}/data/smos/
				
			# For Assimilated Precipitation data (e.g., TRMM 3B42, NCEP ST4)
			ln -sf ${WORKPATH}/4dvar/${DA_START_DATE}/prda/ob07.rain matlab_post/${DA_START_DATE}/data/obs_pr
	
			# For TRMM obsrevation
						
			# Linking of OpL & DArun files
			ln -sf ${WORKPATH}/openloop/${DA_START_DATE}/wrfout_* matlab_post/${DA_START_DATE}/wrfout/opl/
			ln -sf ${WORKPATH}/4dvar/${DA_START_DATE}/wrf/wrfout* matlab_post/${DA_START_DATE}/wrfout/4dvar/
			
			# Copy files of Openloop wrfout files
			cp -ir ${WORKPATH}/openloop/${DA_START_DATE}/wrfout_d03* matlab_post/${DA_START_DATE}/process/wrfout/d03
			
		# Link files that need to be in a loop
		# -----------------------------------
			set LOOP_TIME = `${ADV_TIME_EXE} ${DA_START_DATE} 1`
			set LOOP_TIME_END = `${ADV_TIME_EXE} ${DA_START_DATE} ${FORECAST_HOURS}`

			while ( ${LOOP_TIME} <= ${LOOP_TIME_END} )
		
				set yyyy_st4 = `echo ${LOOP_TIME} | cut -c1-4`
				set   mm_st4 = `echo ${LOOP_TIME} | cut -c5-6`
				set   dd_st4 = `echo ${LOOP_TIME} | cut -c7-8`
				set   hh_st4 = `echo ${LOOP_TIME} | cut -c9-10`
			
				# link ST4 1h data
				ln -sf ${WRFDA_ST4_DIR}/${yyyy_st4}/${mm_st4}/01h/ob.rain_ana.${yyyy_st4}${mm_st4}${dd_st4}${hh_st4}.01h		matlab_post/${DA_START_DATE}/data/st4/
			
				set LOOP_TIME = `${ADV_TIME_EXE} ${LOOP_TIME} 1`
			
			end # end of "while ( ${LOOP_TIME} <= ${LOOP_TIME_END} )"

		# MATLAB analysis
		# ----------------	
			cd matlab_post/${DA_START_DATE}
		
			# Date process
			# ------------	
				set yyyy1 = `echo ${DA_START_DATE} | cut -c1-4`
				set   mm1 = `echo ${DA_START_DATE} | cut -c5-6`
				set   dd1 = `echo ${DA_START_DATE} | cut -c7-8`
				set   hh1 = `echo ${DA_START_DATE} | cut -c9-10`

		


cat >! sub_top_parameter.m << EOF

% Parameters
% ----------
	WRFOUT_string = ':00:00';  % at desktop: use 2%3A00%3A00';  at cluster, use ':00:00'

	YEAR	= '${yyyy1}';
	MONTH	= '${mm1}';
	DAY	= '${dd1}';
	HOUR	= '${hh1}';
	FORECAST_HOURS = ${FORECAST_HOURS};
	MATLAB_SCENARIO_05_STR = '${MATLAB_SCENARIO_05_STR}';

		if DOMAIN=='01'
			% The following selection is for D01 size 149x79 
			% D01 spatial resolution = 36 km 
			NX = 149; NY = 79;
      	WRF_X1 = 30;   WRF_X2 = 110;
         WRF_Y1 = 20;   WRF_Y2 = 70;
         ratio = 9;
         INDEX = 4;
         special_ratio = 1;
		end    

    	if DOMAIN=='02'
			% The following selection is for D02 size 210x150
			% D02 spatial resolution = 12 km       
			NX = 180; NY = 200;         
     		WRF_X1 = 11;    WRF_X2 = 170; % after upscaling to 24 km!!
         WRF_Y1 = 11;    WRF_Y2 = 190; % after upscaling to 24 km!!
         ratio = 2;
         INDEX = 0;
         special_ratio = 64/81;
      end
      
      if DOMAIN=='03'
			% The following selection is for D03 size 300x240
			% D02 spatial resolution = 4 km            
			NX = 150; NY = 120;    
     		WRF_X1 = 1;    WRF_X2 = 150; % after upscaling to 24 km!!
         WRF_Y1 = 1;    WRF_Y2 = 120; % after upscaling to 24 km!!
         ratio = 1;
         INDEX = 0;
         
         % Region of ST4 for analysis to shorten computation time
         %   Note: 
         %   - This four number requires manual adjustment.  
         %   - Please see the path for more details: E:\liaofan\MATLAB\2015\150921_PrSMDA_Hydro_04\150918_st4_interpolation_apurimac150801_case26
            
         if MATLAB_SCENARIO_LOC_STR == 'IA'
             % for the case of Iowa (IA)
             x_left_ind = 530;
             x_right_ind = 750;
             y_bottom_ind = 430;
             y_top_ind = 610;
                
         elseif MATLAB_SCENARIO_LOC_STR == 'KS'
            
             % For the case of Kansas (KS)
             x_left_ind = 420;
             x_right_ind = 650;
             y_bottom_ind = 310;
             y_top_ind = 490;
         end
      end
      
EOF

cat >! func_runme.m << EOF
	function func_runme
	
	clc; clear all; close all
	
	cd ~
	startup
	cd ${WORKPATH}/matlab_post/${DA_START_DATE}

	tic	
	
	% 1. 1H ST4
	% scen02_st4: only for D01
	% scen03_st4: can be used for all D01, D02, and D03
	disp('- Running runme_st4');
%	scen03_st4('01'); scen03_st4_plot('01');
%	scen04_st4('02'); scen04_st4_plot('02');
	scen05_st4('03'); 
	scen05_st4_plot('03');
	scen05_wrfout_rain_replace('03');

	% 2. wrfout (with func_wrfout_process.m)
	% disp('- Running runme_wrfout');
	% runme_wrfout
	
	% 2-1. TRMM
	% WRFDA_RAIN_DA_TYPE = '${WRFDA_RAIN_DA_TYPE}';
	% if (WRFDA_RAIN_DA_TYPE == 'TRMM')
	% 	runme_trmm
	% end

	% 3. 6H ST4
	% disp('- Running runme_st4_6h');
	% runme_st4_6h
	
	% 4. 6H analysis
	% disp('- Running runme_6h_analysis');
	% runme_6h_analysis

	% the rest files are not used or not important..

	toc

	disp('- Done MATLAB analysis for ${WORKPATH}/matlab_post/${DA_START_DATE}');
	
EOF

	cd ../..


	# execute matlab
	# -------------
		# make the matlab file executed from a linux system as a function in order to pass. (2013.09.11) 
		cd matlab_post/${DA_START_DATE}

	set WORKSPACE		= `pwd`
	set JOBNAME 		= matlab		
		
cat >! zz_runpbs.pbs << EOF
### file:  
#PBS -N ${JOBNAME}_${CASENUM}
#PBS -l nodes=1:ppn=${PBS_PPN_MATLAB}
#PBS -l mem=${PBS_MEM_MATLAB}gb
#PBS -l walltime=${PBS_WALLTIME_MATLAB}:00:00
#PBS -q ${PBS_QUEUE_MATLAB}

source ~/${MODULE_FILE}

cd ${WORKSPACE}
matlab -nodisplay -nosplash -r "func_runme, quit"
EOF
		
	qsub zz_runpbs.pbs | sed 's/.repace.pace.gatech.edu//g' >& temp.txt
	set JOB_ID = `cat temp.txt`


cat >! zz_jobID.txt << EOF
${JOBNAME}.o${JOB_ID}
${JOBNAME}.e${JOB_ID}
EOF

		rm temp.txt

			
		cd ../..	


		# For next step
		# -------------
			set DA_START_DATE = `${ADV_TIME_EXE} ${DA_START_DATE} 6`
			set DA_END_DATE 	= `${ADV_TIME_EXE} ${DA_END_DATE} 6`
	
	end # end of while loop for ( ${DA_END_DATE} <= ${WPS_GEN_END_DATE} )

