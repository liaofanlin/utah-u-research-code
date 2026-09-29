#!/bin/csh
#

set echo
echo "------------------------------------------------------------------------------------------"
echo "--- Beginning of runme_darun_3dvar.csh --> zz_runme_darun_3dvar.csh --> darun_psot.csh ---"
echo "------------------------------------------------------------------------------------------"

set NCL_SCRIPT_PATH=/uufs/chpc.utah.edu/common/home/zpu-group10/pu02/coding/ncl/2017/170821_WRFDA_v3.8_tools/my_version

# =================================================================

cd psot

# Link first guess and analysis
	ln -sf ../3dvar/wrfvar_output .
	ln -sf ../3dvar/fg .
	ln -sf ../3dvar/wrfinput_d01 .

# Practices suggested from http://www2.mmm.ucar.edu/wrf/users/wrfda/Tutorials/2017_July/class/psot.html
# -------------------------------------
	# Create the increment file
		ncdiff -v U,V,T,QVAPOR,MU,P,PSFC wrfvar_output fg increment.nc

	# I Can specify the vertical level inside the script
	#	- It generates WRF-Var_plot_XX_level_XX.pdf
		ln -sf ${NCL_SCRIPT_PATH}/WRF-Var_plot.ncl .
		ncl WRF-Var_plot.ncl

	# Some other plots
	#	- It generates several psotXXX.pdf files
		ln -sf ${NCL_SCRIPT_PATH}/da_plot_psot.ksh .
		ln -sf ${NCL_SCRIPT_PATH}/psot_* .
		ln -sf ${NCL_SCRIPT_PATH}/WRF_contributed.ncl.test .

		./da_plot_psot.ksh





echo "------------------------------------------------------------------------------------------"
echo "--- End of runme_darun_3dvar.csh --> zz_runme_darun_3dvar.csh --> darun_psot.csh ---------"
echo "------------------------------------------------------------------------------------------"

