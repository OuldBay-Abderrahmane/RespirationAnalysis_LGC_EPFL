%% CORTISOL ANALYSIS PIPELINE (POST EXCEL CALCULATIONS)
%
%
%
%
%

%% LOAD DATA
% initialize server path
SERVERpath = fullfile('\\', 'svfas5.epfl.ch', 'Sandi-Lab', 'Catherine');
% SERVERpath = fullfile('M:', 'Catherine');
% initialize experiment's analysis path
XPpath = fullfile(SERVERpath, 'XP VIBES', 'STUDY 1', 'ANALYSIS');
% intitiaize cort path
CORTpath = fullfile(XPpath, 'RESULTS', 'VARIABLES','XLSX');
% load xlsx table
excelReadTable = readtable([CORTpath, filesep, 'Cortisol_full_results_visit1.xlsx'],...
    'Sheet','cortisol_visit1');

%% EXTRACT DATA
% CORT_data: structure with cortisol data with the following subfields:
%   .ID: vector > subject identification number (NS subjects in total)
%   .sex: vector > subject gender (important because of the hormones levels)
%   .CORTraw: matrix > all samples values for each subject
%   .CORTcorrected: matrix > all samples values for each subject
%   .timings: matrix > all samples timepoints for each subject
%   .samplesInterval: matrix > interval between samples, unit = minutes
%
%   .AUCg_raw_A0-S40: vector > area under the curve with respect to the 
%    ground based on all raw samples 
%   .AUCg_raw_A10-S40: vector >  area under the curve with respect to the 
%    ground based on the raw samples from A10 to S40 (not sure useful)
%   .AUCg_corrected_A0-S40: vector > area under the curve with respect to the
%    ground based on all corrected samples
%   .AUCg_corrected_A10-S40: vector > area under the curve with respect to the 
%    ground based on the corrected samples from A10 to S40 (not sure useful)
%
%   .AUCi_raw_A10-S40: vector > area under the cruve with respect to the
%    increase based on the raw samples from A10 to S10
%   .AUCi_corrected_A10-S10: vector > area under the cruve with respect to
%   the increase based on the corrected samples from A10 to S10
%
%   .AUCcorr_raw_S0-S40: vector > area under the cruve corrected (S0
%   becomes new origin, area is calculated accordingly) based on the raw
%   samples from S0 to S40
%   .AUCcorr_corrected_S0-S40: vector > area under the curve corrected
%   based on the the corrected samples from S0 to S40 (values should be 
%   similar to those in vector .AUCcorr_raw_S0-S40)

CORT_data.ID = excelReadTable.Participant_ID';
CORT_data.sex = excelReadTable.Sex';
CORT_data.CORTraw = [excelReadTable.A0';...
    excelReadTable.A10';...
    excelReadTable.S0';...
    excelReadTable.S10';...
    excelReadTable.S20';...
    excelReadTable.S30';...
    excelReadTable.S40'];
CORT_data.CORTcorrected = [excelReadTable.A0corrected';...
    excelReadTable.A10corrected';...
    excelReadTable.S0corrected';...
    excelReadTable.S10corrected';...
    excelReadTable.S20corrected';...
    excelReadTable.S30corrected';...
    excelReadTable.S40corrected'];
CORT_data.timings = [excelReadTable.A0_Timing';...
    excelReadTable.A10_Timing';...
    excelReadTable.S0_Timing';...
    excelReadTable.S10_Timing';...
    excelReadTable.S20_Timing';...
    excelReadTable.S30_Timing';...
    excelReadTable.S40_Timing'].*24; % store timings in hours
CORT_data.samplesInterval = [excelReadTable.A0_distance_between_measurements';...
    excelReadTable.A10_distance_between_measurements';...
    excelReadTable.S0_distance_between_measurements';...
    excelReadTable.S10_distance_between_measurements';...
    excelReadTable.S20_distance_between_measurements';...
    excelReadTable.S30_distance_between_measurements';...
    excelReadTable.S40_distance_between_measurements'];
 CORT_data.AUCg_raw_A0S40 = excelReadTable.AUCg_not_corrected_all_samples';
 CORT_data.AUCg_raw_A10S40 = excelReadTable.AUCg_not_corrected_A10S40';
 CORT_data.AUCg_corrected_A0S40 = excelReadTable.AUCg_corrected_all_samples';
 CORT_data.AUCg_corrected_A10S40 = excelReadTable.AUCg_corrected_A10S40';
 CORT_data.AUCi_raw_A10S10 = excelReadTable.AUCi_not_corrected_A10S10';
 CORT_data.AUCi_corrected_A10S10 = excelReadTable.AUCi_corrected_A10S10';
 CORT_data.AUCcorr_raw_S0S40 = excelReadTable.AUCcorr_not_corrected_S0S40';
 CORT_data.AUCcorr_corrected_S0S40 = excelReadTable.AUCcorr_corrected_S0S40';

%% mean variables 
CORT_data.ID;

%% means
[mCort, semCORT] = mean_sem_sd(CORT_data.CORTraw,2);
[mTime, semTime] = mean_sem_sd(CORT_data.timings,2);

[n_mCort, n_semCORT] = mean_sem_sd(CORT_data.CORTcorrected,2);
[mTime, semTime] = mean_sem_sd(CORT_data.timings,2);

%% plot not normalized

lWidth = 3;
pSize = 30;

figure;
hdl = errorbar(mTime, mCort, semCORT, semCORT, semTime, semTime);
hdl.LineWidth = lWidth;
hdl.LineStyle = ':';
hdl.Color = 'k';
xlabel('Time of the day (hours)');
ylabel('CORTISOL (µg/dL)');
legend_size(pSize);

%% plot normalized
lWidth = 3;
pSize = 30;

figure;
hdl = errorbar(mTime, n_mCort, n_semCORT, n_semCORT, semTime, semTime);
hdl.LineWidth = lWidth;
hdl.LineStyle = ':';
hdl.Color = 'k';
xlabel('Time of the day (hours)');
ylabel('CORTISOL (a.u.)');
legend_size(pSize);
