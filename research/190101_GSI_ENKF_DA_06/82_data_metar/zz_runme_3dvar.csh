#!/bin/csh -x
	rm -rf 3dvar
	mkdir 3dvar

	time csh ./zz_script/runme_darun_3dvar_cycling.csh \
	/uufs/chpc.utah.edu/common/home/u6013926/zpu-group10/installation/11_install 					190101_41 							-98.0 								38.5 \
	2018070100 				2018080100 					2018080300 					/uufs/chpc.utah.edu/common/home/zpu-group10/pu02/data/fnl_0p25_ncar \
	2 		4 			8						4 \
	3 		5				false 				false \
	false				"28*10." 		/uufs/chpc.utah.edu/common/home/zpu-group10/pu02/data/st4 						/uufs/chpc.utah.edu/common/home/zpu-group10/pu02/data/trmm/forWRFDA_v1 \
	9000 						20 					41 								121 \
	151 						1 							1363 							811 \
	3000 						76 			61				150 \
	1 			301							241 							4000	\
	51			24 			apurimacforce-6							WRFDA3.4_4dvar_dm \
	64							32							120						3 \
	TRMM			false				false							1 \
	/uufs/chpc.utah.edu/common/home/u6013926/data2/coding/fortran/2017/170301_smda_v09_data2_module_04					120							150								4 \
	wrfinput_d01			/nv/hp19/llin35/data2/research/2015/151001_SMDA_exp/99_bec_nc/02_BaBEC					BaBEC.nc					smos_obs.nc \
	/uufs/chpc.utah.edu/common/home/u6013926/data2/data/smos/ori_cp34-bec/smos_for_DA_v05_20170517				false					6					01 \
	1						WRF3.9_dm_prog02_20181004				WRFDA3.9_3dvar_dm			WRFDA3.9_4dvar_dm \
	WRFPLUS3.9_dm			zpu-group10/installation/module_11_20170816.txt						0				0 \
	false				4				2				6 \
	/uufs/chpc.utah.edu/common/home/u6013926/data2/coding/fortran/2017/170401_nc_repl_v02_data2_module_04					SBATCH_CHPC						false					false \
	48				2				64				zpu-np \
	zpu-np		64				12			1 \
	12	zpu	ember	12 \
	64								false			false			0 \
	2		2				false			1 \
	false		false			false				true \
	false			false			false				false \
	false		false			false					false \
	false			false			false				false \
	false 			false		false			2

