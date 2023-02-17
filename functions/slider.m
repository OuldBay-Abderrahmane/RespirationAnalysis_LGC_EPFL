function [signalCleaned, signal_binary] = slider(signal, signal_time, window, file)
    % [signalCleaned, signal_binary] = slider(signal, signal_time, window, file)
    % Give the values of interest during a physical task
    % 
    % INPUT
    % - signal: file 
    % - signal_time: time array of the task
    % - window: sampling rate
    % - file:
    %
    % OUTPUT :
    % signalCleaned: indexes of the start of choice and effort phase
    % signal_binary : effort level chosen
    % 
    % Developed by Abderrahmane Ould Bay - 15/02/2023

    signal_binary = [];
    signalCleaned = signal;
    signalAbs = abs(signal);
    meanAbs= mean(signalAbs);
    treshold = meanAbs/3;
    
    time = window;
    cluster = struct();
    list_clusters = [];
    for i = 1:time:(length(signalAbs)-300)
        if mean(signalAbs(i:i+time))< treshold
            signal_binary = [signal_binary, zeros(1, time)];
            if length(list_clusters)>=1 
                if i == list_clusters(end).end
                    last_cluster = list_clusters(end);
                    last_cluster.end = last_cluster.end + time;
                    list_clusters(end) = last_cluster;
                else
                    cluster.idx = i;
                    cluster.end = i + time;
                    list_clusters = [list_clusters, cluster];
                end
            else
                cluster.idx = i;
                cluster.end = i + time;
                list_clusters = [list_clusters, cluster];
            end
        else
            signal_binary = [signal_binary,  ones(1, time)];
        end
    end

    if ~isempty(list_clusters)
        for i = 1:length(list_clusters)
            current_cluster = list_clusters(i);             
            figure; plot(signal_time(1:length(signalCleaned)), signalCleaned, 'Color', 'k');
            hold on
            yyaxis right; plot(signal_time(1:length(signal_binary)), signal_binary, 'Color', 'r');
            xlabel("Temps")
            title(file)
            yn = questdlg('Remove cluster?','Remove cluster','Yes','No','Yes');
            if strcmp(yn,'Yes')
            signal_binary(current_cluster.idx: current_cluster.end) = 1;
            signalCleaned(current_cluster.idx: current_cluster.end) = NaN;
            elseif strcmp(yn,'No')

            end
            close all
        end
    end

end