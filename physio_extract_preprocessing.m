%% Pipeline to interpolate and smooth respiration data

% DETERMINE PATHS TO DATA AND TO SAVING SPOTS attempt to do a function
% [commonPath, folderNames, dataFields, tmpFileNames, nFolders,...
%    nFiles] = path_to_data(VIBES, 1, 2); 

%% 
commonPath = fullfile('C:', 'Users', 'ouldbay', ...
    'breathmetrics', 'physio_extracted', 'respiration');
folderPattern = fullfile(commonPath, 'CID*');
folders = dir(folderPattern);

%% 0.0 Convert .resp file to .mat using siemens_RESPload2
% respDataFileName = fullfile(commonPath, "CID002\CID002_LGCMot_run3.resp");
% 
% rawSignal = load("CID002\CID002_LGCMot_run3.mat");
% figure; raw_hdl = plot(rawSignal.signal, 'Color', 'b');
% hold on
% 
% signalSmooth = load("CID002\s_f_CID002_LGCMot_run3.mat");
% sm_hdl = plot(signalSmooth.cleanedRespiData, 'Color', 'r');
% hold on
% 
% signal_band = load("CID002\f_CID002_LGCMot_run3.mat");
% filter_hdl = plot(signal_band.signalFiltered, 'Color', 'g');
% 


% slider(signal_band)
% 
% legend([raw_hdl, sm_hdl, filter_hdl],{ 'raw','smooth','bandpass'});
% legend('boxoff');


[signalCleaned, time] = clean_data(folders, commonPath, 'CID*.resp', [0.1 1], 50);



%% 1. Load data for analysis

for iFolders = 1:length(folders)
    folderPath = fullfile(commonPath, folders(iFolders).name);
    rootDir = fullfile(commonPath, folders(iFolders).name,'CID*.mat');
    fileNames = dir(rootDir);

    for iFiles = 1:length(fileNames)
        disp(fileNames(iFiles).name)
        respDataFileName = fileNames(iFiles).name;     
        data = load(strcat(folderPath,'\', respDataFileName)).signal;
        srate = 50; % srate is sampling rate in second (here 1000 samples per s)
        dataType = 'humanBB'; % data type for human respiration is either humanAirflow (nasal device) or humanBB (breathing belt)
        
        %% 2. Specifying which field in the struct is the respiration data
        
        respiratoryData = data;
        
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
            num2str(length(folders)), ', ', 'iFiles: ', num2str(iFiles), ...
            '/', num2str(length(fileNames))])
        

        %% 4. Interpolation on the de-noised data
        
        denoisedData= bmObj.smoothedRespiration';
        %%
%         try
%             [interpSmoothData, ~, NSat, NNaN, NInterp, sampleStatus] = interpol_1d_data_no_oversaturation(denoisedData, [0 3000], 0); % potential oversaturation >> interpol_1d_data_symetric_points; without oversaturation>> interpol_1d_data_no_oversaturation_peaks_window_length
%             disp(NSat);
%             disp(NNaN);
%             disp(NInterp);
%             interpSmoothData = interpSmoothData';
%             smoothingErrors{iFolders, iFiles} = 0;
% 
%         catch ME
%             %msg = ['error occured for participant ', fileNames(iFiles), ...
%             %    ', iFiles ', num2str(iFiles), '/', length(iFiles), 'in ', ...
%             %    'iFolders ', num2str(iFolders), '/', length(iFiles)];
%             %disp(msg);
%             %smoothingErrors{iFolders, iFiles} = [ME.message msg];
%             %interpSmoothData = denoisedData;
%             disp('ok')

%         end
        %% 5. Replace denoised data by denoised + interpolated data
        
        bmObj.smoothedRespiration = denoisedData; % interpSmoothData';

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
%             PLOT_LIMITS = 1:length(bmObj.rawRespiration);
%             figure; hold all;
%             
%             title(respDataFileName);
%             r=plot(bmObj.time(PLOT_LIMITS),bmObj.rawRespiration(PLOT_LIMITS),'k-');
%             sm=plot(bmObj.time(PLOT_LIMITS),bmObj.smoothedRespiration(PLOT_LIMITS),'b-');
%             bc=plot(bmObj.time(PLOT_LIMITS),bmObj.baselineCorrectedRespiration(PLOT_LIMITS),'r-');
%             legend([r,sm,bc],{'Raw Respiration';'Smoothed+interpolated Respiration';'Baseline Corrected Respiration'});
%             xlabel('Time (seconds)');
%             ylabel('Respiratory Flow');

        
        %% 7. save new data file
        
        % change file directory according to what is needed AND HOW YOU WANT TO NAME
        % YOUR FILE
        
        cleanedRespiData = bmObj.baselineCorrectedRespiration;
        saveFile = strcat(folderPath,'\s_', erase(respDataFileName, '_f'));
        save(saveFile, 'cleanedRespiData')
        
    end
end
% resultsDirERRORS = fullfile('C:', 'Users', 'ouldbay', ...
%     'breathmetrics', 'physio_extracted', 'respiration', 'WITHOUT OVERSATURATIONS'); % change from POTENTIAL OVERSATURATIONS to WITHOUT OVERSATURATIONS when needed
% save(strcat(resultsDirERRORS, filesep, 'smoothingErrors'), 'smoothingErrors');
% disp(['the error file has successfully been uploaded in ',...
%     'C: > Users > ouldbay > breathmetrics > physio_extracted > respiration > WITHOUT OVERSATURATIONS']);
%% done