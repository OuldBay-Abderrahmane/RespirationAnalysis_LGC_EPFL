function [average] = averageFeature(array)
    % [average] = averageFeature(array, dimension)
    % averageFeature computes the average of a given vector
    % or array (works with NaNs too)
    %
    % INPUT
    % - array: (self-explanatory) 1D array of data
    %
    % OUTPUT :
    % average - the given feature average
    %
    % Developed by Abderrahmane Ould Bay - 15/02/2023
    
    average = 0;
    for i=1:length(array)
        length1 = length(array);
        currentTask = array{i}(2);
        currentTask = currentTask{1}(1);
        currentTask = currentTask{1};

        if ~ isnan(currentTask)
            average = average + currentTask;
        else
            length1 = length1 - 1;
        end
        if i == length(array)
            average = average/length1;
        end
    end
end