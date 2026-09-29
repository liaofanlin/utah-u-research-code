#!/bin/csh
#

	echo "----------------------------------------------------------------------------------s-"
	echo "--- Beginning of runme_gen_be.csh --> zz_runme_gen_be.csh --> gen_be_anal.csh -----"
	echo "-----------------------------------------------------------------------------------"

set PROGRAM_DIR 				= $1
set WRF_3DVAR_EXE_VERSION	= $2
set GEN_BE_NL_CV_OPTION		= $3
set GEN_BE_BE_BIN_TYPE		= $4


set WRFDA_DIR 					= ${PROGRAM_DIR}/wrfda/${WRF_3DVAR_EXE_VERSION}
set GEN_BE_NUM_WE 			= 24	# Point of interest, must be a point less than E_WE
set GEN_BE_NUM_SN 			= 20	# Point of interest, must be a point less then E_SN
set GEN_BE_NUM_LEVELS 		= 30	# A point less than E_VERT
set GEN_BE_RESOLUTION_KM 	= 36.0


# ========================================
# 2017.08.28: This exercise is suggested by http://www2.mmm.ucar.edu/wrf/users/wrfda/Tutorials/2017_July/class/genbe.html


cd gen_be_anal

./gen_be_plot_wrapper.ksh \
${WRFDA_DIR} 				${GEN_BE_NUM_WE}			${GEN_BE_NUM_SN}			${GEN_BE_NUM_LEVELS} \
${GEN_BE_RESOLUTION_KM}	${GEN_BE_NL_CV_OPTION}	${GEN_BE_BE_BIN_TYPE}

cd ..
