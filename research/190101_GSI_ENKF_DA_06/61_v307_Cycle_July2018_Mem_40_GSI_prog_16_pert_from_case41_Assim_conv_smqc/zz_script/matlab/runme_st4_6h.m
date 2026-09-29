clc; close all; clear all

% get the parameters
    sub_top_parameter;

% create folders
    if exist('./st4_data/st4-6h_bfgr_fig','dir')~=7
        mkdir('./st4_data/st4-6h_bfgr_fig');
    end

    if exist('./st4_data/st4-6h_atgr_txt','dir')~=7
        mkdir('./st4_data/st4-6h_atgr_txt');
    end

    if exist('./st4_data/st4-6h_atgr_fig','dir')~=7
        mkdir('./st4_data/st4-6h_atgr_fig');
    end

% source of wrfout:
if DOMAIN=='01'
wrf_lon      = double( ncread('./wrfdomain/wrfinput_d01','XLONG') );
wrf_lat      = double( ncread('./wrfdomain/wrfinput_d01','XLAT') );
wrf_landmask = double( ncread('./wrfdomain/wrfinput_d01','LANDMASK') );
end

if DOMAIN=='02'

% Loading WRF lon and lat data
    wrf_lon_atgr_temp = load('./wrfout-process/wrf_lon_atgr.txt');
    wrf_lat_atgr_temp = load('./wrfout-process/wrf_lat_atgr.txt');
    
    wrf_lon_atgr  = wrf_lon_atgr_temp(WRF_X1:WRF_X2,WRF_Y1:WRF_Y2);
    wrf_lat_atgr  = wrf_lat_atgr_temp(WRF_X1:WRF_X2,WRF_Y1:WRF_Y2);
end


    fig = figure; set(fig, 'renderer', 'painters');
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        % loading lon, lat, and rain
            if HOUR{7}=='00'
                temp_day=str2num(DAY)+1;
                if temp_day<10
                    DAY=['0' num2str(temp_day)];
                else
                    DAY=num2str(temp_day);
                end
            end
                data  = load(['./st4_data/st4-6h_data/ob.rain_ana.' YEAR MONTH DAY HOUR{7} '.06h']);
                
            lat_st4 = data(:,2);   lat_bfgr = reshape(lat_st4,1121,881);
            lon_st4 = data(:,3);   lon_bfgr = reshape(lon_st4,1121,881);
            rain_st4 = data(:,7); 
            ind=find(rain_st4<0);  rain_st4(ind)=0;
            rain_st4_bfgr = reshape(rain_st4 , 1121 , 881 );
        
        % Plot the precipitation
            pcolor( lon_bfgr , lat_bfgr , rain_st4_bfgr); shading flat; hold on
            h=colorbar; 
            ylabel(h, '6H Hourly Precipitation [mm/hr]');
            getBGmap(1); caxis([0 20])
            title(['6H Rain of NEXRAD on ' YEAR '-' MONTH '-' DAY ':' HOUR{7} ' (-bfgr)']);
            xlabel('Longitude'); ylabel('Latitude');
            saveas(fig,['./st4_data/st4-6h_bfgr_fig/st4_rain_bfgr_' YEAR MONTH DAY HOUR{7} '_D' DOMAIN '.jpg']);
            clf        
            
           
            
            
        % Upscaling  
        % -----------------------------------------------------------------
            for u=1:fix(1121/ratio)
                for v=1:fix(881/ratio)
                    rain_temp              = rain_st4_bfgr( ((u-1)*ratio+1):(u*ratio) , ((v-1)*ratio+1):(v*ratio) );
                    st4_rain_bfgr_up(u,v)  = sum(sum(rain_temp))/ratio^2;
                    st4_lon_bfgr_up(u,v)   = lon_bfgr( (u)*ratio-INDEX , (v)*ratio-INDEX );
                    st4_lat_bfgr_up(u,v)   = lat_bfgr( (u)*ratio-INDEX , (v)*ratio-INDEX );
                end
            end     
            
        % Regrid
        % -----------------------------------------------------------------
    
            for u=1:(WRF_X2-WRF_X1+1)
                for v=1:(WRF_Y2-WRF_Y1+1)
                    rain_atgr(u,v) = liaofan_interpolate(st4_lon_bfgr_up, st4_lat_bfgr_up, st4_rain_bfgr_up, 1, fix(1121/ratio)-1, 1, fix(881/ratio)-1, wrf_lon_atgr(u,v),wrf_lat_atgr(u,v)  );
                end
            end
            
            save(       ['./st4_data/st4-6h_atgr_txt/st4_rain_atgr_' YEAR MONTH DAY HOUR{7} '_D' DOMAIN '.txt'],'-ASCII','rain_atgr');
    
    
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    clear all
    % get the parameters
    sub_top_parameter;
    fig = figure; set(fig, 'renderer', 'painters');
    
    
    wrf_lon_atgr_temp = load('./wrfout-process/wrf_lon_atgr.txt');
    wrf_lat_atgr_temp = load('./wrfout-process/wrf_lat_atgr.txt');
    
    wrf_lon_atgr  = wrf_lon_atgr_temp(WRF_X1:WRF_X2,WRF_Y1:WRF_Y2);
    wrf_lat_atgr  = wrf_lat_atgr_temp(WRF_X1:WRF_X2,WRF_Y1:WRF_Y2);
    
    
    % make plots
            if HOUR{7}=='00'
                temp_day=str2num(DAY)+1;
                if temp_day<10
                    DAY=['0' num2str(temp_day)];
                else
                    DAY=num2str(temp_day);
                end
            end
        
        
        rain_atgr = load(['./st4_data/st4-6h_atgr_txt/st4_rain_atgr_' YEAR MONTH DAY HOUR{7} '_D' DOMAIN '.txt']);
        
        
        pcolor(wrf_lon_atgr,wrf_lat_atgr,rain_atgr); shading flat
        m=colormap; m(1:1,:)=1; colormap(m); colorbar
        caxis([0 20])
        hold on; getBGmap(1)
        title(['Six-hour rain (mm) of ST4 at ' YEAR '.' MONTH '.' DAY '-' HOUR{7} ':00']);
        xlabel('Longitude'); ylabel('Latitude');
        set(gca,'box','on')
        saveas(fig, ['./st4_data/st4-6h_atgr_fig/st4_rain_atgr_' YEAR MONTH DAY HOUR{7} '_D' DOMAIN '.jpg'])
        clf 

    
