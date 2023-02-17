function [average] = getAverageSecondaryFeature(type, arrayToAverage)
    % [average] = getAverageSecondaryFeature(type, arrayToAverage)
    % Give the average of a feature vector and give NaN if not supported
    % 
    % INPUT
    % - type: feature type 
    % - arrayToAverage:  
    %
    % OUTPUT :
    % average: average of the feature value 
    %
    % Developed by Abderrahmane Ould Bay - 15/02/2023

    if isequal(type, 'BreathingRate') 
        average = sum(arrayToAverage)/length(arrayToAverage);
    elseif isequal(type, 'MinuteVentilation')
        average = sum(arrayToAverage)/length(arrayToAverage);
    elseif isequal(type, 'AverageTidalVolume') 
        average = sum(arrayToAverage)/length(arrayToAverage);
    else 
        average = NaN;
        disp('Secondary Feature Not Supported go to getAverageSecondaryFeature.m and add it ');
    end
end

