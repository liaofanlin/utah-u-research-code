#! /bin/ksh
#-----------------------------------------------------------------------
# Script gen_be_wrapper.ksh
#
# Purpose: Calculates background error statistics for WRF-Var.
#
# This code is modified from /nv/hp19/llin35/data/data/wrfda/tutorial_2011/cases/gen_be/gen_be_wrapper.ksh
#-----------------------------------------------------------------------

export E_VERT=$1
export WRAPPER_START_DATE=$2
export WRAPPER_END_DATE=$3
export PROGRAM_DIR=$4
export WRF_3DVAR_EXE_VERSION=$5

#[1] Define job by overriding default environment variables:

cd gen_be

export START_DATE=${WRAPPER_START_DATE}	# the first perturbation valid date
export END_DATE=${WRAPPER_END_DATE}						# the last perturbation valid date
export WRFVAR_DIR=${PROGRAM_DIR}/wrfda/${WRF_3DVAR_EXE_VERSION}
export FC_DIR=`pwd`/fc	# where wrf forecasts are
export BIN_TYPE=5
export RUN_DIR=`pwd`/gen_be${BIN_TYPE}

# seting for gen_be
	export RUN_GEN_BE_STAGE0=true
	export RUN_GEN_BE_STAGE1=true
	export RUN_GEN_BE_STAGE2=true
	export RUN_GEN_BE_STAGE2A=true
	export RUN_GEN_BE_STAGE3=true
	export RUN_GEN_BE_STAGE4=true
	export RUN_GEN_BE_DIAGS=true
	export RUN_GEN_BE_DIAGS_READ=true
	export RUN_GEN_BE_MULTICOV=true
	#export DATA_ON_LEVELS=.true. # "False if fields projected onto modes."
	export BE_METHOD=NMC
	export FCST_RANGE=12
	#Example of changes required for "be_method=ENS":
	#export BE_METHOD=ENS
	#export NE=2 # 30

# setting for wrf
	export NUM_LEVELS=`expr ${E_VERT} - 1`		# = bottom_top = e_vert - 1
	export DOMAIN=01
	export FCST_RANGE1=24
	export FCST_RANGE2=12
	export INTERVAL=12
	export STRIDE=1
	export USE_RFi=true		# use recursive filters?



#[2] Run gen_be:
if ${USE_RFi}; then
   ${WRFVAR_DIR}/var/scripts/gen_be/gen_be.ksh
else                          # loop over wavelet filter lengths:
   export DO_NORMALIZE=.false.	# normalize before wavelet transform?
   NEW_SUF=
   export RUN_DIR=${RUN_DIR}.
   for L in 7;do
      export WAVELET_NBAND=$L
      for N in C;do          # possible WAVELET_NAME values: B C D V
         export WAVELET_NAME=$N
         if [[ $WAVELET_NAME == B ]];then
            export ISTRT=18      
            export IINC=1
            export IFIN=$ISTRT
         elif [[ $WAVELET_NAME == C ]];then
            export ISTRT=30
            export IINC=6
            export IFIN=30
         elif [[ $WAVELET_NAME == D ]];then
            export ISTRT=6
            export IINC=2
            export IFIN=20
         elif [[ $WAVELET_NAME == V ]];then
            export ISTRT=24      
            export IINC=1
            export IFIN=$ISTRT
         fi
         for I in `seq ${ISTRT} ${IINC} ${IFIN}`; do
            export WAVELET_FILT_LEN=$I
            OLD_SUF=${NEW_SUF}
            NEW_SUF=${WAVELET_NBAND}${WAVELET_NAME}${WAVELET_FILT_LEN}n
            export RUN_DIR=${RUN_DIR%${OLD_SUF}}${NEW_SUF}
            ${WRFVAR_DIR}/var/scripts/gen_be/gen_be.ksh
         done
      done
   done
fi

cd ..
