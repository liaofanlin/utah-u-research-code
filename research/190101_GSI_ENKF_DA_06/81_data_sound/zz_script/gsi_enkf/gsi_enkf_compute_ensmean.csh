#!/bin/csh -x
#


set GSI_ENKF_NANALS		= $1

# Copy mem001 file to ensmean file
rm wrfarw.ensmean
cp ../data_at_ana_time/wrfarw.mem001 wrfarw.ensmean


# Create the matlab script
cat >! gsi_enkf_compute_ensmean.m <<EOF
close all; clear all; clc;

GSI_ENKF_NANALS = ${GSI_ENKF_NANALS};

var_str = {'T','U','V','QVAPOR','SMOIS','PH','MU'};

% For 3D variables
% ----------------
for vv = 1:6

	disp(['Processing Variable ' var_str{vv}]);
	
	for ii=1:GSI_ENKF_NANALS
		if ii<10
			ens_str = ['0' num2str(ii)];
		else
			ens_str = num2str(ii);
		end
		
		data(:,:,:,ii) = ncread(['../data_at_ana_time/wrfarw.mem0' ens_str],var_str{vv});
	end

	data_mean = mean(data,4);
	ncwrite('wrfarw.ensmean',var_str{vv},data_mean);
	clear data data_mean;
end

% For 2D variables
% ----------------
for vv = 7:7

	disp(['Processing Variable ' var_str{vv}]);

	for ii=1:GSI_ENKF_NANALS
		if ii<10
			ens_str = ['0' num2str(ii)];
		else
			ens_str = num2str(ii);
		end
		
		data(:,:,ii) = ncread(['../data_at_ana_time/wrfarw.mem0' ens_str],var_str{vv});
	end

	data_mean = mean(data,3);
	ncwrite('wrfarw.ensmean',var_str{vv},data_mean);
	clear data data_mean;
end
EOF

# Run the matlab script
matlab -nodisplay -nosplash -r "gsi_enkf_compute_ensmean, quit"