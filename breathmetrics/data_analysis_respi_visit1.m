%% RESPI DATA ANALYSIS PIPELINE

%% 1. load data for analysis
commonPath = fullfile('M:', 'Catherine', 'XP VIBES', 'STUDY 1',...
    'ANALYSIS', 'CLEAN', 'PHYSIO', 'RESPIRATION', 'V1', 'WITHOUT OVERSATURATIONS');
folderNames = {'1 BASELINE EYES CLOSED', '2 BASELINE EYES OPENED', '3 ANTICIPATION'};
dataField = {'cleanedRespiData'};

resultsDataField = {'a_baselineEyesClosed', 'a_baselineEyesOpened', ...
     'a_anticipationTSST'};
resultsDir = fullfile('M:', 'Catherine', 'XP VIBES', 'STUDY 1', ...
     'ANALYSIS', 'RESULTS', 'VARIABLES');
resultsFileName = 'Respiratory_features_visit1.xlsx';

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
        secondField = fieldnames(dataStruct);
        dataStructField2 = dataStruct.(secondField{2});
        sampleStatus = dataStructField2(:,1);

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

    tableRespiratoryFeaturesBaselineEyesClosed = struct2table(respiFeaturesStruct.(resultsDataField{1}));
    tableRespiratoryFeaturesBaselineEyesOpened = struct2table(respiFeaturesStruct.(resultsDataField{2}));
    tableRespiratoryFeaturesAnticipationTSST = struct2table(respiFeaturesStruct.(resultsDataField{3}));

        sheet = 1;
    writetable(tableRespiratoryFeaturesBaselineEyesClosed,resultsFileName,'sheet',sheet)
        sheet = 2;
    writetable(tableRespiratoryFeaturesBaselineEyesOpened,resultsFileName,'sheet',sheet)
        sheet = 3;
    writetable(tableRespiratoryFeaturesAnticipationTSST,resultsFileName,'sheet',sheet)

%% done