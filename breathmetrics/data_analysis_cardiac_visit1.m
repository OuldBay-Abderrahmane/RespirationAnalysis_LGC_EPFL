%% HR AND HRV DATA ANALYSIS PIPELINE

%% 1. Load data for anylsis

commonPath = fullfile('M:', 'Catherine', 'XP VIBES', 'STUDY 1', 'ANALYSIS', ...
    'CLEAN', 'PHYSIO', 'CUTDATA', 'V1');
folderNames = {'ANTICIPATION', 'BASELINE EYES CLOSED', 'BASELINE EYES OPENED', 'TASK TSST'};
dataField = {'anticipationTSST', 'eyesClosedBaseline', 'eyesOpenedBaseline', 'taskTSST'};

resultsDataField = {'a_anticipationTSST', 'a_baselineEyesClosed', 'a_baselineEyesOpened', 'a_taskTSST'};
resultsDir = fullfile('M:', 'Catherine', 'XP VIBES', 'STUDY 1', ...
     'ANALYSIS', 'RESULTS', 'VARIABLES');
resultsFileName = 'Cardiac_features.xlsx';

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
        
        %% 2. specifying the field and the column in the struct 
        
        selectField = fieldnames(dataStruct);
        dataStructField = dataStruct.(selectField{1});
        cardiacData = dataStructField(:,3);

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
 
     tableCardiacFeaturesAnticipationTSST = struct2table(cardiacFeaturesStruct.(resultsDataField{1}));
     tableCardiacFeaturesBaselineEyesClosed = struct2table(cardiacFeaturesStruct.(resultsDataField{2}));
     tableCardiacFeaturesBaselineEyesOpened = struct2table(cardiacFeaturesStruct.(resultsDataField{3}));
     tableCardiacFeaturesTaskTSST = struct2table(cardiacFeaturesStruct.(resultsDataField{4}));
     
         sheet = 1;
     writetable(tableCardiacFeaturesAnticipationTSST,resultsFileName,'sheet',sheet)
         sheet = 2;
     writetable(tableCardiacFeaturesBaselineEyesClosed,resultsFileName,'sheet',sheet)
         sheet = 3;
     writetable(tableCardiacFeaturesBaselineEyesOpened,resultsFileName,'sheet',sheet)
         sheet = 4;
     writetable(tableCardiacFeaturesTaskTSST,resultsFileName,'sheet',sheet)% % %% done

% if fileNames(iFiles) != 'V043'
