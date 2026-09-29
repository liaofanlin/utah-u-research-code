clear all; close all; clc

data_raw = load('porfaot.txt');

% The dimension and lon/lat infomration is at 
%   - https://ldas.gsfc.nasa.gov/gldas/data/0.25deg/oldstandard/porfaot.ctl
data_reshape = reshape(data_raw,[1440 600]);

% Let the negative values (ocean/water) be NaN
ind = find(data_reshape<0);
data_reshape(ind) = NaN;

% Figure
figure('color','w','position',[100 100 1200 500]);

    colormap('jet');
    pcolor(data_reshape'); shading flat;
    caxis([0.35 0.65]);
    set(gca,'Ydir','normal');
    axis equal;
    colorbar;
    title('GLDAS 1/4 degree top 0-2 cm soil porosity');
    set(gca,'fontsize',14);

    fileStr = strcat('gldas_0p25_0_2_cm_porosity.jpg');
    export_fig( sprintf(['./'  fileStr]) ,'-m2');
