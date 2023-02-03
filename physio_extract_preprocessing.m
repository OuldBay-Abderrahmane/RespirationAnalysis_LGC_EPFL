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


clean_data(folders, commonPath, 'CID*.resp', [0.1 1], 50);

signal = load("CID001\c_CID001_LGCMot_run1.mat");
signalCleaned = signal.signalCleaned;


bmObj = breathmetrics_modif(signalCleaned, 50, 'humanBB');

bmObj.baselineCorrectedRespiration = signalCleaned';
bmObj = findExtrema(bmObj);

plotFeatures(bmObj, 'extrema', 3);
run = runs_definition('study1', '001', 'fMRI_noSatTask');

