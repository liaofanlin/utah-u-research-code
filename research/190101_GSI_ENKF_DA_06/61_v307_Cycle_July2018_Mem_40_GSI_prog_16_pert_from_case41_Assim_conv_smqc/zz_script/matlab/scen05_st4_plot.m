function scen05_st4_plot(DOMAIN)

    % get the parameters
    sub_top_parameter;
    fig = figure; set(fig, 'renderer', 'painters');
    
    for k = 1 : FORECAST_HOURS
    
        disp(['Ploting hour ' num2str(k) ' with current time at ' datestr(clock)]);
        
        % Process of day and hour strings
            HOUR_ST4 = str2num(HOUR) + k;

            if HOUR_ST4 >= 24
                quotient = fix(HOUR_ST4/24);
                HOUR_ST4 = HOUR_ST4 - 24 * quotient;
                DAY_ST4 = str2num(DAY) + 1 * quotient;
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
    
        % Loading variables
            wrf_lon_atgr 	= ncread( ['./process/st4/d' DOMAIN '/st4-1h_atgr_nc/st4_rain_valid_' YEAR MONTH DAY_ST4_str HOUR_ST4_str '.nc'],'LON');
            wrf_lat_atgr 	= ncread( ['./process/st4/d' DOMAIN '/st4-1h_atgr_nc/st4_rain_valid_' YEAR MONTH DAY_ST4_str HOUR_ST4_str '.nc'],'LAT');
            rain_atgr 		= ncread( ['./process/st4/d' DOMAIN '/st4-1h_atgr_nc/st4_rain_valid_' YEAR MONTH DAY_ST4_str HOUR_ST4_str '.nc'],'ST4_1h_rain');
    
        % Make plot
            pcolor(wrf_lon_atgr,wrf_lat_atgr,rain_atgr); shading flat
                m=colormap; m(1:1,:)=0.7; colormap(m); colorbar
                caxis([0 10])
                hold on; getBGmap(1)
                axis equal
                xlim([min(wrf_lon_atgr(:)) max(wrf_lon_atgr(:))]); 
                ylim([min(wrf_lat_atgr(:)) max(wrf_lat_atgr(:))]); 
                title(['One-hour rain (mm) of ST4 valid at ' YEAR '.' MONTH '.' DAY_ST4_str '-' HOUR_ST4_str ':00']);
                xlabel('Longitude'); ylabel('Latitude');
                set(gca,'box','on')

            saveas(fig, ['./process/st4/d' DOMAIN '/st4-1h_atgr_nc/st4_rain_atgr_' YEAR MONTH DAY_ST4_str HOUR_ST4_str '_D' DOMAIN '.jpg'])
            clf; pause(1)
    
    end
