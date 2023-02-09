%% Pipeline to interpolate and smooth respiration data

% DETERMINE PATHS TO DATA AND TO SAVING SPOTS attempt to do a function
% [commonPath, folderNames, dataFields, tmpFileNames, nFolders,...
%    nFiles] = path_to_data(VIBES, 1, 2); 

commonPath = fullfile('\\', 'svfas5.epfl.ch', 'Sandi-Lab', 'Catherine', ...
    'XP VIBES', 'STUDY 1', 'ANALYSIS', 'CLEAN', 'PHYSIO', 'CUTDATA', 'V2');
folderNames = {'1 BASELINE EYES CLOSED', '2 BASELINE EYES OPENED', ...
    '3 ANXIETY OPEN FIELD', '4 ANXIETY ELEVATED PLATFORM WAY UP', ...
    '5 ANXIETY ELEVATED PLATFORM TOP', '6 ANXIETY ELEVATED PLATFORM WAY DOWN', ...
    '7 ANXIETY ELEVATED PLATFORM FULL', '8 ANXIETY DARK MAZE', ...
    '9 STRESS MIST TRAINING', '10 STRESS MIST EXPERIMENT PHASE 1', ...
    '11 STRESS MIST EXPERIMENT PHASE 2', '12 STRESS MIST EXPERIMENT PHASE 3', ...
    '13 STRESS MIST EXPERIMENT PHASE 4', '14 STRESS MIST EXPERIMENT FULL', ...
    '15 NEUTRAL CONTROL'};
dataFields = {'eyesClosedBaseline', 'eyesOpenedBaseline', 'anxietyOpenField', ...
    'anxietyElevatedPlatformWUP', 'anxietyElevatedPlatformTOP', ...
    'anxietyElevatedPlatformWDN', 'anxietyElevatedPlatformFULL', ... 
    'anxietyDarkMaze', 'stressMISTtraining', 'stressMISTexperimentPHASE1', ...
    'stressMISTexperimentPHASE2', 'stressMISTexperimentPHASE3', ...
    'stressMISTexperimentPHASE4', 'stressMISTexperimentFULL', 'neutralControl'};
tmpFileNames = ls([commonPath,filesep,folderNames{1},'V*.mat']);

nFolders = length(folderNames);
nFiles = length(tmpFileNames);
smoothingErrors = cell(nFolders, nFiles);

%% 1. Load data for analysis
for iFolders = 1:length(folderNames)
    rootDir = [commonPath, filesep, folderNames{iFolders}];
    resultsDir = fullfile('\\', 'svfas5.epfl.ch', 'Sandi-Lab', ...
        'Catherine','XP VIBES','STUDY 1', 'ANALYSIS','CLEAN','PHYSIO', ...
        'RESPIRATION', 'V2', 'WITHOUT OVERSATURATIONS', folderNames{iFolders}); % CHANGE POTENTIAL OVERSATURATIONS TO WITHOUT OVERSATURATIONS WHEN DONE WITH THE FORMER VERSION OF THE INTERP FUNCTION
    fileNames = ls([rootDir,filesep,'V*.mat']);
    
    for iFiles = 1:length(fileNames)
        respDataFileName = fileNames(iFiles,:);
        
        % if you have your own data, type the path to it into rootDir and the name
        % of the file in respDataFileName
        
        dataStruct = load(fullfile(rootDir,respDataFileName));
        srate = 1000; % srate is sampling rate in second (here 1000 samples per s)
        dataType = 'humanBB'; % data type for human respiration is either humanAirflow (nasal device) or humanBB (breathing belt)
        
        %% 2. Specifying which field in the struct is the respiration data
        
        firstField = fieldnames(dataStruct);
        dataStructField = dataStruct.(firstField{1});
        respiratoryData = dataStructField(:,1);
        
        %% 3. Initializing the breathmetrics class & de-noising data.
        
        bmObj = breathmetrics_modif(respiratoryData, srate, dataType);
        
        % bmObj is now a class object with many properites, most will be empty at
        % this point.
        
        % Call bmObj to see its properties
        
        % rawRespiration is the raw vector of respiratory data.
        
        % smoothedRespiration is that vector mean smoothed by 50 ms window. This
        % is not fully baseline corrected yet.
        
        % srate is your sampling rate
        
        % time is a 1xN vector where each point represents where each sample in the
        % other fields occur in real time.
        
        disp(['Current file being processed: ', respDataFileName])
        disp(['Location: ', 'iFolders: ', num2str(iFolders), '/',...
            num2str(length(folderNames)), ', ', 'iFiles: ', num2str(iFiles), ...
            '/', num2str(length(fileNames))])
        
        %% 4. Interpolation on the de-noised data
        
        denoisedData= bmObj.smoothedRespiration';

        try
            [interpSmoothData, ~, NSat, NNaN, NInterp] = interpol_1d_data_no_oversaturation(denoisedData, [-4.89 1.92], 0); % potential oversaturation >> interpol_1d_data_symetric_points; without oversaturation>> interpol_1d_data_no_oversaturation_peaks_window_length
            disp(NSat);
            disp(NNaN);
            disp(NInterp);
            interpSmoothData = interpSmoothData';
            smoothingErrors{iFolders, iFiles} = 0;

        catch ME
            msg = ['error occured for participant ', fileNames(iFiles), ...
                ', iFiles ', num2str(iFiles), '/', length(iFiles), 'in ', ...
                'iFolders ', num2str(iFolders), '/', length(iFiles)];
            disp(msg);
            smoothingErrors{iFolders, iFiles} = [ME.message msg];
            interpSmoothData = denoisedData;

        end
        
        %% 5. Replace denoised data by denoised + interpolated data
        
        bmObj.smoothedRespiration = interpSmoothData;
        
        %% 6. Baseline correcting the smoothed and interpolated signal
        
        % verbose prints out steps as they go. Set to 0 to silence.
        verbose=1;
        
        % there are two methods for baseline correcting your respiratory data:
        % * average over a sliding window
        % * average over the mean and set to zero
        
        % The sliding window is the most accurate method but takes slightly longer
        baselineCorrectionMethod = 'sliding';
        % baselineCorrectionMethod can be set to 'simple' to set the baseline as
        % the mean. It is a fraction less accurate but far faster.
        % baselineCorrectionMethod = 'simple';
        
        % the default baseline correction method is 'sliding'.
        
        
        % zScore (0 or 1).
        % if zScore is set to 1, the amplitude in the recording will be normalized.
        % z-scoring can be helpful for comparing certain features for
        % between-subject analyzes.
        % the default value is 0
        
        zScore=0;   % we don't particularly need to zscore our data since 
                    % are already on the same scale.
        
        bmObj.correctRespirationToBaseline(baselineCorrectionMethod, zScore, verbose);
        
        
        %plot data
%           PLOT_LIMITS = 1:length(bmObj.rawRespiration);
%           figure; hold all;
%           
%           title(respDataFileName);
%           r=plot(bmObj.time(PLOT_LIMITS),bmObj.rawRespiration(PLOT_LIMITS),'k-');
%           sm=plot(bmObj.time(PLOT_LIMITS),bmObj.smoothedRespiration(PLOT_LIMITS),'b-');
%           bc=plot(bmObj.time(PLOT_LIMITS),bmObj.baselineCorrectedRespiration(PLOT_LIMITS),'r-');
%           legend([r,sm,bc],{'Raw Respiration';'Smoothed+interpolated Respiration';'Baseline Corrected Respiration'});
%           xlabel('Time (seconds)');
%           ylabel('Respiratory Flow');

        
        %% 7. save new data file
        
        % change file directory according to what is needed AND HOW YOU WANT TO NAME
        % YOUR FILE
        
        cleanedRespiData = bmObj.baselineCorrectedRespiration;
        
        save([resultsDir,filesep,'s_',respDataFileName],...
            'cleanedRespiData');
        
    end
end
resultsDirERRORS = fullfile('\\', 'svfas5.epfl.ch', 'Sandi-Lab', ...
    'Catherine','XP VIBES','STUDY 1', 'ANALYSIS','CLEAN','PHYSIO', ...
    'RESPIRATION', 'V2', 'WITHOUT OVERSATURATIONS'); % change from POTENTIAL OVERSATURATIONS to WITHOUT OVERSATURATIONS when needed
save(strcat(resultsDirERRORS, filesep, 'smoothingErrors'), 'smoothingErrors');
disp(['the error file has successfully been uploaded in ',...
    'Catherine > XP VIBES > STUDY 1 > ANALYSIS > CLEAN > PHYSIO > RESPIRATION > V2 > WITHOUT OVERSATURATIONS']);
%% done