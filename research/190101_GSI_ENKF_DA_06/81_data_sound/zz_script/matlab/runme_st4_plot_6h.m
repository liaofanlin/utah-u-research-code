clc; close all; clear all

% purpose: plot the domain to see if my analysis domain fit where the storm is

% get the parameters
    sub_top_parameter;

% load wrf and plot it

    wrf_lon      = double( ncread('./wrfdomain/wrfinput_d01','XLONG') );
    wrf_lat      = double( ncread('./wrfdomain/wrfinput_d01','XLAT') );
    wrf_landmask = double( ncread('./wrfdomain/wrfinput_d01','LANDMASK') );

%     subplot(3,1,1)
%     pcolor(wrf_lon(WRF_X1:WRF_X2,WRF_Y1:WRF_Y2), wrf_lat(WRF_X1:WRF_X2,WRF_Y1:WRF_Y2), wrf_landmask(WRF_X1:WRF_X2,WRF_Y1:WRF_Y2)); 
%     shading flat; hold on;
%     getBGmap(1);  colorbar


            if HOUR{7}=='00'
                temp_day=str2num(DAY)+1;
                if temp_day<10
                    DAY=['0' num2str(temp_day)];
                else
                    DAY=num2str(temp_day);
                end
            end

% load ST4 data
    data  = load(['./st4_data/st4-6h_data/ob.rain_ana.' YEAR MONTH DAY HOUR{7} '.06h']);
    lat_st4 = data(:,2);
    lon_st4 = data(:,3);
    lat_bfgr   = reshape(lat_st4, 1121, 881);
    lon_bfgr   = reshape(lon_st4, 1121, 881);
  
    rain_st4 = data(:,7);

    for w=1:length(rain_st4)
        if rain_st4(w)<0
            rain_st4(w)=0;
        end
    end

    rain_st4_bfgr = reshape(rain_st4 , 1121 , 881 );
    fig = figure; set(fig, 'renderer', 'painters');
    
% Plot ST4 precipitation
    subplot(2,1,1)
    pcolor( lon_bfgr , lat_bfgr , rain_st4_bfgr ); shading flat; hold on
    m=colormap; m(1:1,:)=1; colormap(m); colorbar
    getBGmap(1);
    h=colorbar; caxis([0 20])
    ylabel(h, 'One-hour Precipitation [mm]');
    title('Rain of ST4');
    xlabel('Longitude'); ylabel('Latitude');
    
% Plot ST4 precipitation (zoom in)
    subplot(2,1,2)
    pcolor( lon_bfgr , lat_bfgr , rain_st4_bfgr ); shading flat; hold on
    m=colormap; m(1:1,:)=1; colormap(m); colorbar
    getBGmap(1);
    h=colorbar; caxis([0 20])
    ylabel(h, 'One-hour Precipitation [mm]');
    title('Rain of ST4 (zoom in)');
    xlabel('Longitude'); ylabel('Latitude');
    axis([wrf_lon(WRF_X1,WRF_Y1)  wrf_lon(WRF_X2,WRF_Y1)  wrf_lat(WRF_X1,WRF_Y1)  wrf_lat(WRF_X2,WRF_Y2)]);

% Save the figures into files
    if exist('./st4_data/st4-6h_bfgr_fig','dir')~=7
        mkdir('./st4_data/st4-6h_bfgr_fig');
    end
    
    saveas(fig, ['./st4_data/st4-6h_bfgr_fig/st4_rain_bfgr_' YEAR MONTH DAY HOUR{7} '.jpg'])
    