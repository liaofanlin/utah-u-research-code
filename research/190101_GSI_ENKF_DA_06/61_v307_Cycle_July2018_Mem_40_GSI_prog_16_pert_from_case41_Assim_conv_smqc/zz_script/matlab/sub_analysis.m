clear all; 

sub_top_parameter;

for k=1:6
    if HOUR{k+1}=='00'
        temp_day=str2num(DAY)+1;
        if temp_day<10
            DAY=['0' num2str(temp_day)];
        else
            DAY=num2str(temp_day);
        end
    end
    
    rain_nexrad(:,:,k)       = load(['./st4_data/st4-1h_atgr_txt/st4_rain_atgr_' YEAR MONTH DAY HOUR{k+1} '_D' DOMAIN '.txt']);
    rain_control_wrf(:,:,k)  = load(['./wrfout-process/atgr-txt_openwrf/openwrf_rain_atgr_' YEAR MONTH DAY HOUR{k+1} '_D' DOMAIN '.txt']);
    rain_case(:,:,k)  = load(['./wrfout-process/atgr-txt_darun/darun_rain_atgr_' YEAR MONTH DAY HOUR{k+1} '_D' DOMAIN '.txt']);
end

mean01 = mean(rain_nexrad(:));      std01 = std(rain_nexrad(:));
mean02 = mean(rain_control_wrf(:)); std02 = std(rain_control_wrf(:));
mean03 = mean(rain_case(:));        std03 = std(rain_case(:));

diff01 = mean(abs(rain_nexrad(:) - rain_control_wrf(:)));
diff02 = mean(abs(rain_nexrad(:) - rain_case(:)));

R1=corrcoef( rain_nexrad(:) , rain_control_wrf(:) );
R2=corrcoef( rain_nexrad(:) , rain_case(:) );

[a b c]=size(rain_nexrad);
rmse1=0; rmse2=0; rmse3=0; rmse4=0; rmse5=0;

for i=1:(a*b*c)
    rmse1 = rmse1 + (rain_nexrad(i) - rain_control_wrf(i) )^2;
    rmse2 = rmse2 + (rain_nexrad(i) - rain_case(i) )^2;
end

rmse1=sqrt(rmse1/(a*b*c));
rmse2=sqrt(rmse2/(a*b*c));

disp(['- Mean of ST4 -- ' num2str(mean01)]);
disp(['- Mean of openloop -- ' num2str(mean02)]);
disp(['- Mean of darun -- ' num2str(mean03)]);
disp(['- STD of ST4 -- ' num2str(std01)]);
disp(['- STD of openloop -- ' num2str(std02)]);
disp(['- STD of darun -- ' num2str(std03)]);

disp(['- Average precip diff of ST4/openloop : ' num2str(diff01)]);
disp(['- Average precip diff of ST4/darun : ' num2str(diff02)]);
disp(['- Correlation of ST4/openloop --' num2str(R1(1,2))]);
disp(['- Correlation of ST4/darun --' num2str(R2(1,2))]);
disp(['- RMSE of ST4/openloop --' num2str(rmse1)]);
disp(['- RMSE ST4/darun --' num2str(rmse2)]);
   
