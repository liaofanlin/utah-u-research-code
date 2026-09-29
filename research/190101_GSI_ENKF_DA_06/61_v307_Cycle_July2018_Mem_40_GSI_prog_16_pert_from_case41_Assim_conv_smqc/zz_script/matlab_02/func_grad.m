function [grad_start grad_end] = func_grad(DATE)


fid1=fopen(['./data/grad_fn_' DATE],'r');

% load and read the text file
% ---------------------------
    tline = fgets(fid1);
    t = 0;
    while ischar(tline);
        t = t+1;
        
        if t>2;
            iteration(t) = str2num( tline(20:21) );
            if iteration == 0
                grad_start = str2num( tline(23:32) );
            end
            
            if iteration(t) == iteration(t-1)
                iter = iteration(t);
                grad_end = str2num( tline(23:32) );
            end
            
        end
        tline=fgets(fid1);
    end
    fclose(fid1);