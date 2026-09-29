#!/bin/csh
#

set echo
echo "-------------------------------------------------------------------------"
echo "--- Running the matlab_scenario_01.csh ----------------------------------"
echo "-------------------------------------------------------------------------"


set WPS_START_DATE								= $1
set WPS_END_DATE 								= $2
set PROGRAM_DIR									= $3

set CASENUM										= $4
set FORECAST_HOURS 								= $5
set FORECAST_INI_FREQ							= $6

set MAX_DOM										= $7
set PBS_PPN_MATLAB								= $8
set PBS_MEM_MATLAB								= $9

set PBS_WALLTIME_MATLAB							= $10
set PBS_QUEUE_MATLAB							= $11
set WRFDA_ST4_DIR								= $12

set WRFDA_RAIN_DIR_DA 							= $13
set WRFDA_RAIN_DA_TYPE							= $14
set MATLAB_SCENARIO_01							= $15

set MATLAB_SCENARIO_02			 				= $16 
set WPS_GEN_END_DATE 							= $17
set MATLAB_SPECIAL_WRFOUT_EXTRACTION			= $18

set SMDA_OBS_FILEPATH							= $19
set WRF_HISTORY_INTERVAL_D01					= $20
set WRF_3DVAR_EXE_VERSION						= $21

set MODULE_FILE									= $22
set MATLAB_SCENARIO_03			 				= $23

set ADV_TIME_EXE 								= ${PROGRAM_DIR}/wrfda/${WRF_3DVAR_EXE_VERSION}/var/build/da_advance_time.exe
set WORKPATH               						= `pwd`

## ====================================================================================================================

	mkdir matlab_post/all
	mkdir matlab_post/all/data


	set DA_START_DATE = ${WPS_START_DATE}
	set DA_END_DATE   = `${ADV_TIME_EXE} ${DA_START_DATE} 6`


	while ( ${DA_END_DATE} <= ${WPS_END_DATE} )

		# Process of date
		# ---------------
			set yyyy1 = `echo $DA_START_DATE | cut -c1-4`
			set   mm1 = `echo $DA_START_DATE | cut -c5-6`
			set   dd1 = `echo $DA_START_DATE | cut -c7-8`
			set   hh1 = `echo $DA_START_DATE | cut -c9-10`
	
			set HOURONE			= `${ADV_TIME_EXE} ${DA_START_DATE} 1`
			set HOURONE_dd 		= `echo ${HOURONE} | cut -c7-8`
			set HOURONE_hh		= `echo ${HOURONE} | cut -c9-10`

			set HOURTWO			= `${ADV_TIME_EXE} ${DA_START_DATE} 2`
			set HOURTWO_dd 		= `echo ${HOURTWO} | cut -c7-8`
			set HOURTWO_hh		= `echo ${HOURTWO} | cut -c9-10`	
		
			set HOURTHREE		= `${ADV_TIME_EXE} ${DA_START_DATE} 3`
			set HOURTHREE_dd 	= `echo ${HOURTHREE} | cut -c7-8`
			set HOURTHREE_hh	= `echo ${HOURTHREE} | cut -c9-10`	
	
			set HOURFOUR		= `${ADV_TIME_EXE} ${DA_START_DATE} 4`
			set HOURFOUR_dd 	= `echo ${HOURFOUR} | cut -c7-8`
			set HOURFOUR_hh		= `echo ${HOURFOUR} | cut -c9-10`	
	
			set HOURFIVE		= `${ADV_TIME_EXE} ${DA_START_DATE} 5`
			set HOURFIVE_dd 	= `echo ${HOURFIVE} | cut -c7-8`
			set HOURFIVE_hh		= `echo ${HOURFIVE} | cut -c9-10`
	
			set HOURSIX			= `${ADV_TIME_EXE} ${DA_START_DATE} 6`
			set HOURSIX_dd 		= `echo ${HOURSIX} | cut -c7-8`
			set HOURSIX_hh		= `echo ${HOURSIX} | cut -c9-10`


		# Process of directories
		# ----------------------

			mkdir matlab_post/${DA_START_DATE}
	
			mkdir matlab_post/${DA_START_DATE}/st4_data
			mkdir matlab_post/${DA_START_DATE}/wrfdomain
			mkdir matlab_post/${DA_START_DATE}/wrfout
			mkdir matlab_post/${DA_START_DATE}/wrfout-process
	
			mkdir matlab_post/${DA_START_DATE}/st4_data/st4-1h_data
			mkdir matlab_post/${DA_START_DATE}/st4_data/st4-6h_data
			mkdir matlab_post/${DA_START_DATE}/st4_data/rainobs-6h_data
	
			mkdir matlab_post/${DA_START_DATE}/wrfout/4dvar
			mkdir matlab_post/${DA_START_DATE}/wrfout/openwrf
			mkdir matlab_post/${DA_START_DATE}/others

			cp -ir ./zz_script/matlab/* matlab_post/${DA_START_DATE}/

		# Linking of files
		# ----------------
			ln -sf ${WORKPATH}/real/${DA_START_DATE}/wrfinput_d01 matlab_post/${DA_START_DATE}/wrfdomain/
			ln -sf ${WORKPATH}/4dvar/${DA_START_DATE}/wrf/wrfout_d02_${yyyy1}-${mm1}-${dd1}_${hh1}:00:00 matlab_post/${DA_START_DATE}/wrfdomain/wrfdomain.nc
	
			ln -sf ${WRFDA_ST4_DIR}/${yyyy1}/${mm1}/01h/ob.rain_ana.${yyyy1}${mm1}${HOURONE_dd}${HOURONE_hh}.01h 		matlab_post/${DA_START_DATE}/st4_data/st4-1h_data 
			ln -sf ${WRFDA_ST4_DIR}/${yyyy1}/${mm1}/01h/ob.rain_ana.${yyyy1}${mm1}${HOURTWO_dd}${HOURTWO_hh}.01h 		matlab_post/${DA_START_DATE}/st4_data/st4-1h_data 
			ln -sf ${WRFDA_ST4_DIR}/${yyyy1}/${mm1}/01h/ob.rain_ana.${yyyy1}${mm1}${HOURTHREE_dd}${HOURTHREE_hh}.01h matlab_post/${DA_START_DATE}/st4_data/st4-1h_data 
			ln -sf ${WRFDA_ST4_DIR}/${yyyy1}/${mm1}/01h/ob.rain_ana.${yyyy1}${mm1}${HOURFOUR_dd}${HOURFOUR_hh}.01h 	matlab_post/${DA_START_DATE}/st4_data/st4-1h_data 
			ln -sf ${WRFDA_ST4_DIR}/${yyyy1}/${mm1}/01h/ob.rain_ana.${yyyy1}${mm1}${HOURFIVE_dd}${HOURFIVE_hh}.01h 	matlab_post/${DA_START_DATE}/st4_data/st4-1h_data 
			ln -sf ${WRFDA_ST4_DIR}/${yyyy1}/${mm1}/01h/ob.rain_ana.${yyyy1}${mm1}${HOURSIX_dd}${HOURSIX_hh}.01h 		matlab_post/${DA_START_DATE}/st4_data/st4-1h_data 
	
			# For ST4 6h data
		   ln -sf ${WRFDA_ST4_DIR}/${yyyy1}/${mm1}/06h/ob.rain_ana.${yyyy1}${mm1}${HOURSIX_dd}${HOURSIX_hh}.06h		matlab_post/${DA_START_DATE}/st4_data/st4-6h_data
	
			# For TRMM obsrevation
			if (${WRFDA_RAIN_DA_TYPE} == 'TRMM') then
				ln -sf ${WRFDA_RAIN_DIR_DA}/${yyyy1}/${mm1}/ob07_ana_${yyyy1}${mm1}${HOURSIX_dd}-${HOURSIX_hh}.rain 	matlab_post/${DA_START_DATE}/st4_data/rainobs-6h_data 
			endif


		# linking and creating sub_top_parameter.m
		# -----------------------------------------	
			if ( ${hh1} == '00' ) then
				set DAYstring	= "{'00','01','02','03','04','05','06'}"
			else if ( ${hh1} == '06' ) then
				set DAYstring	= "{'06','07','08','09','10','11','12'}"
			else if ( ${hh1} == '12' ) then
				set DAYstring	= "{'12','13','14','15','16','17','18'}"
			else if ( ${hh1} == '18' ) then
				set DAYstring	= "{'18','19','20','21','22','23','00'}"
			endif	
	
		cd matlab_post/${DA_START_DATE}

cat >! sub_top_parameter.m << EOF
%     WRFOUT_string = '%3A00%3A00';  % at desktop: use 2%3A00%3A00';  at cluster, use ':00:00'
    WRFOUT_string = ':00:00';  % at desktop: use 2%3A00%3A00';  at cluster, use ':00:00'

	YEAR	= '${yyyy1}';
	MONTH	= '${mm1}';
	DAY	= '${dd1}';
	HOUR	= ${DAYstring};

	DOMAIN = '01';

        if DOMAIN=='01'
                WRF_X1 = 40;   WRF_X2 = 105;
                WRF_Y1 = 20;   WRF_Y2 = 60;
                ratio = 9;
                INDEX = 4;
        end
        
        % X = 211, Y = 151
        if DOMAIN=='02'
                
                WRF_X1 = 5;    WRF_X2 = 100; % after upscaling to 24 km!!
                WRF_Y1 = 5;    WRF_Y2 = 70; % after upscaling to 24 km!!
                ratio = 6;
                INDEX = 2;
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
	disp('- Running runme_st4');
	runme_st4

	% 2. wrfout (with func_wrfout_process.m)
	disp('- Running runme_wrfout');
	runme_wrfout
	
	% 2-1. TRMM
	WRFDA_RAIN_DA_TYPE = '${WRFDA_RAIN_DA_TYPE}';
	if (WRFDA_RAIN_DA_TYPE == 'TRMM')
		runme_trmm
	end

	% 3. 6H ST4
	disp('- Running runme_st4_6h');
	runme_st4_6h
	
	% 4. 6H analysis
	disp('- Running runme_6h_analysis');
	runme_6h_analysis

	% the rest files are not used or not important..

	toc

	disp('- Done MATLAB analysis for ${WORKPATH}/matlab_post/${DA_START_DATE}');
	
EOF





	cd ../..

	# linking of WRF out files
	# ----------
		cd matlab_post/${DA_START_DATE}/wrfout/4dvar/
		ln -sf ../../../../4dvar/${DA_START_DATE}/wrf/wrfout* .
		cd ../openwrf/
		ln -sf ../../../../openloop/${DA_START_DATE}/wrfout* .
		cd ../../../..	
		mkdir matlab_post/${DA_START_DATE}/psot_data
		cd matlab_post/${DA_START_DATE}/psot_data
		ln -sf ../../../4dvar/${WPS_START_DATE}/increment.nc .
		ln -sf ../../../4dvar/${WPS_START_DATE}/wrfout_inc_07.nc .
		cd ../../..


	# execute matlab
	# -------------
		# make the matlab file executed from a linux system as a function in order to pass. (2013.09.11) 
		cd matlab_post/${DA_START_DATE}

	set WORKSPACE		= `pwd`
	set JOBNAME 		= matlab		
		
## Loading module and submitting pbs
## ---------------------------------

if (${MODULE_FILE} == 'module_default') then

cat >! zz_runpbs.pbs << EOF
### file:  
#PBS -N ${JOBNAME}_${CASENUM}
#PBS -l nodes=1:ppn=${PBS_PPN_MATLAB}
#PBS -l mem=${PBS_MEM_MATLAB}gb
#PBS -l walltime=${PBS_WALLTIME_MATLAB}:00:00
#PBS -q ${PBS_QUEUE_MATLAB}

cd ${WORKSPACE}
matlab -nodisplay -nosplash -r "func_runme, quit"

EOF

else 

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
endif

qsub zz_runpbs.pbs | sed 's/.repace.pace.gatech.edu//g' >& temp.txt
##












set JOB_ID = `cat temp.txt`


cat >! zz_jobID.txt << EOF
${JOBNAME}.o${JOB_ID}
${JOBNAME}.e${JOB_ID}
EOF

	rm temp.txt


			
	#		matlab -nodisplay -nosplash -r "func_runme, quit"
		cd ../..	


	# For next step
	# -------------
		set DA_START_DATE = `${ADV_TIME_EXE} ${DA_START_DATE} 6`
		set DA_END_DATE 	= `${ADV_TIME_EXE} ${DA_END_DATE} 6`
	
end # end of while loop for ( ${DA_END_DATE} <= ${WPS_END_DATE} )

# --------------------------------------------------------------------------------------------------------
# ---- One time thing ------------------------------------------------------------------------------------
# --------------------------------------------------------------------------------------------------------


		cp -ir ./zz_script/matlab_02/* ./matlab_post/all 
	
		cd matlab_post/all
		
cat >! runme_02.m << EOF
	clc; clear all; close all	
	cd ~
	startup
	cd ${WORKPATH}/matlab_post/all

	tic		
	% 1. Analysze the cost and grad function
	% func_runme_fn('${mm1}')

	% 2. Analyze the statistics from all cycles
	func_runme_6h_analysis('${mm1}')

	toc
	close all
	disp('- Done MATLAB analysis for ${WORKPATH}/matlab_post/all');
	
	disp(' ');
	disp('Please find the following files:');
   disp('	- cost and grad function for each cycle:');
	disp(' 		~ (CASE)/matlab_psot/all/cost_grad_fn.jpg');
	disp('		~ (CASE)/matlab_post/all/cost_grad_fn.txt');
	disp('	- Simulation time for each cycle:');
	disp('		~ (CASE)/matlab_post/all/simulation_time.jpg');
	disp('		~ (CASE)/matlab_post/all/simulation_time.txt');
	disp('	- Statistics for each 6-h precipitation:');
	disp('		~ (CASE)/matlab_post/all/6h_analysis_mon${mm1}.jpg');
	disp('	- Each comparison plot of 6-h precipitation and their statistics:');
	disp('		~ (CASE)/matlab_post/(each cycle time)/wrfout-process/6h_total_rain_(DATE)_D02.jpg');
	disp('		~ (CASE)/matlab_post/(each cycle time)/wrfout-process/result_(DATE)_D02.txt');
	disp(' ');
	
EOF
		
		
	
	# matlab -nodisplay -nosplash -r "runme_02, quit"
		cd ../..
