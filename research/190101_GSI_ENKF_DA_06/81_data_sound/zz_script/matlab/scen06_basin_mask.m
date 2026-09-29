function scen05_basin_mask(DOMAIN)

tic 

% get the parameters
    sub_top_parameter;
   
    data_path_terrestrial   = './data/hydro';
    data_path_wrfout        = './wrfout/domain/d03';
    data_path_tribs         = './process/tribs';
    
% create folders
    if exist( [data_path_tribs '/nc_mask'],'dir')~=7
        mkdir([data_path_tribs '/nc_mask']);
    end

% Load data
% ----------
    % Load data from terrestrial file
        lon_hydro   = double( ncread( [data_path_terrestrial '/Fulldom_hires_netcdf_file.nc'],'LONGITUDE') );
        lat_hydro   = double( ncread( [data_path_terrestrial '/Fulldom_hires_netcdf_file.nc'],'LATITUDE') );
        frxst_pts   = double( ncread( [data_path_terrestrial '/Fulldom_hires_netcdf_file.nc'],'frxst_pts') );
        basn_msk    = double( ncread( [data_path_terrestrial '/Fulldom_hires_netcdf_file.nc'],'basn_msk') );
       
    % Get the outlet lon and lat
        ind =find(frxst_pts>0);
        lon_outlet = lon_hydro(ind);
        lat_outlet = lat_hydro(ind);

    % Load data from wrfout
        lon_wrf = double( ncread( [data_path_wrfout '/wrfout_d03'],'XLONG') )   ;
        lat_wrf = double( ncread( [data_path_wrfout '/wrfout_d03'],'XLAT') );

        
% Process basin mask 
% ------------------
    % basn_msk arrary has a different arrary direction to the WRF arrary.
    basn_msk_fliplr = fliplr(basn_msk);
    
    mask_wrf = NaN(NX,NY);
    k=0;
    for i=1:NX
        for j=1:NY
            % Get the hydro info. within a WRF grid
                basn_msk_region = basn_msk_fliplr( ((i-1)*lsm_to_hydro_ratio+1) : (i*lsm_to_hydro_ratio) , ...
                                                   ((j-1)*lsm_to_hydro_ratio+1) : (j*lsm_to_hydro_ratio));
                                                   
            % Fidn out the number of Hydro pixels within a WRF grid
            ind_overlap = find( basn_msk_region == 1 ); % ID=1 --> Turkey basin

            % If the number of Hydro pixels is more than 50%, do the following
            if length(ind_overlap)> (lsm_to_hydro_ratio^2)/2
                k               = k+1; % couting the number of WRF grids in a basin
                mask_wrf(i,j)   = 6;  
            end          
        end
    end
    
% Create NC file
% --------------
    file_path = [data_path_tribs '/nc_mask/wrf_hydro_mask.nc'];
    delete(file_path);
    
    % Create NetCDF variables
        nccreate( file_path , 'LON'  , 'Dimensions',{'X' NX 'Y' NY} , 'Format','classic');     
        nccreate( file_path , 'LAT'  , 'Dimensions',{'X' NX 'Y' NY} , 'Format','classic');
        nccreate( file_path , 'MASK' , 'Dimensions',{'X' NX 'Y' NY} , 'Format','classic');
        
    % Write variables into the NetCDF file
        ncwrite( file_path , 'LON'  , lon_wrf );
        ncwrite( file_path , 'LAT'  , lat_wrf );
        ncwrite( file_path , 'MASK' , mask_wrf );
        
    % Add global or local attributes
    % Source: http://www.mathworks.com/help/matlab/ref/ncwriteatt.html
        fileattrib( file_path , '+w');
        ncwriteatt( file_path , '/' , 'creation_date', datestr(now) );
        ncwriteatt( file_path , '/' , 'total WRF grids in the Turkey Basin', num2str(k) );
        ncwriteatt( file_path , 'MASK' , 'Description', 'Turkey Mask over WRF grids' );

% Plot 

% Plot precipitation overlap map
% -----------------------------
% setup
    left_x  = 0.03;
    top_y   = 1.01;
    vspace  = 0.47;
    height  = 0.37;
    width   = 0.9;

    % Because pcolor displays pixels using lon and lat inform. at the
    % corner at the bottom-left grid corner, I did the following action to
    % let pcolor place the filled grids at the center of the grid.  Those
    % two numbers are based on the spacing of WRF lon and lat.
        for j = 1:NY
            if j==1
                wrf_lat_new(:,j) = lat_wrf(:,j) - (lat_wrf(1,2)-lat_wrf(1,1))/2;
            else
                wrf_lat_new(:,j) = lat_wrf(:,j) - (lat_wrf(1,j)-lat_wrf(1,j-1))/2;
            end
        end
        for i = 1:NX
            if i==1
                wrf_lon_new(i,:) = lon_wrf(i,:) - (lon_wrf(2,1)-lon_wrf(1,1))/2;
            else
                wrf_lon_new(i,:) = lon_wrf(i,:) - (lon_wrf(i,1)-lon_wrf(i-1,1))/2;
            end
        end


    %  Figure part one
    fig = figure('position',[100 100 1000 1000],'color','w','renderer', 'painters');
        subplot(2,1,1,'position',[left_x top_y-vspace*1 width height])
            % Add WRF-Hydro basin map 
            pcolor( lon_hydro , lat_hydro , basn_msk ); shading flat; hold on
            % Add the outlets WRF-Hydro basins
            scatter(lon_outlet,lat_outlet,30,'MarkerEdgeColor','red','linewidth',2);

            title('WRF-Hydro basins');
            contourcmap('jet',[-0.5:1:6.5]);
            m=colormap; m(1:1,:)=1; m(7:7,:)=0.3;
            colormap(m);

            axis equal
            ylim([min(lat_wrf(:)) max(lat_wrf(:))]); xlim([min(lon_wrf(:)) max(lon_wrf(:))])

            % Add color bar information 
            h=colorbar;
            caxis([-0.5 6.5])
            ylabel(h,'Hydro Basin Number');
            set(h,'Ytick',[0 1 2 3 4 5 6],'YTickLabel',{'No basin','1','2','3','4','5','LSM grid'});
            grid on
            
            % add LSM grids
            pcolor(wrf_lon_new,wrf_lat_new,nan(NX,NY));

    %  Figure part two
        subplot(2,1,2,'position',[left_x top_y-vspace*2 width height])
            % Add WRF-Hydro basin map 
            pcolor( lon_hydro ,lat_hydro , basn_msk ); shading flat; hold on
            % add WRF LSM grids
            pcolor(wrf_lon_new,wrf_lat_new, mask_wrf ); shading flat;
            % Add the outlets WRF-Hydro basins
            scatter(lon_outlet,lat_outlet,30,'MarkerEdgeColor','red','linewidth',2);

            title('WRF-Hydro basins');

            axis equal
            ylim([min(lat_wrf(:)) max(lat_wrf(:))]); xlim([min(lon_wrf(:)) max(lon_wrf(:))])

            % Add color bar information 
            caxis([-0.5 6.5])
            grid on
            
    % Clear big variables
        clear lon_hydro lat_hydro basn_mask frxst_pts
            
    % post processing
        % Fore more information of export_fig, see
        %   https://sites.google.com/site/oliverwoodford/software/export_fig
        fileStr = strcat([data_path_tribs '/nc_mask/mask.jpg']);

%         saveas(fig,fileStr); 
        export_fig( sprintf(fileStr) ,'-m2');
        
        clf
        toc
        
