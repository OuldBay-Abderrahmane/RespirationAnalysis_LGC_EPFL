%% RESPI DATA ANALYSIS PIPELINE

%% 1. load data for analysis
commonPath = fullfile('M:', 'Catherine', 'XP VIBES', 'STUDY 1',...
    'ANALYSIS', 'CLEAN', 'PHYSIO', 'RESPIRATION', 'V2', 'WITHOUT OVERSATURATIONS');
folderNames = {'1 BASELINE EYES CLOSED', '2 BASELINE EYES OPENED', ...
    '3 ANXIETY OPEN FIELD', '4 ANXIETY ELEVATED PLATFORM WAY UP', ...
    '5 ANXIETY ELEVATED PLATFORM TOP', '6 ANXIETY ELEVATED PLATFORM WAY DOWN', ...
    '7 ANXIETY ELEVATED PLATFORM FULL', '8 ANXIETY DARK MAZE', ...
    '9 STRESS MIST TRAINING', '10 STRESS MIST EXPERIMENT PHASE 1' ...
    '11 STRESS MIST EXPERIMENT PHASE 2', '12 STRESS MIST EXPERIMENT PHASE 3', ...
    '13 STRESS MIST EXPERIMENT PHASE 4', '14 STRESS MIST EXPERIMENT FULL', ...
    '15 NEUTRAL CONTROL'};
dataField = {'cleanedRespiData'};

resultsDataField = {'a_eyesClosedBaseline', 'a_eyesOpenedBaseline', 'a_anxietyOpenField', ...
    'a_anxietyElevatedPlatformWUP', 'a_anxietyElevatedPlatformTOP', ...
    'a_anxietyElevatedPlatformWDN', 'a_anxietyElevatedPlatformFULL', ...
    'a_anxietyDarkMaze', 'a_stressMISTtraining', 'a_stressMISTexperimentPHASE1', ...
    'a_stressMISTexperimentPHASE2', 'a_stressMISTexperimentPHASE3', ...
    'a_stressMISTexperimentPHASE4', 'a_stressMISTexperimentFULL', ...
    'a_neutralControl'};
resultsDir = fullfile('M:', 'Catherine', 'XP VIBES', 'STUDY 1', ...
     'ANALYSIS', 'RESULTS', 'VARIABLES');
resultsFileName = 'Respiratory_features_visit2.xlsx';

respiFeaturesStruct = [];

for iFolders = 1:length(folderNames)
    rootDir = [commonPath, filesep, folderNames{iFolders}];
    fileNames = ls([rootDir,filesep,'s*.mat']);
        
    for iFiles = 1:length(fileNames)
        respDataFileName = fileNames(iFiles,:);
        
        % if you have your own data, type the path to it into rootDir and the name
        % of the file in respDataFileName
        
        dataStruct = load(fullfile(rootDir,respDataFileName));
        srate = 1000; % srate is sampling rate in second (here 1000 samples per s)
        dataType = 'humanBB'; % data type for human respiration is either humanAirflow (nasal device) or humanBB (breathing belt)
        
    %% 2. specifying which field in the struct is the respiration data
        
        firstField = fieldnames(dataStruct);
        dataStructField = dataStruct.(firstField{1});
        respiratoryData = dataStructField(:,1);
%         secondField = fieldnames(dataStruct);
%         dataStructField2 = dataStruct.(secondField{2});
%         sampleStatus = dataStructField2(:,1);

    %% QUICK FIX REMOVE NAN FROM DATA %% will most likely need to be brushed up
     
    if sum(isnan(respiratoryData)) ~= 0
        respiratoryData = [respiratoryData(~isnan(respiratoryData))];
    end
        
    %% 3. constructor

        bmObj = data_analysis_respi_functions(respiratoryData, srate, dataType, sampleStatus);

    %% 4. extract all respiratory features

        bmObj.estimateAllRespiFeatures;
        
%     %% 5. plot respi features (just in case we need to check sth)
% 
%         annotations = {'extrema', 'onsets','maxflow','volumes', 'pauses'};
% 
%         fig = bmObj.plotFeatures
%         fig = bmObj.plotFeatures({annotations{1},annotations{4}});
%         set(fig.CurrentAxes,'XLim');
% 
%         fig = bmObj.plotFeatures(annotations{5});
%         set(fig.CurrentAxes,'XLim');

    %% 6. put all respiratory features calculated into a new row in the appropriate field

        respiFeaturesValues = bmObj.secondaryFeatures.values;
        respiFeaturesLabels = bmObj.secondaryFeatures.keys;
        participantID = {respDataFileName(3:6)};
        
        respiFeaturesStruct.(resultsDataField{iFolders}).participantID(iFiles, 1) = participantID;
        
        for iValues = 1:length(respiFeaturesValues)
            fieldName = [respiFeaturesLabels{iValues}];
            respiFeaturesStruct.(resultsDataField{iFolders}).(fieldName)(iFiles,:) = respiFeaturesValues(iValues);     
        end
    
    end
end

%% save data into an xlsx file with separated sheets per condition

     tableRespiratoryFeaturesECB = struct2table(respiFeaturesStruct.(resultsDataField{1}));
     tableRespiratoryFeaturesEOB = struct2table(respiFeaturesStruct.(resultsDataField{2}));
     tableRespiratoryFeaturesAOF = struct2table(respiFeaturesStruct.(resultsDataField{3}));
     tableRespiratoryFeaturesAEPwup = struct2table(respiFeaturesStruct.(resultsDataField{4}));
     tableRespiratoryFeaturesAEPtop = struct2table(respiFeaturesStruct.(resultsDataField{5}));
     tableRespiratoryFeaturesAEPwdn = struct2table(respiFeaturesStruct.(resultsDataField{6}));
     tableRespiratoryFeaturesAEPf = struct2table(respiFeaturesStruct.(resultsDataField{7}));
     tableRespiratoryFeaturesADM = struct2table(respiFeaturesStruct.(resultsDataField{8}));
     tableRespiratoryFeaturesSMISTt = struct2table(respiFeaturesStruct.(resultsDataField{9}));
     tableRespiratoryFeaturesSMISTep1 = struct2table(respiFeaturesStruct.(resultsDataField{10}));
     tableRespiratoryFeaturesSMISTep2 = struct2table(respiFeaturesStruct.(resultsDataField{11}));
     tableRespiratoryFeaturesSMISTep3 = struct2table(respiFeaturesStruct.(resultsDataField{12}));
     tableRespiratoryFeaturesSMISTep4 = struct2table(respiFeaturesStruct.(resultsDataField{13}));
     tableRespiratoryFeaturesSMISTef = struct2table(respiFeaturesStruct.(resultsDataField{14}));
     tableRespiratoryFeaturesNC = struct2table(respiFeaturesStruct.(resultsDataField{15}));
     
         sheet = 1;
     writetable(tableRespiratoryFeaturesECB,resultsFileName,'sheet',sheet)
         sheet = 2;
     writetable(tableRespiratoryFeaturesEOB,resultsFileName,'sheet',sheet)
         sheet = 3;
     writetable(tableRespiratoryFeaturesAOF,resultsFileName,'sheet',sheet)
         sheet = 4;
     writetable(tableRespiratoryFeaturesAEPwup,resultsFileName,'sheet',sheet)
         sheet = 5;
     writetable(tableRespiratoryFeaturesAEPtop,resultsFileName,'sheet',sheet)
         sheet = 6;
     writetable(tableRespiratoryFeaturesAEPwdn,resultsFileName,'sheet',sheet)
         sheet = 7;
     writetable(tableRespiratoryFeaturesAEPf,resultsFileName,'sheet',sheet)
         sheet = 8;
     writetable(tableRespiratoryFeaturesADM,resultsFileName,'sheet',sheet)
         sheet = 9;
     writetable(tableRespiratoryFeaturesSMISTt,resultsFileName,'sheet',sheet)
         sheet = 10;
     writetable(tableRespiratoryFeaturesSMISTep1,resultsFileName,'sheet',sheet)
         sheet = 11;
     writetable(tableRespiratoryFeaturesSMISTep2,resultsFileName,'sheet',sheet)
         sheet = 12;
     writetable(tableRespiratoryFeaturesSMISTep3,resultsFileName,'sheet',sheet)
         sheet = 13;
     writetable(tableRespiratoryFeaturesSMISTep4,resultsFileName,'sheet',sheet)
         sheet = 14;
     writetable(tableRespiratoryFeaturesSMISTef,resultsFileName,'sheet',sheet)
         sheet = 15;
     writetable(tableRespiratoryFeaturesNC,resultsFileName,'sheet',sheet)

%% done