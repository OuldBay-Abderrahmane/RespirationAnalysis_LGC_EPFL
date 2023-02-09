function [signalFiltered, time, start] = filterSignal(folderPath, file, filterBand, freq)
    
    [signal, time, start] = siemens_RESPload2(fullfile(folderPath, file));
    meanSignal = mean(signal);
    stdSignal= std(signal);
    signalTroncated = remove(signal, meanSignal, stdSignal); 

    order= 1;
    [b, a] = butter(order, filterBand / (freq / 2), 'bandpass');
    % filter the pupil diameter
    signalFiltered  = filter(b, a, signalTroncated);
end