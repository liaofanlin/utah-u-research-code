	rm -rf obsproc
	mkdir obsproc

	csh ./zz_script/runme_obsproc.csh \
	-98.0						38.5					2018070100				2018080100 \
	/uufs/chpc.utah.edu/common/home/u6013926/zpu-group10/installation/11_install					1					9000						3000 \
	121						151					1363						811 \
	76		61	45				30 \
	WRFDA3.9_3dvar_dm	1	6			/uufs/chpc.utah.edu/common/home/u6013926/zpu-group10/data/ncar_ds337_conventional_dataset \
	false		false	true		false \
	false		false	false		false \
	false		false		false	false \
	false		false	false		false
