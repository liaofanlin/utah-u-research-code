#!/bin/csh
#

set echo
echo "--------------------------------------------------------------------"
echo "--- Beginning of zz_runme_gsi.csh -> gsi_create_run_enkf_wrf.csh ---"
echo "--------------------------------------------------------------------"

	set WORKSPACE		= $1
	set GSI_GSI_ROOT	= $2
	set WORKSPACE_GSI	= $3
	
# ==============================================
cat >! run_enkf_wrf.ksh << EOF
#!/bin/ksh
#####################################################
# machine set up (users should change this part)
#####################################################
#

# set -x

#
# GSIPROC = processor number used for GSI analysis
#------------------------------------------------
  GSIPROC=12
  ARCH='LINUX'

# Supported configurations:
            # IBM_LSF,
            # LINUX, LINUX_LSF, LINUX_PBS,
            # DARWIN_PGI
#
#####################################################
# case set up (users should change this part)
#####################################################
#
# ANAL_TIME= analysis time  (YYYYMMDDHH)
# WORK_ROOT= working directory, where GSI runs
# PREPBURF = path of PreBUFR conventional obs
# BK_FILE  = path and name of background file
# OBS_ROOT = path of observations files
# FIX_ROOT = path of fix files
# GSI_EXE  = path and name of the gsi executable 

  # Setting for Time
  ANAL_TIME=2016070400
  
  # Setting for Background
  BK_ROOT=${WORKSPACE_GSI}/arw_2016070400/bk
  BK_FILE=\${BK_ROOT}/wrfarw.ensmean
  
  # Setting for EnKF Run  
  WORK_ROOT=./enkf_arw
  diag_ROOT=${WORKSPACE_GSI}/gsidiag_arw
  GSI_ROOT=${GSI_GSI_ROOT}
  FIX_ROOT=\${GSI_ROOT}/fix
  ENKF_EXE=\${GSI_ROOT}/src/enkf/wrf_enkf
  CRTM_ROOT=~/zpu-group10/installation/11_install/gsi/CRTM_2.2.3
  ENKF_NAMELIST=${WORKSPACE}/zz_script/enkf_wrf_namelist.sh

  # Setting for ensemble parameters
  NMEM_ENKF=10
  BK_FILE_mem=\${BK_ROOT}/wrfarw
  NLONS=42
  NLATS=60
  NLEVS=40
  IF_ARW=.true.
  IF_NMM=.false.
  list="conv"
#  list="conv amsua_n15 amsua_n18"
#  list="conv amsua_n18 mhs_n19 hirs4_n19"
#
#####################################################
# Users should NOT change script after this point
#####################################################
#

# =================================================================
# 01. Specifying mpi run commands
# =================================================================

	case \$ARCH in
	   'IBM_LSF')
	      ###### IBM LSF (Load Sharing Facility)
	      RUN_COMMAND="mpirun.lsf " ;;

	   'LINUX')
	      if [ \$GSIPROC = 1 ]; then
	         #### Linux workstation - single processor
	         RUN_COMMAND=""
	      else
	         ###### Linux workstation -  mpi run
	        RUN_COMMAND="mpirun -np \${GSIPROC}  "
	      fi ;;

	   'LINUX_LSF')
	      ###### LINUX LSF (Load Sharing Facility)
	      RUN_COMMAND="mpirun.lsf " ;;

	   'LINUX_PBS')
	      #### Linux cluster PBS (Portable Batch System)
	#      RUN_COMMAND="mpirun -np \${GSIPROC} " ;;
	      RUN_COMMAND="mpiexec_mpt -n \${GSIPROC} " ;;

	   'DARWIN_PGI')
	      ### Mac - mpi run
	      if [ \$GSIPROC = 1 ]; then
	         #### Mac workstation - single processor
	         RUN_COMMAND=""
	      else
	         ###### Mac workstation -  mpi run
	         RUN_COMMAND="mpirun -np \${GSIPROC}  "
	      fi ;;

	   * )
	     print "error: \$ARCH is not a supported platform configuration."
	     exit 1 ;;
	esac

# =================================================================
# 02. Time Processing
# =================================================================
	# Given the analysis date, compute the date from which the
	# first guess comes.  Extract cycle and set prefix and suffix
	# for guess and observation data files
	# gdate=\`\$ndate -06 \$adate\`
	gdate=\$ANAL_TIME
	YYYYMMDD=\`echo \$adate | cut -c1-8\`
	HH=\`echo \$adate | cut -c9-10\`

# =================================================================
# 03. Linking/Copying the Fixed Files and Setting up the Working Directory
# =================================================================
	# Fixed files
	# CONVINFO=\${FIX_ROOT}/global_convinfo.txt
	# SATINFO=\${FIX_ROOT}/global_satinfo.txt
	# SCANINFO=\${FIX_ROOT}/global_scaninfo.txt
	# OZINFO=\${FIX_ROOT}/global_ozinfo.txt
	ANAVINFO=\${diag_ROOT}/anavinfo
	CONVINFO=\${diag_ROOT}/convinfo
	SATINFO=\${diag_ROOT}/satinfo
	SCANINFO=\${diag_ROOT}/scaninfo
	OZINFO=\${diag_ROOT}/ozinfo
	# LOCINFO=\${FIX_ROOT}/global_hybens_locinfo.l64.txt

	# Set up workdir
	# rm -rf \$WORK_ROOT		# removed by liaofan 2018.08.28
	# mkdir -p \$WORK_ROOT	# removed by liaofan 2018.08.28
	cd \$WORK_ROOT

	cp \$ENKF_EXE        ./enkf.x

	cp \$ANAVINFO        ./anavinfo
	# cp \$CONVINFO        ./convinfo	# removed by liaofan 2018.08.28
	cp \$SATINFO         ./satinfo
	cp \$SCANINFO        ./scaninfo
	cp \$OZINFO          ./ozinfo
	# cp \$LOCINFO         ./hybens_locinfo

	cp \$diag_ROOT/satbias_in ./satbias_in
	cp \$diag_ROOT/satbias_pc ./satbias_pc

# =================================================================
# 04. Obtaining Diag Files (Observation Ensemble Prior)
# =================================================================
	# get mean
	ln -s \${BK_FILE_mem}.ensmean ./firstguess.ensmean
	
	# removed by liaofan 2018.09.03
	#for type in \$list; do
	#   ln -s \$diag_ROOT/diag_\${type}_ges.ensmean .
	#done

	# get each member
	imem=1
	while [[ \$imem -le \$NMEM_ENKF ]]; do
	   member="mem"\`printf %03i \$imem\`
	   ln -s \${BK_FILE_mem}.\${member} ./firstguess.\${member}
		
		# removed by liaofan 2018.09.03
	   #for type in \$list; do
	   #   ln -s \$diag_ROOT/diag_\${type}_ges.\${member} .
	   #done
		
	   (( imem = \$imem + 1 ))
	done

# =================================================================
# 05. Generating GSI EnKF Namelist
# =================================================================
	# Build the GSI namelist on-the-fly
	. \$ENKF_NAMELIST

# =================================================================
# 06. Obtaining Background Files
# =================================================================
	# make analysis files
	cp firstguess.ensmean analysis.ensmean
	
	# get each member
	imem=1
	while [[ \$imem -le \$NMEM_ENKF ]]; do
	   member="mem"\`printf %03i \$imem\`
	   cp firstguess.\${member} analysis.\${member}
	   (( imem = \$imem + 1 ))
	done

# =================================================================
# 07. Running EnKF and Checking Run Time Error
# =================================================================
	# Run EnKF
	# -----------
	echo ' Run EnKF'

	\${RUN_COMMAND} ./enkf.x < enkf.nml > stdout 2>&1

	# run time error check
	# --------------------
	error=\$?

	if [ \${error} -ne 0 ]; then
	  echo "ERROR: \${ENKF_EXE} crashed  Exit status=\${error}"
	  exit \${error}
	fi

exit
EOF


