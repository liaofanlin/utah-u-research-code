#!/bin/csh
#

echo "------------------------------------------------------------------------------------------"
echo "--- Beginning of runme_darun_3dvar.csh --> zz_runme_darun_3dvar.csh --> darun_ncl_plot.csh ---"
echo "------------------------------------------------------------------------------------------"

set DA_START_DATE	= $1
set WRFDA_DOMAIN	= $2

set NCL_SCRIPT_PATH = ~/zpu-group10/coding/ncl/2017/170821_WRFDA_v3.8_tools/TOOLS/var/graphics/ncl

# =================================================================

cd ncl_plots_${WRFDA_DOMAIN}

# =====================
# WRF-Var_plot.ncl
# =====================
	rm -rf WRF-Var_plot
	mkdir  WRF-Var_plot
	
	cd WRF-Var_plot
	
	# Link files
		ln -sf ../../3dvar_${WRFDA_DOMAIN}/wrfinput_${WRFDA_DOMAIN} .
		ln -sf ../../3dvar_${WRFDA_DOMAIN}/wrfvar_output .
		ln -sf ${NCL_SCRIPT_PATH}/WRF_contributed.ncl.test	
		
	# Copy and process the original ncl file
		cp ${NCL_SCRIPT_PATH}/WRF-Var_plot.ncl .
		
		sed -i -- 's,/karri/users/xinzhang/support/con200/run_cpu1/2007010200/wrfvar/working/,,g' WRF-Var_plot.ncl				# Change the directory of wrfinput & wrfvar_output
		
	# Run the script
	ncl WRF-Var_plot.ncl
		
	cd ..

# =====================
# plot_ob_ascii_loc.ncl	
# =====================
	rm -rf plot_ob_ascii_loc
	mkdir  plot_ob_ascii_loc
	
	cd plot_ob_ascii_loc
	
	# Link files
		ln -sf ../../3dvar_${WRFDA_DOMAIN}/wrfinput_${WRFDA_DOMAIN} .
		ln -sf ../../3dvar_${WRFDA_DOMAIN}/ob.ascii .
		
	# Copy and process the original ncl file
		cp ${NCL_SCRIPT_PATH}/plot_ob_ascii_loc.ncl .
		
		sed -i -- 's,/ptmp/xzhang/RUN_FSO/FengG/ob/2010060100/,,g' plot_ob_ascii_loc.ncl				# Change the directory of ob.ascii
		sed -i -- 's,/ptmp/xzhang/RUN_FSO/FengG/rc/2010060100/,,g' plot_ob_ascii_loc.ncl				# Change the directory of wrfinput_d01
		sed -i -- "s/2010060100/$DA_START_DATE/g" plot_ob_ascii_loc.ncl									# Change the time string
		
	# Run the script
	ncl plot_ob_ascii_loc.ncl
		
	cd ..
		
# ====================
# plot_gts_omb_oma.ncl
# ====================
	rm -rf plot_gts_omb_oma
	mkdir  plot_gts_omb_oma
	
	cd plot_gts_omb_oma
	
	# Link files
		ln -sf ../../3dvar_${WRFDA_DOMAIN}/fg .
		ln -sf ../../3dvar_${WRFDA_DOMAIN}/gts_omb_oma_01 .
	
	# Copy and process the original plot_gts_omb_oma.ncl
		cp ${NCL_SCRIPT_PATH}/plot_gts_omb_oma.ncl .
	
		sed -i -- 's,"/ptmp/xzhang/RUN_FSO/CONUS/ncl_plot/",".",g' plot_gts_omb_oma.ncl			# Change the path for "plotdir"
		sed -i -- 's,datdir1+date+datdir2,datdir1,g' plot_gts_omb_oma.ncl								# Change the variable of "gts_fullname"
		sed -i -- 's,"/ptmp/xzhang/RUN_FSO/CONUS/run/","./",g' plot_gts_omb_oma.ncl				# Change where the gts_obs_oma_01 data is (for datdir1)
		sed -i -- 's,"/ptmp/xzhang/RUN_FSO/CONUS/rc/2010060106/wrfinput_d01","fg",g' plot_gts_omb_oma.ncl	# Change wrfinput file path
		sed -i     "s/2010060118/$DA_START_DATE/g" plot_gts_omb_oma.ncl							# Change Date
		sed -i -- 's,isfilepresent,fileexists,g' plot_gts_omb_oma.ncl									# isfilepresent function is not working for news NCL versions
		sed -i -- 's/proc_surface_types = False/proc_surface_types = True/g' plot_gts_omb_oma.ncl	# Change false-plot for surface data to true-plot
	
	# Run the script
	ncl plot_gts_omb_oma.ncl
	
	cd ..
	
# ======================
# plot_cost_grad_fn.ncl
# ======================
	rm -rf plot_cost_grad_fn
	mkdir  plot_cost_grad_fn
	
	cd plot_cost_grad_fn
	
	# Link files
		ln -sf ../../3dvar_${WRFDA_DOMAIN}/cost_fn .
		ln -sf ../../3dvar_${WRFDA_DOMAIN}/grad_fn .
	
	# Copy and process the original plot_cost_grad_fn
		cp ${NCL_SCRIPT_PATH}/plot_cost_grad_fn.ncl .
		
		sed -i -- 's,"/kumquat/users/${USER}/DA/3dvar/","./",g' plot_cost_grad_fn.ncl			# Change the data path
		sed -i -- 's,"X11","pdf",g' plot_cost_grad_fn.ncl												# Change output from X11 to pdf
		sed -i -- 's,ndata_cost/11,ndata_cost/12,g' plot_cost_grad_fn.ncl							# The divisor is wrong
		sed -i -- 's:read_cost,(/nrow,11/):read_cost,(/nrow,12/):g' plot_cost_grad_fn.ncl	# The size was wrong for cost
		sed -i -- 's:read_grad,(/nrow,10/):read_grad,(/nrow,11/):g' plot_cost_grad_fn.ncl	# The size was wrong for grad
	
	# Run the script
		ncl plot_cost_grad_fn.ncl

	cd ..

# ======================================================================================================

	
cd .. 




echo "------------------------------------------------------------------------------------------"
echo "--- End of runme_darun_3dvar.csh --> zz_runme_darun_3dvar.csh --> darun_ncl_plots.csh ---------"
echo "------------------------------------------------------------------------------------------"

