#!/bin/csh
#

set echo
echo "------------------------------------------------------------------------------------------"
echo "--- Beginning of runme_darun_3dvar.csh --> zz_runme_darun_3dvar.csh --> darun_psot.csh ---"
echo "------------------------------------------------------------------------------------------"

set WRFDA_DOMAIN = $1

set NCL_SCRIPT_PATH=/uufs/chpc.utah.edu/common/home/zpu-group10/pu02/coding/ncl/2017/170821_WRFDA_v3.8_tools/my_version

# =================================================================

cd psot_${WRFDA_DOMAIN}

# Link first guess and analysis
	ln -sf ../3dvar_${WRFDA_DOMAIN}/wrfvar_output .
	ln -sf ../3dvar_${WRFDA_DOMAIN}/fg .
	ln -sf ../3dvar_${WRFDA_DOMAIN}/wrfinput_${WRFDA_DOMAIN} .

# Practices suggested from http://www2.mmm.ucar.edu/wrf/users/wrfda/Tutorials/2017_July/class/psot.html
# -------------------------------------
	# Create the increment file
		ncdiff -v U,V,T,QVAPOR,MU,P,PSFC wrfvar_output fg increment.nc

	# Some other plots
	#	- It generates several psotXXX.pdf files
		ln -sf ${NCL_SCRIPT_PATH}/da_plot_psot.ksh .
		ln -sf ${NCL_SCRIPT_PATH}/psot_* .
		ln -sf ${NCL_SCRIPT_PATH}/WRF_contributed.ncl.test .

		./da_plot_psot.ksh


echo "------------------------------------------------------------------------------------------"
echo "--- End of runme_darun_3dvar.csh --> zz_runme_darun_3dvar.csh --> darun_psot.csh ---------"
echo "------------------------------------------------------------------------------------------"

