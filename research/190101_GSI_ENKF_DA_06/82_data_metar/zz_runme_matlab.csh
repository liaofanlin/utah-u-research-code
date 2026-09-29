#!/bin/csh -x

	rm -rf matlab_post
	mkdir matlab_post/
	
	csh zz_script/runme_matlab.csh \
	2018070100 				2018080100						/uufs/chpc.utah.edu/common/home/u6013926/zpu-group10/installation/11_install \
	190101_41 							72						6 \
	1							2 					8 \
	120			apurimacforce-6					/uufs/chpc.utah.edu/common/home/zpu-group10/pu02/data/st4 \
	/uufs/chpc.utah.edu/common/home/zpu-group10/pu02/data/trmm/forWRFDA_v1				TRMM				false \
	false	 		2018080300					true \
	/uufs/chpc.utah.edu/common/home/u6013926/data2/data/smos/ori_cp34-bec/smos_for_DA_v05_20170517				360		WRFDA3.9_3dvar_dm \
	zpu-group10/installation/module_11_20170816.txt						true				false \
	IA		false				40 \
	SBATCH_CHPC						12			1 \
	12	zpu		ember \
	12
