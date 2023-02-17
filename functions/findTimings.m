function [idx] = findTimings(time, freq, array, T0)
    % [idx] = findTimings(time, freq, array, T0)
    % Find the different timings of the phases choice effort 
    % 
    % INPUT
    % - time: time array of the task
    % - freq: sample rate
    % - array: phases from the behavior files
    % - T0: Time zero
    %
    % OUTPUT :
    % signalFiltered: signal output after being filtered
    % time: signal time array  
    % start: index of signal start
    %
    % Developed by Abderrahmane Ould Bay - 15/02/2023
    
    idx = zeros(1, length(array));
    array = array - T0;
    for i= 1:length(array)
        for j = 1:length(time)
            if array(i)>time(j) && array(i)<time(j)+ 1/freq
                idx(i) = j+1;
                break;
            elseif array(i)==time(j)
                idx(i) = j;
                break;
            else
            end
        end
    end
end