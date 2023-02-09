%% Pipeline to interpolate and smooth respiration data

% DETERMINE PATHS TO DATA AND TO SAVING SPOTS attempt to do a function
% [commonPath, folderNames, dataFields, tmpFileNames, nFolders,...
%    nFiles] = path_to_data(VIBES, 1, 2); 

%% 
commonPath = fullfile('C:', 'Users', 'ouldbay', ...
    'breathmetrics', 'physio_extracted', 'respiration');
folderPattern = fullfile(commonPath, 'CID*');
folders = dir(folderPattern);

behavior = load('behavioral_prm.mat').bayesian_mdl.mdl_3;
metabolits_file = load('MRS_data.mat');

features = {'BreathingRate'; 'MinuteVentilation'; 'AverageTidalVolume'};
metabolits = {'Tau'; 'GSH'; 'GABA'; 'Lac'};


[patients, featuresTable, metabolitsTable] = clean_store_data(folders, commonPath, 'CID*.resp', ...
    [0.1 1], 50, behavior, metabolits_file,  metabolits, features);


save("study1AggregatedData.mat", "patients", "featuresTable", "metabolitsTable")
patients = load("study1AggregatedData.mat");



%% -------------------- Correlations

[pvalues, h1, h2] = correlationResp(patients.patients, patients.metabolitsTable.Tau, ...
    patients.featuresTable.BreathingRate, 'Tau', 'BR');



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

