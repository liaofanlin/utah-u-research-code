clc; close all; clear all
% data is from /nv/hp19/llin35/data/research/2013/130211_6h_nested_rainDA/11_case
case_num='11';

xlat = double( ncread('wrfdomain/wrfinput_d01','XLAT') );
xlon = double( ncread('wrfdomain/wrfinput_d01','XLONG') );

% Wind speed
% ----------
    xlat_u = double( ncread('wrfdomain/wrfinput_d01','XLAT_U') );
    xlon_u = double( ncread('wrfdomain/wrfinput_d01','XLONG_U') );
    xlat_v = double( ncread('wrfdomain/wrfinput_d01','XLAT_V') );
    xlon_v = double( ncread('wrfdomain/wrfinput_d01','XLONG_V') );

    u_inc = double( ncread('psot_data/increment.nc','U') );
    v_inc = double( ncread('psot_data/increment.nc','V') );

    u_inc_new = interp2(xlon_u', xlat_u', u_inc(:,:,1)',xlon', xlat');
    v_inc_new = interp2(xlon_v', xlat_v', v_inc(:,:,1)',xlon', xlat');
    u_inc_new=u_inc_new';
    v_inc_new=v_inc_new';

    [m n]=size(xlat);
    for i=1:fix(m/4)
        for j=1:fix(n/4)
            u_inc_new_up3times(i,j)=u_inc_new(i*4,j*4);
            v_inc_new_up3times(i,j)=v_inc_new(i*4,j*4);

        end
    end

    figure
        subplot(3,1,1)
        imagesc(u_inc(:,:,1)'); hold on; set(gca,'YDir','normal'); grid on
        colorbar
        title('U-wind increment (analysis minus background) [m s-1]-layer 1')
        subplot(3,1,2)
        imagesc(v_inc(:,:,1)'); hold on; set(gca,'YDir','normal'); grid on
        colorbar
        title('V-wind increment (analysis minus background) [m s-1]-layer 1')
        subplot(3,1,3)
        quiver(u_inc_new_up3times',v_inc_new_up3times',1.5); 
        title({'Increment of Wind Speed (upscale 4 dx & dy)-layer 1','Max value is 0.026 [m s-1]'});
        colorbar
        axis([0 34 0 24]);


% MU & PSFC
% ---------
    mu_inc = double( ncread('psot_data/increment.nc','MU') );
    psfc_inc = double( ncread('psot_data/increment.nc','PSFC') );

    figure
    subplot(2,1,1)
        imagesc(mu_inc'); hold on; set(gca,'YDir','normal'); grid on
        colorbar
        title('MU increment (analysis minus background) [pa]')  
    subplot(2,1,2)
        imagesc(psfc_inc'); hold on; set(gca,'YDir','normal'); grid on
        colorbar
        title('PSFC increment (analysis minus background) [pa]') 
    
% P & T
% -----
    p_inc = double( ncread('psot_data/increment.nc','P') );
    t_inc = double( ncread('psot_data/increment.nc','T') );
    qvapor_inc = double( ncread('psot_data/increment.nc','QVAPOR') );

    figure
    subplot(3,1,1)
        imagesc(p_inc(:,:,1)'); hold on; set(gca,'YDir','normal'); grid on
        colorbar
        title('P increment (analysis minus background) [pa]-layer 1')  
    subplot(3,1,2)
        imagesc(t_inc(:,:,1)'); hold on; set(gca,'YDir','normal'); grid on
        colorbar
        title('T increment (analysis minus background) [K]-layer 1') 
    subplot(3,1,3)
        imagesc(qvapor_inc(:,:,1)'); hold on; set(gca,'YDir','normal'); grid on
        colorbar
        title('QVAPOR increment (analysis minus background) [kg kg-1]-layer 1')     
        

% Precipitation
% -------------
    rainnc_inc = double( ncread('psot_data/wrfout_inc_07.nc','RAINNC') );
    rainc_inc  = double( ncread('psot_data/wrfout_inc_07.nc','RAINC') );

    rainnc_open= double( ncread('wrfout/openwrf/wrfout_d01_2009-06-11_00:00:00','RAINNC') );
    rainc_open = double( ncread('wrfout/openwrf/wrfout_d01_2009-06-11_00:00:00','RAINC') );

    rainnc_da  = double( ncread('wrfout/darun/wrfout_d01_2009-06-11_00:00:00','RAINNC') );
    rainc_da   = double( ncread('wrfout/darun/wrfout_d01_2009-06-11_00:00:00','RAINC') );

    scrsz = get(0,'ScreenSize');
    
    figure('Position',[scrsz(3)/3 scrsz(4)/3 scrsz(3)/3 scrsz(4)/3])
        imagesc((rainnc_inc+rainc_inc)'); hold on; set(gca,'YDir','normal')
        caxis([-10 10])
        m=colormap; m(32:33,:)=1; colormap(m); colorbar
        max_rain=max(max(rainnc_inc+rainc_inc));
        min_rain=min(min(rainnc_inc+rainc_inc));
        sum_inc=sum(sum(rainnc_inc+rainc_inc));
        grid on
        title({'Total precipitation increment [mm]',['Original data-max= ' num2str(max_rain) ' & min= ' num2str(min_rain)], ['Increment rain = ' num2str(sum_inc) ' mm']});

    figure('Position',[scrsz(3)/3 scrsz(4)/3 scrsz(3)/3 scrsz(4)/3])
        imagesc((rainnc_open+rainc_open)'); hold on; set(gca,'YDir','normal')
        colorbar
        m=colormap; m(1:1,:)=1; colormap(m); colorbar
        title('Total precipitation of open loop [mm]');
		  grid on

