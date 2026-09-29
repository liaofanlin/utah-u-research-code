#!/bin/csh -x
	rm -rf 3dvar
	mkdir 3dvar

	time csh ./zz_script/runme_darun_3dvar.csh \
	/uufs/chpc.utah.edu/common/home/u6013926/zpu-group10/installation/12_install 					171021_10 							-97.0 								38.5 \
	2016070100 				2016072900 					2016073100 					/uufs/chpc.utah.edu/common/home/zpu-group10/pu02/data/fnl_0p25_ncar \
	2 		4 			8						4 \
	5 		5				true 				false \
	true				"28*10." 		/uufs/chpc.utah.edu/common/home/zpu-group10/pu02/data/st4 						/uufs/chpc.utah.edu/common/home/zpu-group10/pu02/data/trmm/forWRFDA_v1 \
	9000 						45 					41 								603 \
	393 						1 							141 							161 \
	9000 						53 			20				150 \
	1 			301							241 							4000	\
	51			24 			apurimacforce-6							WRFDA3.4_4dvar_dm \
	64							32							120						3 \
	TRMM			false				false							1 \
	/uufs/chpc.utah.edu/common/home/u6013926/data2/coding/fortran/2017/170301_smda_v09_data2_module_04					602							392								4 \
	wrfinput_d01			/nv/hp19/llin35/data2/research/2015/151001_SMDA_exp/99_bec_nc/02_BaBEC					BaBEC.nc					smos_obs.nc \
	/uufs/chpc.utah.edu/common/home/u6013926/data2/data/smos/ori_cp34-bec/smos_for_DA_v05_20170517				false					6					01 \
	1						WRF3.9.1_dm				WRFDA3.9.1_3dvar_dm_prog02_gen_be_diags			WRFDA3.9_4dvar_dm \
	WRFPLUS3.9_dm			zpu-group10/installation/module_12_20170818.txt						0				0 \
	false				4				2				6 \
	/uufs/chpc.utah.edu/common/home/u6013926/data2/coding/fortran/2017/170401_nc_repl_v02_data2_module_04					SBATCH_CHPC						false					true \
	48				1				12				zpu \
	ember		12				12			1 \
	12	zpu	ember	12 \
	12								false			false			0 \
	2


