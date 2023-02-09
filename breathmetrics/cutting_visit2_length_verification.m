%% CUTTING VISIT 2 LENGTH VERIFICATION
% written by Catherine Bratschi
% september 2022

%% Define rootpath
rootDir = fullfile('\\', 'svfas5.epfl.ch', 'Sandi-Lab', 'Catherine', ...
    'XP VIBES', 'STUDY 1', 'ANALYSIS');
folderDir = fullfile('\\', 'svfas5.epfl.ch', 'Sandi-Lab', 'Catherine', ...
    'XP VIBES', 'STUDY 1', 'ANALYSIS', 'CLEAN', 'PHYSIO', 'CUTDATA', 'V2');
folderNames = {'1 BASELINE EYES CLOSED', '2 BASELINE EYES OPENED', ...
    '3 ANXIETY OPEN FIELD', '4 ANXIETY ELEVATED PLATFORM WAY UP', ...
    '5 ANXIETY ELEVATED PLATFORM TOP', '6 ANXIETY ELEVATED PLATFORM WAY DOWN', ...
    '7 ANXIETY ELEVATED PLATFORM FULL', '8 ANXIETY DARK MAZE', ...
    '9 STRESS MIST TRAINING', '10 STRESS MIST EXPERIMENT PHASE 1',...
    '11 STRESS MIST EXPERIMENT PHASE 2', '12 STRESS MIST EXPERIMENT PHASE 3', ...
    '13 STRESS MIST EXPERIMENT PHASE 4', '14 STRESS MIST EXPERIMENT FULL', ...
    '15 NEUTRAL CONTROL'};
outputNames = {'baselineEyesClosed', 'baselineEyesOpened', ...
    'anxietyOpenField', 'anxietyElevatedPlatformWUP', ...
    'anxietyElevatedPlatformTOP', 'anxietyElevatedPlatformWDN', ...
    'anxietyElevatedPlatformFULL', 'anxietyDarkMaze', ...
    'stressMISTtraining', 'stressMISTexperimentPhase1', ...
    'stressMISTexperimentPhase2', 'stressMISTexperimentPhase3', ...
    'stressMISTexperimentPhase4', 'stressMISTexperimentFULL', ...
    'neutralControl'};

lengthList = zeros;
Xaxis = zeros;
row = 1;
labels = zeros;
close all;

for iFolders = 15:length(folderNames)
    currentFolder = folderNames{iFolders};
    currentOutputName = outputNames{iFolders};
    fileDir = [folderDir, filesep, currentFolder];
    fileNames = ls([fileDir,filesep,'V*.mat']);
    labels = 1:length(fileNames);

    for iFiles = 1:length(fileNames)
        currentDataFileName = fileNames(iFiles, :);
        dataStruct = load(fullfile(fileDir, currentDataFileName));
        selectField = fieldnames(dataStruct);
        rawData = dataStruct.(selectField{1});
        
        lengthList(iFiles, 1) = length(rawData(:,1));
        Xaxis (iFiles, 1) = 1;
%         labels(row, 1) = string(fileNames(1:4));
        
        clc;
        disp(strcat('Length extracted_', num2str(iFiles), '/', ...
            num2str(length(fileNames)), '_from folder_', ...
            num2str(iFolders), '/', num2str(length(folderNames))))
    end

    figure;
    hold on;
    title(num2str(currentOutputName));
    scatter(Xaxis, lengthList);
    labelpoints(Xaxis, lengthList, labels); % , 'outliers_lin', {'sd', 1.5}
    
    changeListName = strcat(currentOutputName, '_lengthList');
    eval([changeListName '=lengthList;']); 
end
