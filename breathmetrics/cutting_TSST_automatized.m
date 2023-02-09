%% CUT TASK

% 49 = start of task
% 56 = end of task

% 5 = fifth column in data (corresponds to the keylogger column

% if needed change file directory in the files variable, use commas as
% separators

%% taskTSST phase

files = ls([fullfile('D:', 'VIBES', 'ACQ', 'RAW', 'MAT ext', 'V1'),filesep,'V*.mat']);


for j = 1:length(files)
    
    rawData = load(files(j,:));
    
    cutdata = rawData.data(:,[1 2 3 4 15]); 
    start_sampling = find(cutdata(:,5) == 49,1);    % change last number if needed (Labbook: double press?)
    stop_sampling = (find(cutdata(:,5) == 56,1));
    endSampling = stop_sampling - start_sampling;                         
    taskTSST = []; 
    toggle = true;
    i = 0;                                          % change i value if needed (it's where the sampling will start)
    row = 1;
    
    while toggle
        try
            taskTSST (row, :) = cutdata(start_sampling + i,:);

            i = i + 1;
            row = row+1;
        
            catch ME
                  warning(['Problem in file number ', j, ME.message])
            continue;
        end

        if i == endSampling
           toggle = false;
        end
    end
    
    save(['M:\Catherine\XP VIBES\STUDY 1\ANALYSIS\CLEAN\ACQ\CUTDATA\V1',...
        '\TASK TSST\V' num2str(files(j,2:4)) '_V1_taskTSST.mat'], 'taskTSST');
    j = j + 1;
end

%% done