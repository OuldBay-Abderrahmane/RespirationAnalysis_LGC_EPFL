%% CUT TASK

% 49 = start of task
% 56 = end of task

% 5 = fifth column in data (corresponds to the keylogger column

%% taskTSST phase
rawData = load('D:\VIBES\ACQ\RAW\MAT ext\V1\V178_visit1.mat'); 

%% create an intermediate matrix with only the data of interest
cutdata = rawData.data(:,[1 2 3 4 15]); 

%% eyes closed baseline

start_sampling = find(cutdata(:,5) == 49,1);    % change last number if needed (Labbook: double press?)
stop_sampling = find(cutdata(:,5) == 56,1);    % change the position of the marker if needed (last number
endSampling = stop_sampling - start_sampling;         % change the position here too                 
taskTSST = []; 
toggle = true;
i = 0;                                          % change i value if needed (it's where the sampling will start)
row = 1;

while toggle
    taskTSST (row, :) = cutdata(start_sampling + i,:);

    i = i + 1;
    row = row+1;
    
    if i == endSampling
       toggle = false;
    end
end

%% taskTSST: overlap check

sum(taskTSST(:,5)~=0)                             % if value is under 10, then all is well 
overstep_check = find(taskTSST(:,5)~=0)           % find where overstep is happening
display_overstep = taskTSST(overstep_check,:)     % display values (column 5 = keylogger entries)

%% taskTSST : visual inspection

% display taskTSST
figure(1);
ttsstlength = 1:length(taskTSST);
ttsstRESP = taskTSST(:,1);
ttsstPPG = taskTSST(:,2);
ttsstECG = taskTSST(:,3);
ttsstEDA = taskTSST(:,4);
    
    % Plot respiration data
    ttsstax1 = nexttile;
    plot(ttsstax1, ttsstlength, ttsstRESP,'-','Color','b');
    title(ttsstax1, 'Respiration data');
    xlabel(ttsstax1, 'sample');
    ylabel(ttsstax1, 'value');
    
    % Plot PPG data
    ttsstax2 = nexttile;
    plot(ttsstax2, ttsstlength, ttsstPPG,'-','Color','k');
    title(ttsstax2, 'PPG data');
    xlabel(ttsstax2, 'sample');
    ylabel(ttsstax2, 'value');

    % Plot ECG data
    ttsstax3 = nexttile;
    plot(ttsstax3, ttsstlength, ttsstECG,'-','Color','r');
    title(ttsstax3, 'ECG data');
    xlabel(ttsstax3, 'sample');
    ylabel(ttsstax3, 'value');

    % Plot EDA data
    ttsstax4 = nexttile;
    plot(ttsstax4, ttsstlength, ttsstEDA,'-','Color','g');
    title(ttsstax4, 'EDA data');
    xlabel(ttsstax4, 'sample');
    ylabel(ttsstax4, 'value');
   
%% save matrix in specific directory
%change directory if needed CHANGE NAME OF FILE ANYWAY.
                                                                            % CHANGE HERE
save('M:\Catherine\XP VIBES\STUDY 1\ANALYSIS\CLEAN\ACQ\CUTDATA\V1\TASK TSST\V178_V1_taskTSST.mat', 'taskTSST');
    

%% additional stuff that I used to solve some issues that might be of some help later

start_sampling = find(cutdata(:,5) == 162,1)
endSampling = 579162

start_sampling = find(cutdata(:,5) == 160,1)
endSampling = 330000

start_sampling = start_sampling(39,1)
stop_sampling = stop_sampling(15,1)