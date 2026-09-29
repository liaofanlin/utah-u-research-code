clc; clear all; close all;
% get the parameters
    sub_top_parameter;

% Loading WRF lon and lat data
    wrf_lon_atgr = load('./st4_data/st4-1h_atgr_txt/st4_lon_atgr_D01.txt');
    wrf_lat_atgr = load('./st4_data/st4-1h_atgr_txt/st4_lat_atgr_D01.txt');
    

% Justifying the DAY
    if (HOUR{7}=='00') 
        temp_day=str2num(DAY)+1;
        if temp_day<10
            DAY=['0' num2str(temp_day)];
        else
            DAY=num2str(temp_day);
        end
    end
    
% Loading tRMM data
    data = load(['st4_data/rainobs-6h_data/ob07_ana_' YEAR MONTH DAY '-' HOUR{7} '.rain']);
    trmm_lon_temp = reshape(data(:,3),1440,400);
    trmm_lat_temp = reshape(data(:,2),1440,400);
    trmm_pcp_temp = reshape(data(:,4),1440,400);

    trmm_lon =trmm_lon_temp(200:470,300:400);
    trmm_lat =trmm_lat_temp(200:470,300:400);
    trmm_pcp =trmm_pcp_temp(200:470,300:400);
    
   
% Interpolation
    for u=1:(WRF_X2-WRF_X1+1)
        for v=1:(WRF_Y2-WRF_Y1+1)
            trmm_pcp_atgr(u,v) = liaofan_interpolate(trmm_lon, trmm_lat, trmm_pcp, 1, 270, 1, 100, wrf_lon_atgr(u,v),wrf_lat_atgr(u,v)  );
        end
    end
    
    
% Save text file
    save(      ['./wrfout-process/trmm_rain_atgr_' YEAR MONTH DAY HOUR{7} '_D' DOMAIN '.txt'],'-ASCII','trmm_pcp_atgr');
    

% Save figure
    fig=figure; set(fig, 'renderer', 'painters');
    subplot(2,1,1)
        pcolor(wrf_lon_atgr,wrf_lat_atgr,trmm_pcp_atgr); shading flat
        hold on; getBGmap(1);
        colorbar
        caxis([0 30]);
        title(['6h TRMM precip after gridded (valid: ' YEAR MONTH DAY ':' HOUR{7} ')']);

    subplot(2,1,2)
        pcolor(trmm_lon,trmm_lat,trmm_pcp); shading flat
        hold on; getBGmap(1);
        colorbar     
        axis([min(min(wrf_lon_atgr)) max(max(wrf_lon_atgr)) min(min(wrf_lat_atgr)) max(max(wrf_lat_atgr))]);
        caxis([0 30]);
        title('6h TRMM precip before gridded');


        saveas(fig,['./wrfout-process/trmm_rain_atgr_' YEAR MONTH DAY HOUR{7} '_D' DOMAIN '.jpg']);
        clf
            
    
    
