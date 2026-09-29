clear all; 

sub_top_parameter;

% Loading WRF lon and lat data
    wrf_lon_atgr_temp = load('./wrfout-process/wrf_lon_atgr.txt');
    wrf_lat_atgr_temp = load('./wrfout-process/wrf_lat_atgr.txt');
    
    wrf_lon_atgr  = wrf_lon_atgr_temp(WRF_X1:WRF_X2,WRF_Y1:WRF_Y2);
    wrf_lat_atgr  = wrf_lat_atgr_temp(WRF_X1:WRF_X2,WRF_Y1:WRF_Y2);

% Justifying the DAY
    if (HOUR{7}=='00') 
        temp_day=str2num(DAY)+1;
        if temp_day<10
            DAY=['0' num2str(temp_day)];
        else
            DAY=num2str(temp_day);
        end
    end
    
% Load 6-h precipitation
    rain_st4            = load(['./st4_data/st4-6h_atgr_txt/st4_rain_atgr_' YEAR MONTH DAY HOUR{7} '_D' DOMAIN '.txt']);
    rain_wrf_openloop   = load(['./wrfout-process/atgr-txt_openwrf/openwrf_6h_rain_atgr_' YEAR MONTH DAY HOUR{7} '_D' DOMAIN '.txt']);
    rain_wrf_da         = load(['./wrfout-process/atgr-txt_darun/darun_6h_rain_atgr_' YEAR MONTH DAY HOUR{7} '_D' DOMAIN '.txt']);
    rain_trmm           = load(['./wrfout-process/trmm_rain_atgr_' YEAR MONTH DAY HOUR{7} '_D' DOMAIN '.txt']);
  
% Calculate statistic
    mean_st4            = mean(rain_st4(:));            std_st4             = std(rain_st4(:));
    mean_wrf_openloop   = mean(rain_wrf_openloop(:));   std_wrf_openloop    = std(rain_wrf_openloop(:));
    mean_wrf_da         = mean(rain_wrf_da(:));         std_wrf_da          = std(rain_wrf_da(:));
    mean_trmm           = mean(rain_trmm(:));           std_trmm            = std(rain_trmm(:));

    diff_wrf_openloop   = mean(abs(rain_st4(:) - rain_wrf_openloop(:)));
    diff_wrf_da         = mean(abs(rain_st4(:) - rain_wrf_da(:)));
    diff_trmm           = mean(abs(rain_st4(:) - rain_trmm(:)));

    R_wrf_openloop  = corrcoef( rain_st4(:) , rain_wrf_openloop(:) );
    R_wrf_da        = corrcoef( rain_st4(:) , rain_wrf_da(:) );
    R_trmm          = corrcoef( rain_st4(:) , rain_trmm(:) );


    [a b]=size(rain_st4);
    rmse_wrf_openloop = 0; rmse_wrf_da = 0; rmse_trmm = 0; rmse4=0; rmse5=0;

    for i=1:(a*b)
        rmse_wrf_openloop   = rmse_wrf_openloop + (rain_st4(i) - rain_wrf_openloop(i) )^2;
        rmse_wrf_da         = rmse_wrf_da + (rain_st4(i) - rain_wrf_da(i) )^2;
        rmse_trmm           = rmse_trmm + (rain_st4(i) - rain_trmm(i) )^2;
    end

    rmse_wrf_openloop = sqrt(rmse_wrf_openloop/(a*b));
    rmse_wrf_da       = sqrt(rmse_wrf_da/(a*b));
    rmse_trmm     = sqrt(rmse_trmm/(a*b));

% plot
    fig = figure('position',[200 200 900 600]); set(fig, 'renderer', 'painters');
    subplot(2,2,1)
        pcolor(wrf_lon_atgr,wrf_lat_atgr,rain_st4); shading flat
        m=colormap; m(1:1,:)=1; colormap(m); colorbar
        caxis([0 20])
        hold on; getBGmap(1)
        title(['6H rain (mm) of ST4 at ' YEAR '.' MONTH '.' DAY '-' HOUR{7} ':00']);
        xlabel('Longitude'); ylabel('Latitude');
        
    subplot(2,2,2)
        pcolor(wrf_lon_atgr,wrf_lat_atgr,rain_wrf_openloop); shading flat
        m=colormap; m(1:1,:)=1; colormap(m); colorbar
        caxis([0 20])
        hold on; getBGmap(1)
        title(['6H rain (mm) of WRF(openloop) at ' YEAR '.' MONTH '.' DAY '-' HOUR{7} ':00']);
        xlabel('Longitude'); ylabel('Latitude');
        
    subplot(2,2,3)
        pcolor(wrf_lon_atgr,wrf_lat_atgr,rain_trmm); shading flat
        m=colormap; m(1:1,:)=1; colormap(m); colorbar
        caxis([0 20])
        hold on; getBGmap(1)
        title(['6H rain (mm) of TRMM) at ' YEAR '.' MONTH '.' DAY '-' HOUR{7} ':00']);
        xlabel('Longitude'); ylabel('Latitude');
  
    subplot(2,2,4)
        pcolor(wrf_lon_atgr,wrf_lat_atgr,rain_wrf_da); shading flat
        m=colormap; m(1:1,:)=1; colormap(m); colorbar
        caxis([0 20])
        hold on; getBGmap(1)
        title(['6H rain (mm) of WRF(DA) at ' YEAR '.' MONTH '.' DAY '-' HOUR{7} ':00']);
        xlabel('Longitude'); ylabel('Latitude');
    
                
    	  set(fig,'paperposition' ,[0 0 1400/150 1200/150]); % set up paper size
    	  print(fig,'-djpeg',['./wrfout-process/6h_total_rain_' YEAR MONTH DAY HOUR{7} '_D' DOMAIN '.jpg'],'-r500');   % do this to get better figure quality!!
%        saveas(fig, ['./wrfout-process/6h_total_rain_' YEAR MONTH DAY HOUR{7} '_D' DOMAIN '.jpg']);

		  close all

% Display statistics
    disp(['- Mean of ST4 -- ' num2str(mean_st4)]);
    disp(['- Mean of openloop -- ' num2str(mean_wrf_openloop)]);
    disp(['- Mean of darun -- ' num2str(mean_wrf_da)]);
    disp(['- Mean of TRMM -- ' num2str(mean_trmm)]);

    disp(['- STD of ST4 -- ' num2str(std_st4)]);
    disp(['- STD of openloop -- ' num2str(std_wrf_openloop)]);
    disp(['- STD of darun -- ' num2str(std_wrf_da)]);
    disp(['- STD of TRMM -- ' num2str(std_trmm)]);

    disp(['- Average abs. precip diff of ST4/openloop : ' num2str(diff_wrf_openloop)]);
    disp(['- Average abs. precip diff of ST4/darun : ' num2str(diff_wrf_da)]);
    disp(['- Average abs. precip diff of ST4/darun : ' num2str(diff_trmm)]);

    disp(['- Correlation of ST4/openloop --' num2str(R_wrf_openloop(1,2))]);
    disp(['- Correlation of ST4/darun --' num2str(R_wrf_da(1,2))]);
    disp(['- Correlation of ST4/TRMM --' num2str(R_trmm(1,2))]);

    disp(['- RMSE of ST4/openloop --' num2str(rmse_wrf_openloop)]);
    disp(['- RMSE of ST4/darun --' num2str(rmse_wrf_da)]);
    disp(['- RMSE of ST4/TRMM --' num2str(rmse_trmm)]);   

    result = [mean_st4 mean_wrf_openloop mean_wrf_da mean_trmm ...
              std_st4 std_wrf_openloop std_wrf_da std_trmm ...
              diff_wrf_openloop diff_wrf_da diff_trmm ...
              R_wrf_openloop(1,2) R_wrf_da(1,2) R_trmm(1,2) ...
              rmse_wrf_openloop rmse_wrf_da rmse_trmm];
    
    sub_top_parameter;     
    save(['./wrfout-process/result_'  YEAR MONTH DAY HOUR{1} '_D' DOMAIN '.txt'],'-ASCII','result');
    

