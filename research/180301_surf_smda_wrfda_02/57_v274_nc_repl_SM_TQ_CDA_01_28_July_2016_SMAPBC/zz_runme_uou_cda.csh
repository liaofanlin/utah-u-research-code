
	rm -rf uou_cda_cycling
	mkdir  uou_cda_cycling

	csh ./zz_script/runme_uou_cda_cycling.csh \
	2016063018 					2016073100  					48 							/uufs/chpc.utah.edu/common/home/u6013926/zpu-group10/installation/12_install	\
	apurimacforce-6							72					64							32 \
	120						180301_51							12				1 \
	WRF3.9.1_dm					WRFDA3.9.1_3dvar_dm_prog02_gen_be_diags		zpu-group10/installation/module_12_20170818.txt						false \
	/uufs/chpc.utah.edu/common/home/u6013926/data2/coding/fortran/2017/170401_nc_repl_v02_data2_module_04 						SBATCH_CHPC						96				4	\
	96 				zpu-kp			zpu-kp		96	\
	12 			1		12	zpu \
	ember 	12		true			0.04 \
	/uufs/chpc.utah.edu/common/home/u6013926/zpu-group10/coding/matlab/2018/180501_SURF_SMDA_WRFDA_05/180521_Creating_SMAP_E_L2_SM_for_SMDA_QC_BC_2016/output_ncfile 				/uufs/chpc.utah.edu/common/home/u6013926/zpu-group10/coding/matlab/2018/180221_NMC_SMATM_Manuscript_v04/nc_data_3y_avg				672	CDA \
	SM_TQ 			602						392						40 \
	4					/uufs/chpc.utah.edu/common/home/u6013926/zpu-group10/coding/matlab/2018/180221_NMC_SMATM_Manuscript_v04/nc_data_3y_avg_kalman_gain
