clear all; close all; clc

data_raw = load('tex_statsfao.txt');

% The dimension and lon/lat infomration is at 
%   -https://ldas.gsfc.nasa.gov/gldas/data/0.25deg/tex_statsfao_mod44w_025.ctl
data_reshape = reshape(data_raw,[1440 600]);

% Let the negative values (ocean/water) be NaN
ind = find(data_reshape<0);
data_reshape(ind) = NaN;

% Figure
figure('color','w','position',[100 100 1200 500]);
    contourcmap('jet',[0.5:1:16.5]);
    colormap('jet');
    pcolor(data_reshape'); shading flat;
    caxis([0.5 16.5]);
    set(gca,'Ydir','normal');
    axis equal;
    colorbar;
    title('GLDAS 1/4 degree soil texture');
    set(gca,'fontsize',14);

    fileStr = strcat('gldas_0p25_soil_texture.jpg');
    export_fig( sprintf(['./'  fileStr]) ,'-m2');
