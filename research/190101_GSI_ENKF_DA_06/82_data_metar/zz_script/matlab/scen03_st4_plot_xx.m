function scen03_st4_plot(DOMAIN)

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
    wrf_lon_atgr 	= ncread( ['./process/st4/d' DOMAIN '/st4-6h_atgr_nc/st4_rain_valid_' YEAR MONTH DAY HOUR{k} '.nc'],'LON');
    wrf_lat_atgr 	= ncread( ['./process/st4/d' DOMAIN '/st4-6h_atgr_nc/st4_rain_valid_' YEAR MONTH DAY HOUR{k} '.nc'],'LAT');
    rain_atgr 		= ncread( ['./process/st4/d' DOMAIN '/st4-6h_atgr_nc/st4_rain_valid_' YEAR MONTH DAY HOUR{k} '.nc'],'ST4_6h_rain');
    
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

        saveas(fig, ['./process/st4/d' DOMAIN '/st4-6h_atgr_nc/st4_rain_atgr_' YEAR MONTH DAY HOUR{k} '_D' DOMAIN '.jpg'])
        clf 
        pause(1)

    
    close all
