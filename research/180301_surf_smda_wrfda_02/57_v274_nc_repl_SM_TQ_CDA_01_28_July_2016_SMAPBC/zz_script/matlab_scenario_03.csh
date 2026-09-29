#!/bin/csh
#

set echo
echo "-------------------------------------------------------------------------"
echo "--- Beginning of runme_matlab.csh --> matlab_scenario_03.csh ------------"
echo "-------------------------------------------------------------------------"
# Note (2017.09.12) Make the arguments same as runme_matlab.csh

set WPS_START_DATE							= $1
set WPS_END_DATE 								= $2
set PROGRAM_DIR								= $3

set CASENUM										= $4
set FORECAST_HOURS 							= $5
set FORECAST_INI_FREQ						= $6

set MAX_DOM										= $7
set PBS_PPN_MATLAB							= $8
set PBS_MEM_MATLAB							= $9

set PBS_WALLTIME_MATLAB						= $10
set PBS_QUEUE_MATLAB							= $11
set WRFDA_ST4_DIR								= $12

set WRFDA_RAIN_DIR_DA 						= $13
set WRFDA_RAIN_DA_TYPE						= $14
set MATLAB_SCENARIO_01						= $15

set MATLAB_SCENARIO_02						= $16 
set WPS_GEN_END_DATE 						= $17
set MATLAB_SPECIAL_WRFOUT_EXTRACTION	= $18

set SMDA_OBS_FILEPATH						= $19
set WRF_HISTORY_INTERVAL_D01				= $20
set WRF_3DVAR_EXE_VERSION					= $21

set MODULE_FILE								= $22
set MATLAB_SCENARIO_03			 			= $23
set MATLAB_SCENARIO_05						= $24

set MATLAB_SCENARIO_LOC_STR				= $25
set MATLAB_SCENARIO_06						= $26
set HYDRO_AGGFACTRT							= $27

set QUEUE_TYPE									= $28
set SBATCH_CHPC_TIME_SHORT					= $29
set SBATCH_CHPC_NODES_SHORT				= $30

set SBATCH_CHPC_NTASKS_SHORT				= $31
set SBATCH_CHPC_ACCOUNT_SHORT				= $32
set SBATCH_CHPC_PARTITION_SHORT			= $33

set SBATCH_CHPC_NPROC_SHORT				= $34


set ADV_TIME_EXE 								= ${PROGRAM_DIR}/wrfda/${WRF_3DVAR_EXE_VERSION}/var/build/da_advance_time.exe
set WORKPATH               				= `pwd`

####################################################################################################


	mkdir matlab_post/all
	mkdir matlab_post/all/data


	set DA_START_DATE 	= ${WPS_START_DATE}
	set DA_END_DATE   	= `${ADV_TIME_EXE} ${DA_START_DATE} 6`


	while ( ${DA_END_DATE} <= ${WPS_GEN_END_DATE} )
	

		# Process of date
		# ---------------
			set DA_HOUR_01  	= `${ADV_TIME_EXE} ${DA_START_DATE} 1`
			set DA_HOUR_02  	= `${ADV_TIME_EXE} ${DA_START_DATE} 2`
			set DA_HOUR_03  	= `${ADV_TIME_EXE} ${DA_START_DATE} 3`
			set DA_HOUR_04  	= `${ADV_TIME_EXE} ${DA_START_DATE} 4`
			set DA_HOUR_05  	= `${ADV_TIME_EXE} ${DA_START_DATE} 5`
			set DA_HOUR_06  	= `${ADV_TIME_EXE} ${DA_START_DATE} 6`
			
			set yyyy0 = `echo $DA_START_DATE  | cut -c1-4`
			set   mm0 = `echo $DA_START_DATE | cut -c5-6`
			set   dd0 = `echo $DA_START_DATE | cut -c7-8`
			set   hh0 = `echo $DA_START_DATE | cut -c9-10`
		
			set yyyy1 = `echo $DA_HOUR_01 | cut -c1-4`
			set   mm1 = `echo $DA_HOUR_01 | cut -c5-6`
			set   dd1 = `echo $DA_HOUR_01 | cut -c7-8`
			set   hh1 = `echo $DA_HOUR_01 | cut -c9-10`
			
			set yyyy2 = `echo $DA_HOUR_02 | cut -c1-4`
			set   mm2 = `echo $DA_HOUR_02 | cut -c5-6`
			set   dd2 = `echo $DA_HOUR_02 | cut -c7-8`
			set   hh2 = `echo $DA_HOUR_02 | cut -c9-10`
			
			set yyyy3 = `echo $DA_HOUR_03 | cut -c1-4`
			set   mm3 = `echo $DA_HOUR_03 | cut -c5-6`
			set   dd3 = `echo $DA_HOUR_03 | cut -c7-8`
			set   hh3 = `echo $DA_HOUR_03 | cut -c9-10`
			
			set yyyy4 = `echo $DA_HOUR_04 | cut -c1-4`
			set   mm4 = `echo $DA_HOUR_04 | cut -c5-6`
			set   dd4 = `echo $DA_HOUR_04 | cut -c7-8`
			set   hh4 = `echo $DA_HOUR_04 | cut -c9-10`
			
			set yyyy5 = `echo $DA_HOUR_05 | cut -c1-4`
			set   mm5 = `echo $DA_HOUR_05 | cut -c5-6`
			set   dd5 = `echo $DA_HOUR_05 | cut -c7-8`
			set   hh5 = `echo $DA_HOUR_05 | cut -c9-10`
			
			set yyyy6 = `echo $DA_HOUR_06 | cut -c1-4`
			set   mm6 = `echo $DA_HOUR_06 | cut -c5-6`
			set   dd6 = `echo $DA_HOUR_06 | cut -c7-8`
			set   hh6 = `echo $DA_HOUR_06 | cut -c9-10`
	

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

			cp -ir ./zz_script/matlab/* matlab_post/${DA_START_DATE}/

		# Linking of files
		# ----------------
			# For domain 
			ln -sf ${WORKPATH}/openloop/${yyyy0}${mm0}${dd0}${hh0}/wrfout_d01_${yyyy0}-${mm0}-${dd0}_${hh0}:00:00 matlab_post/${DA_START_DATE}/wrfout/domain/d01/wrfout_d01
			ln -sf ${WORKPATH}/openloop/${yyyy0}${mm0}${dd0}${hh0}/wrfout_d02_${yyyy0}-${mm0}-${dd0}_${hh0}:00:00 matlab_post/${DA_START_DATE}/wrfout/domain/d02/wrfout_d02
			ln -sf ${WORKPATH}/openloop/${yyyy0}${mm0}${dd0}${hh0}/wrfout_d03_${yyyy0}-${mm0}-${dd0}_${hh0}:00:00 matlab_post/${DA_START_DATE}/wrfout/domain/d03/wrfout_d03
	
			# For ST4 1h data
		   ln -sf ${WRFDA_ST4_DIR}/${yyyy1}/${mm1}/01h/ob.rain_ana.${yyyy1}${mm1}${dd1}${hh1}.01h		matlab_post/${DA_START_DATE}/data/st4/
		   ln -sf ${WRFDA_ST4_DIR}/${yyyy1}/${mm1}/01h/ob.rain_ana.${yyyy2}${mm2}${dd2}${hh2}.01h		matlab_post/${DA_START_DATE}/data/st4/
		   ln -sf ${WRFDA_ST4_DIR}/${yyyy1}/${mm1}/01h/ob.rain_ana.${yyyy3}${mm3}${dd3}${hh3}.01h		matlab_post/${DA_START_DATE}/data/st4/
		   ln -sf ${WRFDA_ST4_DIR}/${yyyy1}/${mm1}/01h/ob.rain_ana.${yyyy4}${mm4}${dd4}${hh4}.01h		matlab_post/${DA_START_DATE}/data/st4/
		   ln -sf ${WRFDA_ST4_DIR}/${yyyy1}/${mm1}/01h/ob.rain_ana.${yyyy5}${mm5}${dd5}${hh5}.01h		matlab_post/${DA_START_DATE}/data/st4/
		   ln -sf ${WRFDA_ST4_DIR}/${yyyy1}/${mm1}/01h/ob.rain_ana.${yyyy6}${mm6}${dd6}${hh6}.01h		matlab_post/${DA_START_DATE}/data/st4/	   	   		   
	
			# For Assimilated SMOS or SMAP data
			ln -sf ${WORKPATH}/4dvar/${DA_START_DATE}/smda/smos_obs.nc matlab_post/${DA_START_DATE}/data/obs_sm
			ln -sf ${WORKPATH}/4dvar/${DA_START_DATE}/smda/sm_obs.nc matlab_post/${DA_START_DATE}/data/obs_sm
				# ln -sf ${SMDA_OBS_FILEPATH}/ncout_1D_25km_descending/${yyyy1}/${mm1}/smos_descending_from_${yyyy1}${mm1}${dd1}.nc matlab_post/${DA_START_DATE}/data/smos/
				
			# For Assimilated Precipitation data (e.g., TRMM 3B42, NCEP ST4)
			ln -sf ${WORKPATH}/4dvar/${DA_START_DATE}/prda/ob07.rain matlab_post/${DA_START_DATE}/data/obs_pr
	
			# For TRMM obsrevation

			
		# Linking of OpL & DArun files
		# --------------------
			ln -sf ${WORKPATH}/openloop/${DA_START_DATE}/wrfout_* matlab_post/${DA_START_DATE}/wrfout/opl/
			ln -sf ${WORKPATH}/4dvar/${DA_START_DATE}/wrf/wrfout* matlab_post/${DA_START_DATE}/wrfout/4dvar/

		# Special wrf file extraction (OpL & DA RUN)
		# ---------------------------------
			if (${MATLAB_SPECIAL_WRFOUT_EXTRACTION} == 'true') then
				source ~/${MODULE_FILE}
				
				if ($MAX_DOM == 1) then
					set DOMSTR = '01'
				else if ($MAX_DOM == 2) then
					set DOMSTR = '01 02'
				else if ($MAX_DOM == 3) then
					set DOMSTR = '01 02 03'	
				endif
					
				# Output wrfout at 00h
				# ---------------------
					foreach DOM(${DOMSTR})
					
						ncks -v SMOIS,RAINNC,RAINC,XLONG,XLAT,PSFC,TSK,T2,Q2,HFX,LH ./matlab_post/${DA_START_DATE}/wrfout/opl/wrfout_d${DOM}_${yyyy0}-${mm0}-${dd0}_${hh0}:00:00 \
										  							     					  ./matlab_post/${DA_START_DATE}/wrfout/opl_sp/wrfout_d${DOM}_${yyyy0}-${mm0}-${dd0}_${hh0}_sp.nc
						ncks -v SMOIS,RAINNC,RAINC,XLONG,XLAT,PSFC,TSK,T2,Q2,HFX,LH ./matlab_post/${DA_START_DATE}/wrfout/4dvar/wrfout_d${DOM}_${yyyy0}-${mm0}-${dd0}_${hh0}:00:00 \
										  							     					  ./matlab_post/${DA_START_DATE}/wrfout/4dvar_sp/wrfout_d${DOM}_${yyyy0}-${mm0}-${dd0}_${hh0}_sp.nc
										  								  	
					end
				
					
				# Output hourly results
				# ---------------------
					if (${WRF_HISTORY_INTERVAL_D01} 	== 60 ) then

						set MATLAB_START_DATE 		= ${DA_START_DATE}
						set MATLAB_END_DATE   		= `${ADV_TIME_EXE} ${DA_START_DATE} ${FORECAST_HOURS}`
						set MATLAB_ITERATION_DATE 	= `${ADV_TIME_EXE} ${DA_START_DATE} 1`

						while ( ${MATLAB_ITERATION_DATE} <= ${MATLAB_END_DATE} )
							
							set yyyy_iterate = `echo $MATLAB_ITERATION_DATE | cut -c1-4`
							set   mm_iterate = `echo $MATLAB_ITERATION_DATE | cut -c5-6`
							set   dd_iterate = `echo $MATLAB_ITERATION_DATE | cut -c7-8`
							set   hh_iterate = `echo $MATLAB_ITERATION_DATE | cut -c9-10`
							
							foreach DOM(${DOMSTR})
								ncks -v SMOIS,RAINNC,RAINC,XLONG,XLAT,PSFC,TSK,T2,Q2,HFX,LH ./matlab_post/${MATLAB_START_DATE}/wrfout/opl/wrfout_d${DOM}_${yyyy_iterate}-${mm_iterate}-${dd_iterate}_${hh_iterate}:00:00 \
												  							     					  ./matlab_post/${MATLAB_START_DATE}/wrfout/opl_sp/wrfout_d${DOM}_${yyyy_iterate}-${mm_iterate}-${dd_iterate}_${hh_iterate}_sp.nc
												  								  
								ncks -v SMOIS,RAINNC,RAINC,XLONG,XLAT,PSFC,TSK,T2,Q2,HFX,LH ./matlab_post/${MATLAB_START_DATE}/wrfout/4dvar/wrfout_d${DOM}_${yyyy_iterate}-${mm_iterate}-${dd_iterate}_${hh_iterate}:00:00 \
												  							       				  ./matlab_post/${MATLAB_START_DATE}/wrfout/4dvar_sp/wrfout_d${DOM}_${yyyy_iterate}-${mm_iterate}-${dd_iterate}_${hh_iterate}_sp.nc

							end	# END OF FOR LOOP
								
							set MATLAB_ITERATION_DATE = `${ADV_TIME_EXE} ${MATLAB_ITERATION_DATE} 1`								
									
						end	# END OF WHILE LOOP	
							
					else
					
						# output only 06h data
						ncks -v SMOIS,RAINNC,RAINC,XLONG,XLAT,PSFC,TSK,T2,Q2,HFX,LH ./matlab_post/${DA_START_DATE}/wrfout/opl/wrfout_d${DOM}_${yyyy6}-${mm6}-${dd6}_${hh6}:00:00 \
										  								  					  ./matlab_post/${DA_START_DATE}/wrfout/opl_sp/wrfout_d${DOM}_${yyyy6}-${mm6}-${dd6}_${hh6}_sp.nc	
						ncks -v SMOIS,RAINNC,RAINC,XLONG,XLAT,PSFC,TSK,T2,Q2,HFX,LH ./matlab_post/${DA_START_DATE}/wrfout/4dvar/wrfout_d${DOM}_${yyyy6}-${mm6}-${dd6}_${hh6}:00:00 \
										  								  					  ./matlab_post/${DA_START_DATE}/wrfout/4dvar_sp/wrfout_d${DOM}_${yyyy6}-${mm6}-${dd6}_${hh6}_sp.nc	

					endif	# end if loop
				
			endif

		# linking and creating sub_top_parameter.m
		# -----------------------------------------	
			if ( ${hh0} == '00' ) then
				set DAYstring	= "{'00','01','02','03','04','05','06'}"
			else if ( ${hh0} == '06' ) then
				set DAYstring	= "{'06','07','08','09','10','11','12'}"
			else if ( ${hh0} == '12' ) then
				set DAYstring	= "{'12','13','14','15','16','17','18'}"
			else if ( ${hh0} == '18' ) then
				set DAYstring	= "{'18','19','20','21','22','23','00'}"
			endif	
	
		cd matlab_post/${DA_START_DATE}


cat >! sub_top_parameter.m << EOF

    WRFOUT_string = ':00:00';  % at desktop: use 2%3A00%3A00';  at cluster, use ':00:00'

	YEAR	= '${yyyy0}';
	MONTH	= '${mm0}';
	DAY	= '${dd0}';
	HOUR	= '${hh0}';


		if DOMAIN=='01'
			% The following selection is for D01 size 149x79 
			% D01 spatial resolution = 36 km 
			NX = 149; NY = 79;
      	WRF_X1 = 30;   WRF_X2 = 110;
         WRF_Y1 = 20;   WRF_Y2 = 70;
         ratio = 9;
         INDEX = 4;
         special_ratio = 1;
         RESOLUTION = 36;
         WRF_TO_ST4_RATIO = 9;
		end    

    	if DOMAIN=='02'
			% The following selection is for D02 size 210x150
			% D02 spatial resolution = 12 km       
			NX = 140; NY = 160;         
     		WRF_X1 = 11;    WRF_X2 = 130; % after upscaling to 24 km!!
         WRF_Y1 = 11;    WRF_Y2 = 150; % after upscaling to 24 km!!
         ratio = 2;
         INDEX = 0;
         special_ratio = 1;
         RESOLUTION = 9;
         WRF_TO_ST4_RATIO = 9;
      end
      
      if DOMAIN=='03'
			% The following selection is for D03 size 300x240
			% D02 spatial resolution = 4 km            
			NX = 300; NY = 240;    
     		WRF_X1 = 11;    WRF_X2 = 290; % after upscaling to 24 km!!
         WRF_Y1 = 11;    WRF_Y2 = 230; % after upscaling to 24 km!!
         ratio = 1;
         INDEX = 0;
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
	scen03_st4('01'); scen03_st4_plot('01');
	scen03_st4('02'); scen03_st4_plot('02');


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


## 4. Loading module and submitting pbs
## ---------------------------------
	# make the matlab file executed from a linux system as a function in order to pass. (2013.09.11) 
	cd matlab_post/${DA_START_DATE}

	set WORKSPACE		= `pwd`
	set JOBNAME 		= MATLAB	

# 4.1. Create a pbs script
# ----------------------------------------------------------------------------------------
if (${QUEUE_TYPE} == 'PBS') then
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

qsub zz_runpbs.pbs | sed 's/.repace.pace.gatech.edu//g' >& temp.txt	# This is used for GT
endif
## ----------------------------------------------------------------------------------------
## 4.2. Create a sbatch script
if (${QUEUE_TYPE} == 'SBATCH_CHPC') then
cat >! zz_runsbatch.slurm <<EOF
#!/bin/csh
#SBATCH --time=${SBATCH_CHPC_TIME_SHORT}:00:00
#SBATCH --nodes=${SBATCH_CHPC_NODES_SHORT}
#SBATCH --ntasks=${SBATCH_CHPC_NTASKS_SHORT}
#SBATCH --account=${SBATCH_CHPC_ACCOUNT_SHORT}
#SBATCH --partition=${SBATCH_CHPC_PARTITION_SHORT}
#SBATCH -o slurm-%j.out-%N
#SBATCH -J ${JOBNAME}

source ~/${MODULE_FILE}

cd ${WORKSPACE}
matlab -nodisplay -nosplash -r "func_runme, quit"

exit 0
EOF

sbatch zz_runsbatch.slurm | sed 's/Submitted batch job //g' >& temp.txt # This is used for UofU

endif
## ---------------------------------------------------------------------------------------
# To Create a file that informs the job ID --------
set JOB_ID = `cat temp.txt`

cat >! zz_jobID.txt << EOF
${JOBNAME}.o${JOB_ID}
EOF

rm temp.txt
## ------------------------------------------------		
			
	cd ../..	


	# For next step
	# -------------
		set DA_START_DATE = `${ADV_TIME_EXE} ${DA_START_DATE} 6`
		set DA_END_DATE 	= `${ADV_TIME_EXE} ${DA_END_DATE} 6`
	
end # end of while loop for ( ${DA_END_DATE} <= ${WPS_GEN_END_DATE} )

