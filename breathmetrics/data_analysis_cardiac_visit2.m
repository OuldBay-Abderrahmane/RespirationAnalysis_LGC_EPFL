%% HR AND HRV DATA ANALYSIS PIPELINE

%% 1. Load data for anylsis

commonPath = fullfile('M:', 'Catherine', 'XP VIBES', 'STUDY 1', 'ANALYSIS', ...
    'CLEAN', 'PHYSIO', 'CUTDATA', 'V2');
folderNames = {'1 BASELINE EYES CLOSED', '2 BASELINE EYES OPENED', ...
    '3 ANXIETY OPEN FIELD', '4 ANXIETY ELEVATED PLATFORM WAY UP', ...
    '5 ANXIETY ELEVATED PLATFORM TOP', '6 ANXIETY ELEVATED PLATFORM WAY DOWN', ...
    '7 ANXIETY ELEVATED PLATFORM FULL', '8 ANXIETY DARK MAZE', ...
    '9 STRESS MIST TRAINING', '10 STRESS MIST EXPERIMENT PHASE 1' ...
    '11 STRESS MIST EXPERIMENT PHASE 2', '12 STRESS MIST EXPERIMENT PHASE 3', ...
    '13 STRESS MIST EXPERIMENT PHASE 4', '14 STRESS MIST EXPERIMENT FULL', ...
    '15 NEUTRAL CONTROL'};
dataField = {'eyesClosedBaseline', 'eyesOpenedBaseline', 'anxietyOpenField', ...
    'anxietyElevatedPlatformWUP', 'anxietyElevatedPlatformTOP', ...
    'anxietyElevatedPlatformWDN', 'anxietyElevatedPlatformFULL', ...
    'anxietyDarkMaze', 'stressMISTtraining', 'stressMISTexperimentPHASE1', ...
    'stressMISTexperimentPHASE2', 'stressMISTexperimentPHASE3', ...
    'stressMISTexperimentPHASE4', 'stressMISTexperimentFULL', ...
    'neutralControl'};

resultsDataField = {'a_eyesClosedBaseline', 'a_eyesOpenedBaseline', 'a_anxietyOpenField', ...
    'a_anxietyElevatedPlatformWUP', 'a_anxietyElevatedPlatformTOP', ...
    'a_anxietyElevatedPlatformWDN', 'a_anxietyElevatedPlatformFULL', ...
    'a_anxietyDarkMaze', 'a_stressMISTtraining', 'a_stressMISTexperimentPHASE1', ...
    'a_stressMISTexperimentPHASE2', 'a_stressMISTexperimentPHASE3', ...
    'a_stressMISTexperimentPHASE4', 'a_stressMISTexperimentFULL', ...
    'a_neutralControl'};
resultsDir = fullfile('M:', 'Catherine', 'XP VIBES', 'STUDY 1', ...
     'ANALYSIS', 'RESULTS', 'VARIABLES');
resultsFileName = 'Cardiac_features_visit2.xlsx';

cardiacFeaturesStruct = [];

for iFolders = 1:length(folderNames)
    rootDir = [commonPath, filesep, folderNames{iFolders}];
    fileNames = ls([rootDir,filesep,'V*.mat']);
        
    for iFiles = 1:length(fileNames)
        cardiacDataFileName = fileNames(iFiles,:);
        
        % if you have your own data, type the path to it into rootDir and the name
        % of the file in cardiacDataFileName
        
        dataStruct = load(fullfile(rootDir,cardiacDataFileName));
        srate = 1000;
        global phase
        phase = iFolders;
        %% 2. specifying the field and the column in the struct 
        
        selectField = fieldnames(dataStruct);
        dataStructField = dataStruct.(selectField{1});
        cardiacData = dataStructField(:,3);
%         mirror = 0;
        
        %% 2.5 mirroring signal for elevated platform wdn
%         if length(cardiacData) < 15000
%             cardiacData = [cardiacData; cardiacData(end:(-1):1)];
%             mirror = 1;
%         end
        %% 3. participant identification
        
        split = strsplit(cardiacDataFileName,'_');
        participantID = split{1};
    
        %% 4. initialize features for analysis
            
            addpath(genpath('C:\Program Files\MATLAB\R2020b\toolbox\PhysioNet-Cardiovascular-Signal-Toolbox-master'));

            try
            HRVout = data_analysis_cardiac_features(cardiacData,[],'ECGWaveform',data_analysis_cardiac_features_initialization('VIBES_study1'));
                catch ME
            rmpath(genpath('PhysioNet-Cardiovascular-Signal-Toolbox-master'));
            warning(['Problem in subject ', participantID, ME.message])
                continue;
            end
            rmpath(genpath('C:\Program Files\MATLAB\R2020b\toolbox\PhysioNet-Cardiovascular-Signal-Toolbox-master'));
            
        %% 5. computation of local HRV measures

        addpath(genpath('C:\Program Files\MATLAB\R2020b\toolbox\MarcusVollmer-HRV-58badf9'));
        RR_loc = HRVout.NN;

        rrHRV = HRV.rrHRV(RR_loc);

        HR    = HRV.HR(RR_loc);
        [TRI,TINN] = HRV.triangular_val(RR_loc);
        rmpath(genpath('C:\Program Files\MATLAB\R2020b\toolbox\MarcusVollmer-HRV-58badf9'));

        cardiacFeaturesStruct.(resultsDataField{iFolders}).participantID(iFiles, 1) = convertCharsToStrings(participantID);

        cardiacFeaturesStruct.(resultsDataField{iFolders}).('HR')(iFiles, 2) = HR;
        cardiacFeaturesStruct.(resultsDataField{iFolders}).(HRVout.HRVtitle{10})(iFiles, 3) = HRVout.HRVout(10);
        cardiacFeaturesStruct.(resultsDataField{iFolders}).(HRVout.HRVtitle{11})(iFiles, 4) = HRVout.HRVout(11);
        cardiacFeaturesStruct.(resultsDataField{iFolders}).(HRVout.HRVtitle{12})(iFiles, 5) = HRVout.HRVout(12);
        cardiacFeaturesStruct.(resultsDataField{iFolders}).(HRVout.HRVtitle{16})(iFiles, 6) = HRVout.HRVout(16);
        cardiacFeaturesStruct.(resultsDataField{iFolders}).(HRVout.HRVtitle{17})(iFiles, 7) = HRVout.HRVout(17);
        cardiacFeaturesStruct.(resultsDataField{iFolders}).(HRVout.HRVtitle{18})(iFiles, 8) = HRVout.HRVout(18);
        cardiacFeaturesStruct.(resultsDataField{iFolders}).(HRVout.HRVtitle{19})(iFiles, 9) = HRVout.HRVout(19);
        cardiacFeaturesStruct.(resultsDataField{iFolders}).(HRVout.HRVtitle{20})(iFiles, 10) = HRVout.HRVout(20);
        cardiacFeaturesStruct.(resultsDataField{iFolders}).(HRVout.HRVtitle{21})(iFiles, 11) = HRVout.HRVout(21);
        cardiacFeaturesStruct.(resultsDataField{iFolders}).(HRVout.HRVtitle{23})(iFiles, 12) = HRVout.HRVout(23);
        cardiacFeaturesStruct.(resultsDataField{iFolders}).(HRVout.HRVtitle{24})(iFiles, 13) = HRVout.HRVout(24);
        cardiacFeaturesStruct.(resultsDataField{iFolders}).(HRVout.HRVtitle{25})(iFiles, 14) = HRVout.HRVout(25);
        cardiacFeaturesStruct.(resultsDataField{iFolders}).(HRVout.HRVtitle{26})(iFiles, 15) = HRVout.HRVout(26);
        cardiacFeaturesStruct.(resultsDataField{iFolders}).(HRVout.HRVtitle{27})(iFiles, 16) = HRVout.HRVout(27);
        cardiacFeaturesStruct.(resultsDataField{iFolders}).(HRVout.HRVtitle{28})(iFiles, 17) = HRVout.HRVout(28);
        cardiacFeaturesStruct.(resultsDataField{iFolders}).(HRVout.HRVtitle{29})(iFiles, 18) = HRVout.HRVout(29);
        cardiacFeaturesStruct.(resultsDataField{iFolders}).('TRI')(iFiles, 19) = TRI;
        cardiacFeaturesStruct.(resultsDataField{iFolders}).('TINN')(iFiles, 20) = TINN;
        cardiacFeaturesStruct.(resultsDataField{iFolders}).('rrHRV')(iFiles, 21) = rrHRV;  

        %assert(false)
     
    end
end
%% save data into an xlsx file with separated sheets per condition
 
     tableCardiacFeaturesECB = struct2table(cardiacFeaturesStruct.(resultsDataField{1}));
     tableCardiacFeaturesEOB = struct2table(cardiacFeaturesStruct.(resultsDataField{2}));
     tableCardiacFeaturesAOF = struct2table(cardiacFeaturesStruct.(resultsDataField{3}));
     tableCardiacFeaturesAEPwup = struct2table(cardiacFeaturesStruct.(resultsDataField{4}));
     tableCardiacFeaturesAEPtop = struct2table(cardiacFeaturesStruct.(resultsDataField{5}));
     tableCardiacFeaturesAEPwdn = struct2table(cardiacFeaturesStruct.(resultsDataField{6}));
     tableCardiacFeaturesAEPf = struct2table(cardiacFeaturesStruct.(resultsDataField{7}));
     tableCardiacFeaturesADM = struct2table(cardiacFeaturesStruct.(resultsDataField{8}));
     tableCardiacFeaturesSMISTt = struct2table(cardiacFeaturesStruct.(resultsDataField{9}));
     tableCardiacFeaturesSMISTep1 = struct2table(cardiacFeaturesStruct.(resultsDataField{10}));
     tableCardiacFeaturesSMISTep2 = struct2table(cardiacFeaturesStruct.(resultsDataField{11}));
     tableCardiacFeaturesSMISTep3 = struct2table(cardiacFeaturesStruct.(resultsDataField{12}));
     tableCardiacFeaturesSMISTep4 = struct2table(cardiacFeaturesStruct.(resultsDataField{13}));
     tableCardiacFeaturesSMISTef = struct2table(cardiacFeaturesStruct.(resultsDataField{14}));
     tableCardiacFeaturesNC = struct2table(cardiacFeaturesStruct.(resultsDataField{15}));
     
         sheet = 1;
     writetable(tableCardiacFeaturesECB,resultsFileName,'sheet',sheet)
         sheet = 2;
     writetable(tableCardiacFeaturesEOB,resultsFileName,'sheet',sheet)
         sheet = 3;
     writetable(tableCardiacFeaturesAOF,resultsFileName,'sheet',sheet)
         sheet = 4;
     writetable(tableCardiacFeaturesAEPwup,resultsFileName,'sheet',sheet)
         sheet = 5;
     writetable(tableCardiacFeaturesAEPtop,resultsFileName,'sheet',sheet)
         sheet = 6;
     writetable(tableCardiacFeaturesAEPwdn,resultsFileName,'sheet',sheet)
         sheet = 7;
     writetable(tableCardiacFeaturesAEPf,resultsFileName,'sheet',sheet)
         sheet = 8;
     writetable(tableCardiacFeaturesADM,resultsFileName,'sheet',sheet)
         sheet = 9;
     writetable(tableCardiacFeaturesSMISTt,resultsFileName,'sheet',sheet)
         sheet = 10;
     writetable(tableCardiacFeaturesSMISTep1,resultsFileName,'sheet',sheet)
         sheet = 11;
     writetable(tableCardiacFeaturesSMISTep2,resultsFileName,'sheet',sheet)
         sheet = 12;
     writetable(tableCardiacFeaturesSMISTep3,resultsFileName,'sheet',sheet)
         sheet = 13;
     writetable(tableCardiacFeaturesSMISTep4,resultsFileName,'sheet',sheet)
         sheet = 14;
     writetable(tableCardiacFeaturesSMISTef,resultsFileName,'sheet',sheet)
         sheet = 15;
     writetable(tableCardiacFeaturesNC,resultsFileName,'sheet',sheet)
     

% if fileNames(iFiles) != 'V043'
