function [iter cost_start cost_end] = func_cost(DATE)


fid1=fopen(['./data/cost_fn_' DATE],'r');

% load and read the text file
% ---------------------------
    tline = fgets(fid1);
    t = 0;
    while ischar(tline);
        t = t+1;
        
        if t>2;
            iteration(t) = str2num( tline(20:21) );
            if iteration == 0
                cost_start = str2num( tline(23:32) );
            end
            
            if iteration(t) == iteration(t-1)
                iter = iteration(t);
                cost_end = str2num( tline(23:32) );
            end
            
        end
        tline=fgets(fid1);
    end
    fclose(fid1);