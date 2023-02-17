function [signalFiltered, time, start] = filterSignal(folderPath, file, filterBand, freq)
    % [signalFiltered, time, start] = filterSignal(folderPath, file, filterBand, freq)
    % Acces and filter the signal using siemems functions and band pass
    % filter 
    % 
    % INPUT
    % - folderPath: Folder path 
    % - file: file to processes
    % - filterBand: frequences of the band pass filter [x y]
    % - freq: Sample rate
    %
    % OUTPUT :
    % signalFiltered: signal output after being filtered
    % time: signal time array  
    % start: index of signal start
    %
    % Developed by Abderrahmane Ould Bay - 15/02/2023
    
    %% Load the file
    [signal, time, start] = siemens_RESPload2(fullfile(folderPath, file));

    %% Remove outlier using mean +- n*std
    meanSignal = mean(signal);
    stdSignal= std(signal);
    signalTroncated = remove(signal, meanSignal, stdSignal); 

    %% Apply filter
    order= 1;
    [b, a] = butter(order, filterBand / (freq / 2), 'bandpass');
    signalFiltered  = filter(b, a, signalTroncated);
end