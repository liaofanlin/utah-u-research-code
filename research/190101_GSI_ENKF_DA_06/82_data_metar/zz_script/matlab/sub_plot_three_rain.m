clear all; close all; clc

sub_top_parameter;

    wrf_lon_atgr = load(['./st4_data/st4-1h_atgr_txt/st4_lon_atgr_D' DOMAIN '.txt']);
    wrf_lat_atgr = load(['./st4_data/st4-1h_atgr_txt/st4_lat_atgr_D' DOMAIN '.txt']);
    
    
fig=figure; set(fig, 'renderer', 'painters');
for k=1:6
    if HOUR{k+1}=='00'
        temp_day=str2num(DAY)+1;
        if temp_day<10
            DAY=['0' num2str(temp_day)];
        else
            DAY=num2str(temp_day);
        end
    end
    
    rain_st4       = load(['./st4_data/st4-1h_atgr_txt/st4_rain_atgr_' YEAR MONTH DAY HOUR{k+1} '_D' DOMAIN '.txt']);
    rain_openloop  = load(['./wrfout-process/atgr-txt_openwrf/openwrf_rain_atgr_' YEAR MONTH DAY HOUR{k+1} '_D' DOMAIN '.txt']);
    rain_darun  = load(['./wrfout-process/atgr-txt_darun/darun_rain_atgr_' YEAR MONTH DAY HOUR{k+1} '_D' DOMAIN '.txt']);
    
    if exist('./wrfout-process/threePlot','dir')~=7
        mkdir('./wrfout-process/threePlot');
    end
    
    subplot(3,1,1)    
        pcolor(wrf_lon_atgr,wrf_lat_atgr,rain_st4); shading flat
        m=colormap; m(1:1,:)=1; colormap(m); colorbar
        caxis([0 10])
        hold on; getBGmap(1)
        title({['One-hour rain (mm) at ' YEAR '.' MONTH '.' DAY '-' HOUR{k+1} ':00'],'ST4'}); ylabel({'ST4','Latitude'});
        set(gca,'box','on')

    subplot(3,1,2)    
        pcolor(wrf_lon_atgr,wrf_lat_atgr,rain_openloop); shading flat
        m=colormap; m(1:1,:)=1; colormap(m); colorbar
        caxis([0 10])
        hold on; getBGmap(1)
        ylabel({'Openloop','Latitude'});
        set(gca,'box','on')
        
     subplot(3,1,3)    
        pcolor(wrf_lon_atgr,wrf_lat_atgr,rain_darun); shading flat
        m=colormap; m(1:1,:)=1; colormap(m); colorbar
        caxis([0 10])
        hold on; getBGmap(1)
        xlabel('Longitude'); ylabel({'DA run','Latitude'});
        set(gca,'box','on')       
        
        saveas(fig, ['./wrfout-process/threePlot/Hourly_rain_' YEAR MONTH DAY HOUR{k} '_D' DOMAIN '.jpg'])
    
        clf
    
end
