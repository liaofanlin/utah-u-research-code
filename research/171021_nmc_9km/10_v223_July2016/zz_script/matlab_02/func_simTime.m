function [simTime] = func_simTime(DATE)

fid1 = fopen(['./data/sim_time_' DATE '.txt'],'r');

% load and read the text file
% ---------------------------
    tline=fgets(fid1);
 
    t=0;
    while ischar(tline);
        t=t+1;
        
        if t>0;
            ind = strfind(tline,'2013');
            month(t)  = str2num(tline(ind+5:ind+6));
            day(t)    = str2num(tline(ind+8:ind+9));
            hour(t)   = str2num(tline(ind+11:ind+12));
            minute(t) = str2num(tline(ind+14:ind+15));
        
        end
        tline=fgets(fid1);
    end
    fclose(fid1);


% Calculating simulation time
% -----------------------------
    for i=2: (t)
        if month(t) == month(t)
            if day(i)==day(i-1)
                simTime = ( hour(i)-hour(i-1) ) *60 + ( minute(i) - minute(i-1) );
            elseif ( day(i)-day(i-1) )== 1
                simTime = ( hour(i)-hour(i-1) ) *60 + ( minute(i) - minute(i-1) ) + 1 * 24 * 60 ;
            else
                disp('More than 24 hours here');
            end

        elseif (month(t) == 9) && (month(t) == 10)
            disp('Month is different v1');

        else
            disp('Month is different v2');
        end
    end
    
