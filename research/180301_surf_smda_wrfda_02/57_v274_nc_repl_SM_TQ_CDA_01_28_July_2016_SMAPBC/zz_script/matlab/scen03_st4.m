function scen03_st4(DOMAIN,special_ratio)

% Note
% ===========
% 1. 2016.05.01
%	  - This script can interpolate ST4 to domain of 36- and 9-km grids
% 	  - Please find the following document for more details 
%		 https://liaofanprogress01.files.wordpress.com/2015/12/160428_rn_others_stageiv_precipitation_interpolation.pdf

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

% Loading WRF lon, lat, and landmask
    wrf_lon      = double( ncread(['./wrfout/domain/d' DOMAIN '/wrfout_d' DOMAIN],'XLONG') );
    wrf_lat      = double( ncread(['./wrfout/domain/d' DOMAIN '/wrfout_d' DOMAIN],'XLAT') );
    wrf_landmask = double( ncread(['./wrfout/domain/d' DOMAIN '/wrfout_d' DOMAIN],'LANDMASK') );   

% test plot (landmask)
    pcolor(wrf_lon, wrf_lat, wrf_landmask); shading flat
    hold on;
    getBGmap(1)
    colorbar

    fig = figure; set(fig, 'renderer', 'painters');

%% Interpolation
%  -------------
    time01 = datenum([str2num(YEAR) str2num(MONTH) str2num(DAY) str2num(HOUR) 0 0]);

    for k=1:6   % the end of sixth hour

        % Time process
            time02      = addtodate(time01,k,'hour');
            data_str    = datestr(time02,'yyyy/mm/dd, HH:MM');
            data_year   = data_str(1:4);
            data_month  = data_str(6:7);
            data_day    = data_str(9:10);
            data_hour   = data_str(13:14);
            disp(['Processing the ST4 rainfall valid on ' data_str]);
                            
        % loading lon, lat, and rain
            data  = load(['./data/st4/ob.rain_ana.' data_year data_month data_day data_hour '.01h']);
                
            lat_st4 = data(:,2);   lat_bfgr = reshape(lat_st4,1121,881);
            lon_st4 = data(:,3);   lon_bfgr = reshape(lon_st4,1121,881);
            rain_st4 = data(:,7); 
            ind=find(rain_st4<0);  rain_st4(ind)=0;
            rain_st4_bfgr = reshape(rain_st4 , 1121 , 881 );
        
        % Plot the precipitation
            pcolor( lon_bfgr , lat_bfgr , rain_st4_bfgr); shading flat; hold on
            h=colorbar; 
            ylabel(h, 'Six-hour Precipitation [mm/hr]');
            getBGmap(1); caxis([0 10])
            m=colormap; m(1:1,:)=0.7; colormap(m); colorbar
            title(['Rain of ST4 valid at ' data_year '-' data_month '-' data_day ':' data_hour ' (-bfgr)']);
            xlabel('Longitude'); ylabel('Latitude');
            saveas(fig,['./process/st4/d' DOMAIN '/st4-1h_bfgr_fig/st4_rain_bfgr_' ...
                        data_year data_month data_day data_hour '.jpg']);
            
            clf    
         
         % Interpolation      
            	% Regrid
            	wrf_lon_atgr = wrf_lon(WRF_X1:WRF_X2,WRF_Y1:WRF_Y2);
            	wrf_lat_atgr = wrf_lat(WRF_X1:WRF_X2,WRF_Y1:WRF_Y2);

            	% Find the lon grid size and lat grid size
            	%   Note: lon has the same size while lat has different size.
            	for ii = 1:(WRF_X2-WRF_X1+1)
               	lon_size(ii) = ( wrf_lon(WRF_X1+ii,1) - wrf_lon(WRF_X1+ii-2,1) ) /2 ;
            	end
            	for ii = 1:(WRF_Y2-WRF_Y1+1)
                	lat_size(ii) = ( wrf_lat(1,WRF_Y1+ii) - wrf_lat(1,WRF_Y1+ii-2) ) /2 ;
            	end  
              
            
            	% Use liaofan_interpolate_nearest function
            	tic
            	for u = 1 : (WRF_X2-WRF_X1+1) 
            		
            		disp(['   --> Processing row ' num2str(u) ' out of ' num2str(size(lon_size))]); 
            		
            		for v = 1: (WRF_Y2-WRF_Y1+1)                   
            			rain_atgr(u,v) = liaofan_interpolate_nearest( lon_bfgr , ...
                                                                   lat_bfgr , ...
                                                                   rain_st4_bfgr , ... 
                                                                   WRF_TO_ST4_RATIO , ...
                                                                   wrf_lon_atgr(u,v) , ...
                                                                   wrf_lat_atgr(u,v) , ...
                                                                   lon_size(u) , ...
                                                                   lat_size(v) ) ;  
                	end   
                	
                	disp(['Done with row ' num2str(u) ' out of ' num2str(length(lon_size)) ' in DOMAIN ' DOMAIN ...
                		   ' with exlapsed time = ' num2str(toc) ' sec (new interp. method)']);
                	     
            	end         
        		
        
            
    
    	 %% Create NC file
	 	 %  --------------
    		  file_path = ['./process/st4/d' DOMAIN '/st4-1h_atgr_nc/st4_rain_valid_' ...
                           data_year data_month data_day data_hour '.nc'];
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
