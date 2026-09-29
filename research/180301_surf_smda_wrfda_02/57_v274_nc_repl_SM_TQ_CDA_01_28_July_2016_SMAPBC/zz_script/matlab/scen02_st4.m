clc; close all; clear all

% get the parameters
    sub_top_parameter;

% create folders
    if exist('./process/st4/st4-6h_bfgr_txt','dir')~=7
        mkdir('./process/st4/st4-6h_bfgr_txt');
    end

    if exist('./process/st4/st4-6h_bfgr_fig','dir')~=7
        mkdir('./process/st4/st4-6h_bfgr_fig');
    end

    if exist('./process/st4/st4-6h_atgr_nc','dir')~=7
        mkdir('./process/st4/st4-6h_atgr_nc');
    end

% source of wrfout:
    if DOMAIN=='01'
    wrf_lon      = double( ncread('./wrfout/domain/d01/wrfout_d01','XLONG') );
    wrf_lat      = double( ncread('./wrfout/domain/d01/wrfout_d01','XLAT') );
    wrf_landmask = double( ncread('./wrfout/domain/d01/wrfout_d01','LANDMASK') );
    end

    if DOMAIN=='02'
    wrf_lon      = double( ncread('./wrfdomain/wrfdomain.nc','XLONG') );
    wrf_lat      = double( ncread('./wrfdomain/wrfdomain.nc','XLAT') );
    wrf_landmask = double( ncread('./wrfdomain/wrfdomain.nc','LANDMASK') );
    end

% test plot (landmask)
    pcolor(wrf_lon, wrf_lat, wrf_landmask); shading flat
    hold on;
    getBGmap(1)
    colorbar

    fig = figure; set(fig, 'renderer', 'painters');

%% Interpolation
%  -------------
    for k=7:7   % the end of sixth hour
        
        % loading lon, lat, and rain
            if HOUR{k}=='00'
                temp_day=str2num(DAY)+1;
                if temp_day<10
                    DAY=['0' num2str(temp_day)];
                else
                    DAY=num2str(temp_day);
                end
            end
                data  = load(['./data/st4/ob.rain_ana.' YEAR MONTH DAY HOUR{k} '.06h']);
                
            lat_st4 = data(:,2);   lat_bfgr = reshape(lat_st4,1121,881);
            lon_st4 = data(:,3);   lon_bfgr = reshape(lon_st4,1121,881);
            rain_st4 = data(:,7); 
            ind=find(rain_st4<0);  rain_st4(ind)=0;
            rain_st4_bfgr = reshape(rain_st4 , 1121 , 881 );
        
        % Plot the precipitation
            pcolor( lon_bfgr , lat_bfgr , rain_st4_bfgr); shading flat; hold on
            h=colorbar; 
            ylabel(h, 'Six-hour Precipitation [mm/hr]');
            getBGmap(1); caxis([0 32])
            m=colormap; m(1:1,:)=0.7; colormap(m); colorbar
            title(['Rain of ST4 valid at ' YEAR '-' MONTH '-' DAY ':' HOUR{k} ' (-bfgr)']);
            xlabel('Longitude'); ylabel('Latitude');
            saveas(fig,['./process/st4/st4-6h_bfgr_fig/st4_rain_bfgr_' YEAR MONTH DAY HOUR{k} '.jpg']);
            
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
            wrf_lon_atgr = wrf_lon(WRF_X1:WRF_X2,WRF_Y1:WRF_Y2);
            wrf_lat_atgr = wrf_lat(WRF_X1:WRF_X2,WRF_Y1:WRF_Y2);
            
            for u=1:(WRF_X2-WRF_X1+1)
                for v=1:(WRF_Y2-WRF_Y1+1)
                    rain_atgr(u,v) = liaofan_interpolate(st4_lon_bfgr_up, st4_lat_bfgr_up, st4_rain_bfgr_up, 1, fix(1121/ratio)-1, 1, fix(881/ratio)-1, wrf_lon_atgr(u,v),wrf_lat_atgr(u,v)  );
                end
            end
            
    end


    
%% Create NC file
%  --------------
  
    file_path = ['./process/st4/st4-6h_atgr_nc/st4_rain_valid_' YEAR MONTH DAY HOUR{k} '.nc'];
    delete(file_path);
    
    ST4_6h_rain = zeros(149,79);
    ST4_6h_rain(:) = NaN;
    ST4_6h_rain(WRF_X1:WRF_X2,WRF_Y1:WRF_Y2) = rain_atgr;
    
    
    figure
        pcolor(wrf_lon,wrf_lat,ST4_6h_rain); shading flat
        m=colormap; m(1:1,:)=0.7; colormap(m); colorbar
        caxis([0 32])
        hold on; getBGmap(1);
    
    
    % Create NetCDF variables
        nccreate( file_path , 'LON'         , 'Dimensions',{'X' 149 'Y' 79}        , 'Format','classic');     
        nccreate( file_path , 'LAT'         , 'Dimensions',{'X' 149 'Y' 79}        , 'Format','classic');
        nccreate( file_path , 'ST4_6h_rain' , 'Dimensions',{'X' 149 'Y' 79}        , 'Format','classic');
        
    % Write variables into the NetCDF file
        ncwrite( file_path , 'LON'          , wrf_lon );
        ncwrite( file_path , 'LAT'          , wrf_lat );
        ncwrite( file_path , 'ST4_6h_rain'  , ST4_6h_rain);
        
    % Add global or local attributes
        % Source: http://www.mathworks.com/help/matlab/ref/ncwriteatt.html
        fileattrib( file_path , '+w');
        ncwriteatt( file_path , '/' , 'creation_date', datestr(now) );
        ncwriteatt( file_path , 'ST4_6h_rain' , 'Unit', 'mm/6h' );

        
        

%% Plot the ST4 precip after regrid
%  --------------------------------
    clear all
    % get the parameters
    sub_top_parameter;
    fig = figure; set(fig, 'renderer', 'painters');
    
    k = 7;
    % loading lon, lat, and rain
        if HOUR{k}=='00'
            temp_day=str2num(DAY)+1;
            if temp_day<10
                DAY=['0' num2str(temp_day)];
            else
                DAY=num2str(temp_day);
            end
        end
    
    % Loading variables
    wrf_lon_atgr = ncread( ['./process/st4/st4-6h_atgr_nc/st4_rain_valid_' YEAR MONTH DAY HOUR{k} '.nc'],'LON');
    wrf_lat_atgr = ncread( ['./process/st4/st4-6h_atgr_nc/st4_rain_valid_' YEAR MONTH DAY HOUR{k} '.nc'],'LAT');
    rain_atgr = ncread( ['./process/st4/st4-6h_atgr_nc/st4_rain_valid_' YEAR MONTH DAY HOUR{k} '.nc'],'ST4_6h_rain');
    
    % Make plot
        pcolor(wrf_lon_atgr,wrf_lat_atgr,rain_atgr); shading flat
        m=colormap; m(1:1,:)=0.7; colormap(m); colorbar
        caxis([0 32])
        hold on; getBGmap(1)
        axis equal
        xlim([min(min(wrf_lon_atgr))+0.2 max(max(wrf_lon_atgr))-0.2]); 
        ylim([min(min(wrf_lat_atgr))+0.2 max(max(wrf_lat_atgr))-0.2]); 
        title(['Six-hour rain (mm) of ST4 valid at ' YEAR '.' MONTH '.' DAY '-' HOUR{k} ':00']);
        xlabel('Longitude'); ylabel('Latitude');
        set(gca,'box','on')

        saveas(fig, ['./process/st4/st4-6h_atgr_nc/st4_rain_atgr_' YEAR MONTH DAY HOUR{k} '_D' DOMAIN '.jpg'])
        clf 
        pause(1)

    
    close all
    

