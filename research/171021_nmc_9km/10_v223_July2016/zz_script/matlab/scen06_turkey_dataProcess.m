function scen06_tribs_dataProcess(DOMAIN)

% get the parameters
    sub_top_parameter;
   
    data_path_st4       = './process/st4/d03/st4-1h_atgr_nc';
    data_path_tribs    = './process/tribs';
    
% create folders
    if exist( [data_path_tribs '/nc_gridded_data'],'dir')~=7
        mkdir([data_path_tribs '/nc_gridded_data']);
    end    
    
    if exist( [data_path_tribs '/txt_tribs_input'],'dir')~=7
        mkdir([data_path_tribs '/txt_tribs_input']);
    end   
    
% Text file initialization
    delete([data_path_tribs '/txt_tribs_input/Rain_turkey.mdf']);
    
    fileID = fopen([data_path_tribs '/txt_tribs_input/Rain_turkey.mdf'],'w');
    
    % write header and the hour 00
    fprintf(fileID,'Y\tM\tD\tH\tR\n');
    fprintf(fileID,'%s\t%s\t%s\t%s\t%s\n', YEAR , MONTH , DAY , HOUR , num2str(0) );


% Rainfall process 
% ----------------
    for k = 1 : FORECAST_HOURS
    
        disp(['Processing tRIBS data at hour ' num2str(k) ' with current time at ' datestr(clock)]);
        
        % Process of day and hour strings
        % -------------------------------
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
            
        % Load and process data
        % ---------------------
            % Load Stage IV rainfall
            rain_st4    = ncread( [ data_path_st4 '/st4_rain_valid_' YEAR MONTH DAY_ST4_str HOUR_ST4_str '.nc'],'ST4_1h_rain');
            mask        = ncread( [ data_path_tribs '/nc_mask/wrf_hydro_mask.nc'],'MASK');
            lon         = ncread( [ data_path_tribs '/nc_mask/wrf_hydro_mask.nc'],'LON');
            lat         = ncread( [ data_path_tribs '/nc_mask/wrf_hydro_mask.nc'],'LAT');

            % Data Process
            rain_turkey = NaN(NX,NY);
            ind = find(mask == 6);
            rain_turkey(ind) = rain_st4(ind);
            
            all_hour_rain = rain_turkey(ind);
            
            % Calculate domain mean
            mean_rain(k) = mean(all_hour_rain);
        
        % Create NC file
        % --------------
            file_path = [data_path_tribs '/nc_gridded_data/gridded_turkey_' YEAR MONTH DAY_ST4_str HOUR_ST4_str '.nc'];
            delete(file_path);        

            % Create NetCDF variables
                nccreate( file_path , 'LON'         , 'Dimensions',{'X' NX 'Y' NY} , 'Format','classic');     
                nccreate( file_path , 'LAT'         , 'Dimensions',{'X' NX 'Y' NY} , 'Format','classic');
                nccreate( file_path , 'HourlyRain'  , 'Dimensions',{'X' NX 'Y' NY} , 'Format','classic');    

            % Write variables into the NetCDF file
                ncwrite( file_path , 'LON'  , lon );
                ncwrite( file_path , 'LAT'  , lat );
                ncwrite( file_path , 'HourlyRain' , rain_turkey );

            % Add global or local attributes
            % Source: http://www.mathworks.com/help/matlab/ref/ncwriteatt.html
                fileattrib( file_path , '+w');
                ncwriteatt( file_path , '/' , 'creation_date', datestr(now) );
                ncwriteatt( file_path , 'HourlyRain' , 'Description', 'Hourly Rain in mm/hr' );
        
        % Write data into txt file
        % ------------------------
        fprintf(fileID,'%s\t%s\t%s\t%s\t%s\n', YEAR , MONTH , DAY_ST4_str , HOUR_ST4_str , sprintf('%.3f', round(mean_rain(k)*1000)/1000) );

            
    end
    
    fclose(fileID);
        
