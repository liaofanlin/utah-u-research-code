#! /bin/ksh
#-----------------------------------------------------------------------
# Script gen_be_wrapper.ksh
#
# Purpose: Calculates background error statistics for WRF-Var.
#-----------------------------------------------------------------------

#[0] Define the input argument

export E_VERT=$1
export WRAPPER_START_DATE=$2
export WRAPPER_END_DATE=$3
export PROGRAM_DIR=$4
export WRF_3DVAR_EXE_VERSION=$5
export GEN_BE_NL_CV_OPTIONS=$6
export GEN_BE_BIN_TYPE=$7
export GEN_BE_WRAPPER_INTERVAL=$8

#[1] Define job by overriding default environment variables:

cd gen_be

export RUN_GEN_BE_STAGE0=true
export RUN_GEN_BE_STAGE1=true
export RUN_GEN_BE_STAGE2=true
export RUN_GEN_BE_STAGE2A=true
export RUN_GEN_BE_STAGE3=true
export RUN_GEN_BE_STAGE4=true
export RUN_GEN_BE_DIAGS=true
export RUN_GEN_BE_DIAGS_READ=true
export RUN_GEN_BE_MULTICOV=true

export WRFVAR_DIR=${PROGRAM_DIR}/wrfda/${WRF_3DVAR_EXE_VERSION}

# Specify control variable options
# NL_CV_OPTIONS = 5: default wind control variables (psi and chi_u)
#                 7: u/v wind control variables
export NL_CV_OPTIONS=${GEN_BE_NL_CV_OPTIONS}       

# How data is binned for calculating statistics
# BIN_TYPE = 5 (default, recommended): Average over all horizontal points;
#                                        i.e. only one bin per vertical level
#            0: No binning
#            1: X-direction mean
#            2: Bin by latitude and height
#            3: Bin by latitude and vertical level
#            4: Fixed number of horizontal bins and by vertical level
#            6: Average over all points (only 1 bin)
export BIN_TYPE=${GEN_BE_BIN_TYPE}           

export START_DATE=${WRAPPER_START_DATE} 	# the first perturbation valid date
export   END_DATE=${WRAPPER_END_DATE} 		# the last perturbation valid date
export NUM_LEVELS=`expr ${E_VERT} - 1`		# = bottom_top = e_vert - 1
#export DATA_ON_LEVELS=.true. # "False if fields projected onto modes."

export BE_METHOD=NMC
#Example of changes required for "be_method=ENS":
#export BE_METHOD=ENS
#export NE=2 # 30

export RUN_DIR=`pwd`/gen_be${BIN_TYPE}_cv${NL_CV_OPTIONS}
export INTERVAL=${GEN_BE_WRAPPER_INTERVAL}	# The interval between your forecast initial times
export FC_DIR=`pwd`/fc       	# where wrf forecasts are
export DOMAIN=01             	# For nested domains, set to the appropriate domain number
export FCST_RANGE1=24        	# Longer forecast time for the NMC method (i.e. for 24-12 NMC, FCST_RANGE1=24, for 36-24 NMC, FCST_RANGE1=36)
export FCST_RANGE2=12        	# Shorter forecast time for the NMC method (i.e. for 24-12 NMC, FCST_RANGE2=12, for 36-24 NMC, FCST_RANGE2=24)
export STRIDE=1            	# STRIDE=1 calculates correlation for every model grid point. STRIDE=2 calculates correlation every 2nd model gridpoint. 3 means every 3rd grid point, etc.
export USE_RFi=true	     		# use recursive filters?

#[2] Run gen_be:
if [[ $NL_CV_OPTIONS = 6 ]]; then
   export RUN_GEN_BE_MULTICOV_CONTRIB=true
   export RUN_GEN_BE_HISTOG=true
fi

if ${USE_RFi}; then
   if [[ $NL_CV_OPTIONS = 6 ]]; then
      ${WRFVAR_DIR}/var/scripts/gen_be/gen_mbe.ksh
   else
      ${WRFVAR_DIR}/var/scripts/gen_be/gen_be.ksh
   fi
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
