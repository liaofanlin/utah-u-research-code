function scen05_st4(DOMAIN)

% get the parameters
    sub_top_parameter;

% create folders
    if exist( ['./process/st4/d' DOMAIN '/st4-1h_bfgr_txt'],'dir')~=7
        mkdir(['./process/st4/d' DOMAIN '/st4-1h_bfgr_txt']);
    end

    if exist( ['./process/st4/d' DOMAIN '/st4-1h_bfgr_fig'],'dir')~=7
        mkdir(['./process/st4/d' DOMAIN '/st4-1h_bfgr_fig']);
    end

    if exist( ['./process/st4/d' DOMAIN '/st4-1h_atgr_nc'],'dir')~=7
        mkdir(['./process/st4/d' DOMAIN '/st4-1h_atgr_nc']);
    end

% source of wrfout:
    if DOMAIN=='01'
    	wrf_lon      = double( ncread('./wrfout/domain/d01/wrfout_d01','XLONG') );
    	wrf_lat      = double( ncread('./wrfout/domain/d01/wrfout_d01','XLAT') );
    	wrf_landmask = double( ncread('./wrfout/domain/d01/wrfout_d01','LANDMASK') );
    end

    if DOMAIN=='02'
    	wrf_lon      = double( ncread('./wrfout/domain/d02/wrfout_d02','XLONG') );
    	wrf_lat      = double( ncread('./wrfout/domain/d02/wrfout_d02','XLAT') );
    	wrf_landmask = double( ncread('./wrfout/domain/d02/wrfout_d02','LANDMASK') );
    end

    if DOMAIN=='03'
    	wrf_lon      = double( ncread('./wrfout/domain/d03/wrfout_d03','XLONG') );
    	wrf_lat      = double( ncread('./wrfout/domain/d03/wrfout_d03','XLAT') );
    	wrf_landmask = double( ncread('./wrfout/domain/d03/wrfout_d03','LANDMASK') );
    end

% test plot (landmask)
    pcolor(wrf_lon, wrf_lat, wrf_landmask); shading flat
    hold on;
    getBGmap(1)
    colorbar

    fig = figure; set(fig, 'renderer', 'painters');

%% Interpolation
%  -------------
    for k = 1 : FORECAST_HOURS
        
        disp(['Processing hour ' num2str(k) ' with current time at ' datestr(clock)]);
        
        % Process of day and hour strings
            HOUR_ST4 = str2num(HOUR) + k;

            if HOUR_ST4 >= 24
                quotient = fix(HOUR_ST4/24);
                HOUR_ST4 = HOUR_ST4 - 24 * quotient;
                DAY_ST4 = str2num(DAY) + 1;
            else
            	 DAY_ST4 = str2num(DAY);   
            end

            if HOUR_ST4 <10
                HOUR_ST4_str = ['0' num2str(HOUR_ST4)];
            else
                HOUR_ST4_str = num2str(HOUR_ST4);
            end

            if DAY_ST4 < 10
                DAY_ST4_str = ['0' num2str(DAY_ST4)];
            else
                DAY_ST4_str = num2str(DAY_ST4);
            end
            
        % load and process ST4 rain
            data  = load(['./data/st4/ob.rain_ana.' YEAR MONTH DAY_ST4_str HOUR_ST4_str '.01h']);
                
            lat_st4 = data(:,2);   lat_bfgr = reshape(lat_st4,1121,881);
            lon_st4 = data(:,3);   lon_bfgr = reshape(lon_st4,1121,881);
            rain_st4 = data(:,7); 
            
            ind=find(rain_st4<0);  rain_st4(ind)=0;
            rain_st4_bfgr = reshape(rain_st4 , 1121 , 881 );
        
        % Specify a region of ST4 data for analysis
            xx = [wrf_lon(1,1) wrf_lon(end,1) wrf_lon(end,end) wrf_lon(1,end) wrf_lon(1,1)];
            yy = [wrf_lat(1,1) wrf_lat(end,1) wrf_lat(end,end) wrf_lat(1,end) wrf_lat(1,1)];
            
                        
        % Plot the precipitation
            pcolor( lon_bfgr , lat_bfgr , rain_st4_bfgr ); shading flat; hold on
            h=colorbar; 
            ylabel(h, 'Hourly Precipitation [mm/hr]');
            getBGmap(1); caxis([0 10])
            plot(xx,yy,'k','linewidth',2);
            m=colormap; m(1:1,:)=0.7; colormap(m); colorbar
            title(['Rain of ST4 valid at ' YEAR '-' MONTH '-' DAY_ST4_str ':' HOUR_ST4_str ' (-bfgr)']);
            xlabel('Longitude'); ylabel('Latitude');
            saveas(fig,['./process/st4/d' DOMAIN '/st4-1h_bfgr_fig/st4_rain_bfgr_' YEAR MONTH DAY_ST4_str HOUR_ST4_str '.jpg']);
            
            clf        
            
        % Upscaling ST4
            for u=1:fix(1121/ratio)
                for v=1:fix(881/ratio)
                    rain_temp              = rain_st4_bfgr( ((u-1)*ratio+1):(u*ratio) , ((v-1)*ratio+1):(v*ratio) );
                    st4_rain_bfgr_up(u,v)  = sum(sum(rain_temp))/ratio^2;
                    st4_lon_bfgr_up(u,v)   = lon_bfgr( (u)*ratio-INDEX , (v)*ratio-INDEX );
                    st4_lat_bfgr_up(u,v)   = lat_bfgr( (u)*ratio-INDEX , (v)*ratio-INDEX );
                end
            end   
                     
        % Regrid
            wrf_lon_atgr = wrf_lon(WRF_X1:WRF_X2,WRF_Y1:WRF_Y2);
            wrf_lat_atgr = wrf_lat(WRF_X1:WRF_X2,WRF_Y1:WRF_Y2);
            
            for u=1:(WRF_X2-WRF_X1+1)
                for v=1:(WRF_Y2-WRF_Y1+1)
                    rain_atgr(u,v) = liaofan_interpolate( st4_lon_bfgr_up , ...
                                                          st4_lat_bfgr_up , ...
                                                          st4_rain_bfgr_up , ...
                                                          x_left_ind, ...
                                                          x_right_ind, ...
                                                          y_bottom_ind, ...
                                                          y_top_ind, ...
                                                          wrf_lon_atgr(u,v), ...
                                                          wrf_lat_atgr(u,v));
                end
            end
    
    	 %% Create NC file
	 	 %  --------------
    		  file_path = ['./process/st4/d' DOMAIN '/st4-1h_atgr_nc/st4_rain_valid_' YEAR MONTH DAY_ST4_str HOUR_ST4_str '.nc'];
    		  delete(file_path);
    
    		  ST4_1h_rain = zeros(NX,NY);
    		  ST4_1h_rain(:) = NaN;
    		  ST4_1h_rain(WRF_X1:WRF_X2,WRF_Y1:WRF_Y2) = rain_atgr;  
    
    		  % Create NetCDF variables
        			nccreate( file_path , 'LON'         , 'Dimensions',{'X' NX 'Y' NY}        , 'Format','classic');     
        			nccreate( file_path , 'LAT'         , 'Dimensions',{'X' NX 'Y' NY}        , 'Format','classic');
        			nccreate( file_path , 'ST4_1h_rain' , 'Dimensions',{'X' NX 'Y' NY}        , 'Format','classic');
        
    		  % Write variables into the NetCDF file
        			ncwrite( file_path , 'LON'          , wrf_lon );
        			ncwrite( file_path , 'LAT'          , wrf_lat );
        			ncwrite( file_path , 'ST4_1h_rain'  , ST4_1h_rain);
        
    		  % Add global or local attributes
        	  % Source: http://www.mathworks.com/help/matlab/ref/ncwriteatt.html
        			fileattrib( file_path , '+w');
        			ncwriteatt( file_path , '/' , 'creation_date', datestr(now) );
        			ncwriteatt( file_path , 'ST4_1h_rain' , 'Unit', 'mm/h' );

        
    end


