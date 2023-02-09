%% DATA VISUAL INSPECTION LOOP

% variables required to load the files of interest
commonPathSmoothedData = fullfile('M:','Catherine','XP VIBES',...
        'STUDY 1','ANALYSIS','CLEAN','PHYSIO','RESPIRATION');
folderNames = {'ANTICIPATION', 'BASELINE EYES CLOSED', 'BASELINE EYES OPENED'};

commonPathRawData = fullfile('M:','Catherine','XP VIBES','STUDY 1',...
        'ANALYSIS','CLEAN','PHYSIO','CUTDATA','V1');
    
%% 1. Load data from files
for iFolders = 1%1:length(folderNames)
    rootDirSmoothedData = [commonPathSmoothedData, filesep, folderNames{iFolders}];
    rootDirRawData = [commonPathRawData, filesep, folderNames{iFolders}];
    fileNamesSmoothedData = ls([rootDirSmoothedData,filesep,'s*.mat']);
    fileNamesRawData = ls([rootDirRawData,filesep,'V*.mat']);
    
    for iFiles = 5%1:length(fileNames)
        smoothedRespDataFileName = fileNamesSmoothedData(iFiles,:);
        rawRespDataFileName = fileNamesRawData(iFiles,:);
        
        % if you have your own data, type the path to it into rootDir and the name
        % of the file in respDataFileName
        
        dataStructSmoothedData = load(fullfile(rootDirSmoothedData,smoothedRespDataFileName));
        dataStructRawData = load(fullfile(rootDirRawData,rawRespDataFileName));
        
%% 2. Specifying which field in the struct is the respiration data
        
        firstFieldSmoothedData = fieldnames(dataStructSmoothedData);
        dataStructFieldSmoothedData = dataStructSmoothedData.(firstFieldSmoothedData{1});
        respiratoryDataSmoothedData = dataStructFieldSmoothedData(:,1);
        
        firstFieldRawData = fieldnames(dataStructRawData);
        dataStructFieldRawData = dataStructRawData.(firstFieldRawData{1});
        respiratoryDataRawData = dataStructFieldRawData(:,1);
        
%% 3. Plot 
  
        PLOT_LIMITS = 1:length(respiratoryDataSmoothedData);
        figure; hold all;
        
        r=nexttile;
        title(rawRespDataFileName);
        plot(respiratoryDataRawData(PLOT_LIMITS), 'b-');
        legend(r,'Raw Respiration');  
        xlabel('Time (seconds)');
        ylabel('Respiratory Flow');
        
        bc=nexttile;
        title(smoothedRespDataFileName);
        plot(respiratoryDataSmoothedData(PLOT_LIMITS),'r-');
        legend(bc,'Baseline Corrected Respiration');  
        xlabel('Time (seconds)');
        ylabel('Respiratory Flow');
        
    end
end