#!/bin/csh -x
#
# Note (2018.04.04): 
#	- This script prepares files for 03_wrf & 04_wrf_full
#	- This script also run WRF for 03_wrf

set echo
echo "--------------------------------------------------------------------------------------------------------"
echo "--- Beginning of runme_uou_cda_cycling.csh --> zz_runme_uou_cda_cycling.csh --> uou_cda_wrf.csh --------"
echo "--------------------------------------------------------------------------------------------------------"

	set CYCLING_START_TIME		= $1
	set PROGRAM_DIR				= $2
	set WRF_3DVAR_EXE_VERSION	= $3
	set WRF_EXE_VERSION			= $4
	
	set SBATCH_CHPC_TIME			= $5
	set SBATCH_CHPC_NODES		= $6
	set SBATCH_CHPC_NTASKS		= $7
	set SBATCH_CHPC_ACCOUNT		= $8
	
	set SBATCH_CHPC_PARTITION	= $9
	set MODULE_FILE				= $10

	set ADV_TIME_EXE 				= ${PROGRAM_DIR}/wrfda/${WRF_3DVAR_EXE_VERSION}/var/build/da_advance_time.exe
	
################################################

# =============================================
# PREPARING LINKS FOR BOTH 03_WRF & 04_WRF_FULL
# =============================================
foreach CASE(03_wrf 04_wrf_full)

	# 0. Go into the working folder
	# -----------------------------
	cd ${CYCLING_START_TIME}/${CASE}

	# 1. Link files
	# -----------------------------
		# Link Table and Data files
		ln -sf ${PROGRAM_DIR}/wrf/${WRF_EXE_VERSION}/run/*.TBL .
		ln -sf ${PROGRAM_DIR}/wrf/${WRF_EXE_VERSION}/run/RRTMG_SW_DATA .
		ln -sf ${PROGRAM_DIR}/wrf/${WRF_EXE_VERSION}/run/RRTMG_LW_DATA .
		ln -sf ${PROGRAM_DIR}/wrf/${WRF_EXE_VERSION}/run/RRTM_DATA .
		ln -sf ${PROGRAM_DIR}/wrf/${WRF_EXE_VERSION}/run/ETAMPNEW_DATA .
		ln -sf ${PROGRAM_DIR}/wrf/${WRF_EXE_VERSION}/run/CAM_AEROPT_DATA .
		ln -sf ${PROGRAM_DIR}/wrf/${WRF_EXE_VERSION}/run/CAM_ABS_DATA .

		# Link ozone data for RRTMG radiation
		#	- See rn170324
		ln -sf ${PROGRAM_DIR}/wrf/${WRF_EXE_VERSION}/run/ozone* .

		# Link data for the CLM Land surface model
		ln -sf ${PROGRAM_DIR}/wrf/${WRF_EXE_VERSION}/run/CLM_* .	

		# Link .exe
		ln -sf ${PROGRAM_DIR}/wrf/${WRF_EXE_VERSION}/main/wrf.exe .
	
		# Link the wrfbdy
		ln -sf ../../../../real/${CYCLING_START_TIME}/wrfbdy_d01 .

		# Link to wrfinput from CDA analysis
		ln -sf ../02_cda/wrfinput_cda wrfinput_d01
		
		# Link of the name list
		if ( ${CASE} == "03_wrf" ) then
			ln -sf ../../../../real/${CYCLING_START_TIME}/namelist.input_cda_cycling namelist.input
		endif
		if ( ${CASE} == "04_wrf_full" ) then
			ln -sf ../../../../real/${CYCLING_START_TIME}/namelist.input namelist.input
		endif
	
	# 3. Go back the cycling main directory
	# -------------------------------------
	cd ../..
	
end

# =============================================
# Prepare slurm file sof 04_wrf_full (so far, only works for SBATCH_CHPC)
# =============================================
cd ${CYCLING_START_TIME}/04_wrf_full

set JOBNAME 	= UOU_CC_WRF
set WORKSPACE	= `pwd`

cat >! zz_runsbatch.slurm <<EOF
#!/bin/csh
#SBATCH --time=${SBATCH_CHPC_TIME}:00:00
#SBATCH --nodes=${SBATCH_CHPC_NODES}
#SBATCH --ntasks=${SBATCH_CHPC_NTASKS}
#SBATCH --account=${SBATCH_CHPC_ACCOUNT}
#SBATCH --partition=${SBATCH_CHPC_PARTITION}
#SBATCH -o slurm-%j.out-%N
#SBATCH -e slurm-%j.err-%N
#SBATCH -J ${JOBNAME}

source ~/${MODULE_FILE}

cd ${WORKSPACE}
mpirun -np \$SLURM_NTASKS ./wrf.exe

exit 0
EOF

cd ../..

# =============================================
# Run WRF for 03_wrf
# =============================================
	cd ${CYCLING_START_TIME}/03_wrf

	mpirun -np $SLURM_NTASKS ./wrf.exe
	
	cd ../..



echo "--------------------------------------------------------------------------------------------------------"
echo "--- End of runme_uou_cda_cycling.csh --> zz_runme_uou_cda_cycling.csh --> uou_cda_wrf.csh --------------"
echo "--------------------------------------------------------------------------------------------------------"












