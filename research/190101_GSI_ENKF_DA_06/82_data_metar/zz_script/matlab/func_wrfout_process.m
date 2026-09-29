function func_wrfout_process(SCENARIO, YEAR, MONTH, DAY, HOUR, WRF_X1, WRF_X2, WRF_Y1, WRF_Y2, DOMAIN)

% Create the folders
% ------------------
    if exist('./wrfout-process','dir')~=7
        mkdir('./wrfout-process');
    end

    if exist(['./wrfout-process/bfgr-fig_' SCENARIO],'dir')~=7
        mkdir(['./wrfout-process/bfgr-fig_' SCENARIO]);
    end

    if exist(['./wrfout-process/atgr-fig_' SCENARIO],'dir')~=7
        mkdir(['./wrfout-process/atgr-fig_' SCENARIO]);
    end

    if exist(['./wrfout-process/atgr-txt_' SCENARIO],'dir')~=7
        mkdir(['./wrfout-process/atgr-txt_' SCENARIO]);
    end
    
    fig=figure; set(fig, 'renderer', 'painters');
        
for k=1:7
    
    if (k>1)
        if (HOUR{k}=='00') 
            temp_day=str2num(DAY)+1;
            if temp_day<10
                DAY=['0' num2str(temp_day)];
            else
                DAY=num2str(temp_day);
            end
        end
    end
    
    % load lon, lat,and rain
    
    if DOMAIN=='01'
    wrf_lat_bfgr  = double( ncread(['./wrfout/' SCENARIO '/wrfout_d01_' YEAR '-' MONTH '-' DAY '_' HOUR{k} ':00:00'],'XLAT')  ); 
    wrf_lon_bfgr  = double( ncread(['./wrfout/' SCENARIO '/wrfout_d01_' YEAR '-' MONTH '-' DAY '_' HOUR{k} ':00:00'],'XLONG') );
    rainnc(:,:,k) = double( ncread(['./wrfout/' SCENARIO '/wrfout_d01_' YEAR '-' MONTH '-' DAY '_' HOUR{k} ':00:00'],'RAINNC'));
    rainc(:,:,k)  = double( ncread(['./wrfout/' SCENARIO '/wrfout_d01_' YEAR '-' MONTH '-' DAY '_' HOUR{k} ':00:00'],'RAINC') );
    end    
    
    if DOMAIN=='02'
    wrf_lat_bfgr  = double( ncread(['./wrfout/' SCENARIO '/wrfout_d02_' YEAR '-' MONTH '-' DAY '_' HOUR{k} ':00:00'],'XLAT')  ); 
    wrf_lon_bfgr  = double( ncread(['./wrfout/' SCENARIO '/wrfout_d02_' YEAR '-' MONTH '-' DAY '_' HOUR{k} ':00:00'],'XLONG') );
    rainnc(:,:,k) = double( ncread(['./wrfout/' SCENARIO '/wrfout_d02_' YEAR '-' MONTH '-' DAY '_' HOUR{k} ':00:00'],'RAINNC'));
    rainc(:,:,k)  = double( ncread(['./wrfout/' SCENARIO '/wrfout_d02_' YEAR '-' MONTH '-' DAY '_' HOUR{k} ':00:00'],'RAINC') );
    end
    
    if k>1
        % sum up the rainnc and rainc
            rain_bfgr = rainnc(:,:,k) + rainc(:,:,k) - rainnc(:,:,k-1)- rainc(:,:,k-1);
        
        % make plot (bfgr)
            pcolor(wrf_lon_bfgr, wrf_lat_bfgr, rain_bfgr ); shading flat
            m=colormap; m(1:1,:)=1; colormap(m); colorbar
            caxis([0 10])
            hold on; getBGmap(1)
            title(['One-hour rain (mm) of ' SCENARIO ' at ' YEAR '.' MONTH '.' DAY '-' HOUR{k} ':00 (bfgr)']);
            xlabel('Longitude'); ylabel('Latitude');
            set(gca,'box','on')

            saveas(fig,['./wrfout-process/bfgr-fig_' SCENARIO '/' SCENARIO '_rain_bfgr_' YEAR MONTH DAY HOUR{k} '_D' DOMAIN '.jpg']);
            clf
            
        % plot the domain the same as st4 data
            wrf_lon_atgr  = wrf_lon_bfgr(WRF_X1:WRF_X2,WRF_Y1:WRF_Y2);
            wrf_lat_atgr  = wrf_lat_bfgr(WRF_X1:WRF_X2,WRF_Y1:WRF_Y2);
            rain_atgr = rain_bfgr(WRF_X1:WRF_X2,WRF_Y1:WRF_Y2);
            
        % make plot (atgr)
            pcolor(wrf_lon_atgr, wrf_lat_atgr, rain_atgr ); shading flat
            m=colormap; m(1:1,:)=1; colormap(m); colorbar
            caxis([0 10])
            hold on; getBGmap(1)
            axis equal
            xlim([min(min(wrf_lon_atgr))+0.2 max(max(wrf_lon_atgr))-0.2]); 
            ylim([min(min(wrf_lat_atgr))+0.2 max(max(wrf_lat_atgr))-0.2]); 
            title(['One-hour rain (mm) of ' SCENARIO ' at ' YEAR '.' MONTH '.' DAY '-' HOUR{k} ':00']);
            xlabel('Longitude'); ylabel('Latitude');
            set(gca,'box','on')

        % save plot and data in text
            save(      ['./wrfout-process/atgr-txt_' SCENARIO '/' SCENARIO '_rain_atgr_' YEAR MONTH DAY HOUR{k} '_D' DOMAIN '.txt'],'-ASCII','rain_atgr');
            saveas(fig,['./wrfout-process/atgr-fig_' SCENARIO '/' SCENARIO '_rain_atgr_' YEAR MONTH DAY HOUR{k} '_D' DOMAIN '.jpg']);
            clf
    end   
end

