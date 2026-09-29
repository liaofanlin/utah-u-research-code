function scen05_wrfout_rain_replace(DOMAIN)

tic

% get the parameters
    sub_top_parameter;
    
    rain_acc    = zeros(NX,NY);
    rain_zero   = zeros(NX,NY);
    
    fig = figure; set(fig, 'renderer', 'painters' , 'position',[100 100 1200 900]);

%% Interpolation
%  -------------
    for k = 1 : FORECAST_HOURS
        
        disp(['Replace rainfall at hour ' num2str(k) ' with current time at ' datestr(clock)]);
        
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
            

          
        % load and process ST4 rain
            rain_st4  = ncread(['./process/st4/d' DOMAIN '/st4-1h_atgr_nc/st4_rain_valid_' YEAR MONTH DAY_ST4_str HOUR_ST4_str '.nc'],'ST4_1h_rain');
            
            rain_acc = rain_acc+rain_st4;
            
            rainnc_bf   = double(ncread(['./wrfout/opl/wrfout_d' DOMAIN '_' YEAR '-' MONTH '-' DAY_ST4_str '_' HOUR_ST4_str WRFOUT_string],'RAINNC'));
            rainc_bf    = double(ncread(['./wrfout/opl/wrfout_d' DOMAIN '_' YEAR '-' MONTH '-' DAY_ST4_str '_' HOUR_ST4_str WRFOUT_string],'RAINC'));
            wrf_lon     = double(ncread(['./wrfout/opl/wrfout_d' DOMAIN '_' YEAR '-' MONTH '-' DAY_ST4_str '_' HOUR_ST4_str WRFOUT_string],'XLONG'));
            wrf_lat     = double(ncread(['./wrfout/opl/wrfout_d' DOMAIN '_' YEAR '-' MONTH '-' DAY_ST4_str '_' HOUR_ST4_str WRFOUT_string],'XLAT'));
                           
            
            ncwrite(['./process/wrfout/d' DOMAIN '/wrfout_d' DOMAIN '_' YEAR '-' MONTH '-' DAY_ST4_str '_' HOUR_ST4_str WRFOUT_string],...
                    'RAINNC',rain_acc);
                
            ncwrite(['./process/wrfout/d' DOMAIN '/wrfout_d' DOMAIN '_' YEAR '-' MONTH '-' DAY_ST4_str '_' HOUR_ST4_str WRFOUT_string],...
                    'RAINC',rain_zero);
                
            rainnc_af = double(ncread(['./process/wrfout/d' DOMAIN '/wrfout_d' DOMAIN '_' YEAR '-' MONTH '-' DAY_ST4_str '_' HOUR_ST4_str WRFOUT_string],'RAINNC'));
            rainc_af  = double(ncread(['./process/wrfout/d' DOMAIN '/wrfout_d' DOMAIN '_' YEAR '-' MONTH '-' DAY_ST4_str '_' HOUR_ST4_str WRFOUT_string],'RAINC'));
                
            
        % Plot the precipitation
            subplot(2,2,1);
            pcolor( wrf_lon , wrf_lat , rainnc_bf ); shading flat; hold on
            
            
            getBGmap(1); caxis([0 64]);
            m=colormap;
            m(1:1,:)=1;
            colormap(m)
            colorbar
            
            title(['RAINNC (bf)']);

            subplot(2,2,2);
            pcolor( wrf_lon , wrf_lat , rainc_bf ); shading flat; hold on
            h=colorbar; 
            getBGmap(1); caxis([0 64]);            
            title(['RAINC (bf)']);

            subplot(2,2,3);
            pcolor( wrf_lon , wrf_lat , rainnc_af ); shading flat; hold on
            h=colorbar; 
            getBGmap(1); caxis([0 64]);

            title(['RAINNC (af)']);

            subplot(2,2,4);
            pcolor( wrf_lon , wrf_lat , rainc_af ); shading flat; hold on
            h=colorbar; 
            getBGmap(1); caxis([0 64]);            
            title(['RAINC (af)']);
            
            saveas(fig,['./process/wrfout/d' DOMAIN '/wrfout_rain_bfgr_' YEAR MONTH DAY_ST4_str HOUR_ST4_str '.jpg']);
   
            clf
    end

    toc

