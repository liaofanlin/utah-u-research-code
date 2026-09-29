function func_runme_fn(month)
%
% example: func_runme_fn('06')
%
Year = '2009';
Month = month;
Day = {'10','11','12','13','14','15','16','17','18','19'};
% Day = {'10'};
Hour = {'00','06','12','18'};

% use function func_cost and func_grad
    k=0;
    for i=1:1 %length(Day)
        for j=1:length(Hour)
            [iter cost_start cost_end] = func_cost([Year Month Day{i} Hour{j}]);
            [grad_start grad_end] = func_grad([Year Month Day{i} Hour{j}]);
            [Time] = func_simTime([Year Month Day{i} Hour{j}]);
            
            k=k+1;
            total_fn(k,:) = [iter cost_start cost_end grad_start grad_end];
            simTime(k)=Time;
        end
    end

    cost_fn_s = total_fn(:,2); % end of cost fn
    cost_fn_e = total_fn(:,3); % start of cost fn
    grad_fn_s = total_fn(:,4); % end of grad fn
    grad_fn_e = total_fn(:,5); % start of grad fn

% make plot
    fig=figure; set(fig, 'renderer', 'painters');
    subplot(3,1,1);
        plot(cost_fn_s,'linewidth',2); hold on
        plot(cost_fn_e,'r','linewidth',2); 
        xlabel('cycle')
        ylabel('Cost')
        legend('Start','End')
        grid on

    subplot(3,1,2);
        plot(grad_fn_s,'linewidth',2); hold on
        plot(grad_fn_e,'r','linewidth',2); 
        xlabel('cycle')
        ylabel('Grad')
        legend('Start','End')
        grid on

	 subplot(3,1,3);
	 	  plot(simTime/60,'linewidth',2);
        ylabel('Simulation time [hour]')
        xlabel('Cycle number')
        grid on
        ylim([0 12])

 saveas(fig ,'cost_grad_fn.jpg');
 save( 'cost_grad_fn.txt','-ASCII','total_fn');
        
