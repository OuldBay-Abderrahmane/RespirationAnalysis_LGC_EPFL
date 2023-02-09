function [average] = getAverageSecondaryFeature(type, arrayToAverage)
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

