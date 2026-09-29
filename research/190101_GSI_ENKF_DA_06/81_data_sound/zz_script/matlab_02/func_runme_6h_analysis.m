function func_runme_6h_analysis(month)
%
% example: func_runme_6h_analysis('06')
%

Year = '2009';
Month = month;
% Day = {'10','11','12','13','14','15','16','17','18','19'};
Day = {'10'};
Hour = {'00','06','12','18'};

% use function func_cost and func_grad
    k=0;
    for i=1:1 %length(Day)
        for j=1:length(Hour)
            k=k+1;
            DATE = strcat(Year,Month,Day(i),Hour(j));
            PATH01 = strcat('../',DATE,'/wrfout-process');
            cd(PATH01{1})
            analysis(k,:) = load(['result_' DATE{1} '_D02.txt']);
            cd ../../all
%             analysis = laod('result_')
%             k=k+1;
%             total_fn(k,:) = [iter cost_start cost_end grad_start grad_end];
        end
    end

    mean_st4 = analysis(:,1); 
    mean_wrf_openloop = analysis(:,2); 
    mean_wrf_da = analysis(:,3); 
    mean_trmm = analysis(:,4); 
% 
    std_st4 = analysis(:,5); 
    std_wrf_openloop = analysis(:,6);
    std_wrf_da = analysis(:,7);
    std_trmm = analysis(:,8);
    %
    diff_wrf_openloop = analysis(:,9);
    diff_wrf_da        = analysis(:,10);
    diff_trmm         = analysis(:,11);
    %
    R_wrf_openloop      = analysis(:,12);
    R_wrf_da            = analysis(:,13);
    R_trmm              = analysis(:,14);
    %
    rmse_wrf_openloop   = analysis(:,15);
    rmse_wrf_da         = analysis(:,16);
    rmse_trmm           = analysis(:,17);

    yd=0.19;

% make plot
    fig=figure('position',[100 100 800 900]); set(fig, 'renderer', 'painters');
    subplot(5,1,1,'fontsize',8,'position',[0.1 0.05+4*yd 0.65 0.13]);
        plot(mean_st4,'k','linewidth',2); hold on
        plot(mean_wrf_openloop,'b','linewidth',2); 
        plot(mean_wrf_da,'r','linewidth',2);
        plot(mean_trmm,'g','linewidth',2);
        xlabel('cycle')
        ylabel('Domain mean')

        grid on
        leg1 = legend('ST IV','WRF openloop','WRF DA run','TRMM');
        set(leg1,'position',[0.85 0.05+4*yd 0.08 0.08])
        
    subplot(5,1,2,'fontsize',8,'position',[0.1 0.05+3*yd 0.65 0.13]);
        plot(std_st4,'k','linewidth',2); hold on
        plot(std_wrf_openloop,'b','linewidth',2); 
        plot(std_wrf_da,'r','linewidth',2);
        plot(std_trmm,'g','linewidth',2);
        xlabel('cycle')
        ylabel('STD')

        grid on
        leg2 = legend('ST IV','WRF openloop','WRF DA run','TRMM');
        set(leg2,'position',[0.85 0.05+3*yd 0.08 0.08])
        
        
    subplot(5,1,3,'fontsize',8,'position',[0.1 0.05+2*yd 0.65 0.13]);
        plot(diff_wrf_openloop,'b','linewidth',2); hold on
        plot(diff_wrf_da,'r','linewidth',2);
        plot(diff_trmm,'g','linewidth',2);
        xlabel('cycle')
        ylabel('Mean Abs. Diff.')
        grid on
        leg3 = legend('WRF openloop','WRF DA run','TRMM');
        set(leg3,'position',[0.85 0.05+2*yd 0.08 0.08])
        
    subplot(5,1,4,'fontsize',8,'position',[0.1 0.05+yd 0.65 0.13]);
        plot(R_wrf_openloop,'b','linewidth',2); hold on
        plot(R_wrf_da,'r','linewidth',2);
        plot(R_trmm,'g','linewidth',2);
        xlabel('cycle')
        ylabel('Correlation')
        grid on
        leg4 = legend('WRF openloop','WRF DA run','TRMM');
        set(leg4,'position',[0.85 0.05+yd 0.08 0.08])

    subplot(5,1,5,'fontsize',8,'position',[0.1 0.05 0.65 0.13]);
        plot(rmse_wrf_openloop,'b','linewidth',2); hold on
        plot(rmse_wrf_da,'r','linewidth',2);
        plot(rmse_trmm,'g','linewidth',2);
        xlabel('cycle')
        ylabel('RMSE')
        grid on
        leg5 = legend('WRF openloop','WRF DA run','TRMM');
        set(leg5,'position',[0.85 0.05 0.08 0.08])
        % 
        %
    saveSameSize(fig, 'file', ['6h_analysis_mon' month '.jpg']);     