#!/bin/csh
#

# set echo
echo "-------------------------------------"
echo "--- Beginning of zz_runme_gsi.csh ---"
echo "-------------------------------------"

	set GSI_GSI_EXE			= comGSIv3.6_EnKFv1.2_prog16
	set WORKSPACE 				= `pwd`
	set GSI_ANA_TIME 			= 2016070400
	set WORKSPACE_GSI 		= ${WORKSPACE}/gsi
	set GSI_OBS_ROOT			= ${WORKSPACE_GSI}/arw_${GSI_ANA_TIME}/obs
	set GSI_BK_ROOT			= ${WORKSPACE_GSI}/arw_${GSI_ANA_TIME}/bk
	set GSI_GSI_ROOT			= ~/zpu-group10/installation/11_install/gsi/${GSI_GSI_EXE}
	set GSI_ARW_DATA_PATH	= ~/zpu-group10/research/2018/180801_GSI_ENKF_DA_03/53_computing_ens_mean_for_case52
	set GSI_OBS_DATA_PATH   = ~/zpu-group10/data/ncar_ds337_conventional_dataset/2016/20160704.nr
	
	set DIAG_READ_PROCESS  	= true
		
	
# ===============================================================
# Preparing the observation data and Creating folders
# ----------------------------------------------------
	rm -rf gsi
	mkdir gsi

	mkdir gsi/arw_${GSI_ANA_TIME}
	mkdir gsi/arw_${GSI_ANA_TIME}/bk
	mkdir gsi/arw_${GSI_ANA_TIME}/obs
	
	# Link background and observation files
	cd gsi/arw_${GSI_ANA_TIME}
	
		ln -sf ${GSI_ARW_DATA_PATH}/data_at_ana_time/wrfarw* ./bk/
		ln -sf ${GSI_ARW_DATA_PATH}/computing_ens_mean/wrfarw* ./bk/
		ln -sf ${GSI_OBS_DATA_PATH}/prepbufr.gdas.20160704.t00z.nr ./obs/gdas1.t00z.prepbufr.nr

	cd ../..

	# Create GSI and EnKF Folders
	rm -rf gsi/gsidiag_arw
	mkdir  gsi/gsidiag_arw
	
	rm -rf gsi/enkf_arw
	mkdir  gsi/enkf_arw

# Processes for file convinfo
# ---------------------------
	rm -rf gsi/pre_proc
	mkdir  gsi/pre_proc

	csh ./zz_script/pre_process.csh \
		${GSI_GSI_ROOT}

# Processes for GSI Observer
# --------------------------
	# Generate run_gsi_regional.ksh
	csh zz_script/gsi_create_run_gsi_regional.csh \
	${GSI_GSI_EXE}			${GSI_OBS_ROOT}		${GSI_BK_ROOT} 	${GSI_GSI_ROOT} \
	${GSI_ARW_DATA_PATH}

	mv run_gsi_regional.ksh ./gsi/
	
	# Run run_gsi_regional.ksh
	cd gsi
	ksh run_gsi_regional.ksh
	cd ..

# Processes of diag files
# -----------------------
	rm -rf gsi/diag_post_proc
	mkdir gsi/diag_post_proc
	
	# Copy SM Innovation data
	cp ./sm_innov/* ./gsi/diag_post_proc/
	
	# Run the program
	csh ./zz_script/diag_post_proc.csh \
		${DIAG_READ_PROCESS}

# Processes for EnKF
# -------------------
	# Generate run_enkf_wrf.ksh
	csh zz_script/gsi_create_run_enkf_wrf.csh \
	${WORKSPACE}		${GSI_GSI_ROOT}	${WORKSPACE_GSI}

	mv run_enkf_wrf.ksh ./gsi/
	
	# Run run_enkf_wrf.ksh
	cd gsi
	ksh run_enkf_wrf.ksh
	cd ..
	
# Move Some of my liaofan coding files
# -------------------------------------
mkdir gsi/enkf_arw/zz_coding_output

mv ./gsi/enkf_arw/liaofan_ENKF_taperv_nf2_* \
	./gsi/enkf_arw/zz_coding_output/

# Move anal_chunk files 
# ----------------------
#mkdir gsi/enkf_arw/zz_coding_ENKF_anal_chunk
#
#set VARIABLE_SIZE = 201
#
#set ii = 1
#
#while ($ii <= $VARIABLE_SIZE)
#
#	if ($ii < 10) then
#		set fileNum = 00$ii
#	else if ($ii < 100 ) then
#		set fileNum = 0$ii	
#	else
#		set fileNum = $ii
#	endif
#
#	echo "Moving ENKF anal_chunk files for nn="$fileNum
#
#	mkdir gsi/enkf_arw/zz_coding_ENKF_anal_chunk/nn_$fileNum
#	
#	mv gsi/enkf_arw/*_nn_$fileNum.txt gsi/enkf_arw/zz_coding_ENKF_anal_chunk/nn_$fileNum
#
#	set ii = `expr ${ii} + 1`
#	
#end

	




