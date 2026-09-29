function scen03_st4_plot(DOMAIN)

    % get the parameters
    sub_top_parameter;
    fig = figure; set(fig, 'renderer', 'painters');

    time01 = datenum([str2num(YEAR) str2num(MONTH) str2num(DAY) str2num(HOUR) 0 0]);

    for k=1:6   % the end of sixth hour
        
        time02      = addtodate(time01,k,'hour');
        data_str    = datestr(time02,'yyyy/mm/dd, HH:MM');
        data_year   = data_str(1:4);
        data_month  = data_str(6:7);
        data_day    = data_str(9:10);
        data_hour   = data_str(13:14);
    
    % Loading variables
    wrf_lon_atgr 	= ncread( ['./process/st4/d' DOMAIN '/st4-1h_atgr_nc/st4_rain_valid_' data_year data_month data_day data_hour '.nc'],'LON');
    wrf_lat_atgr 	= ncread( ['./process/st4/d' DOMAIN '/st4-1h_atgr_nc/st4_rain_valid_' data_year data_month data_day data_hour '.nc'],'LAT');
    rain_atgr 		= ncread( ['./process/st4/d' DOMAIN '/st4-1h_atgr_nc/st4_rain_valid_' data_year data_month data_day data_hour '.nc'],'ST4_1h_rain');
    
    % Make plot
        pcolor(wrf_lon_atgr,wrf_lat_atgr,rain_atgr); shading flat
        m=colormap; m(1:1,:)=0.7; colormap(m); colorbar
        caxis([0 10])
        hold on; getBGmap(1)
        axis equal
        xlim([min(min(wrf_lon_atgr))+0.2 max(max(wrf_lon_atgr))-0.2]); 
        ylim([min(min(wrf_lat_atgr))+0.2 max(max(wrf_lat_atgr))-0.2]); 
        title(['One-hour rain (mm) of ST4 valid at ' data_year '.' data_month '.' data_day '-' data_hour ':00']);
        xlabel('Longitude'); ylabel('Latitude');
        set(gca,'box','on')

        saveas(fig, ['./process/st4/d' DOMAIN '/st4-1h_atgr_nc/st4_rain_atgr_' data_year data_month data_day data_hour '_D' DOMAIN '.jpg'])
        clf 
        pause(1)

    
    end
