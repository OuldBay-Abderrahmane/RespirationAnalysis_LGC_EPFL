%% Pipeline to interpolate and smooth respiration data

% DETERMINE PATHS TO DATA AND TO SAVING SPOTS attempt to do a function


%% -------------------- Cleaning the Data and saving it
% DETERMINE PATHS TO DATA 
commonPath = fullfile('C:', 'Users', 'ouldbay', ...
    'breathmetrics', 'physio_extracted', 'respiration');
folderPattern = fullfile(commonPath, 'CID*');
folders = dir(folderPattern);

commonPathBehavior = fullfile('C:', 'Users', 'ouldbay', ...
    'breathmetrics', 'behavior_extracted' );
folderPatternBehavior = fullfile(commonPath, 'CID*');
foldersBehavior = dir(folderPatternBehavior);

% SELECT FEATURES AND METABOLITS TO STUDY
behavior = load('behavioral_prm.mat').bayesian_mdl.mdl_3;
metabolits_file = load('MRS_data.mat');

features = {'BreathingRate'; 'MinuteVentilation'; 'AverageTidalVolume'};
metabolits = {'Tau'; 'GSH'; 'GABA'; 'Lac'};

% RUN THE CLEANING SAVE FUNCTIONS USING THE PATHS, FEATURES AND METABOLITS
[patients, subjectsTotalFeatures, metabolitsTable] = clean_store_data(folders, foldersBehavior, commonPath, commonPathBehavior, 'CID*.resp', ...
    [0.1 1], 50, behavior, metabolits_file,  metabolits, features);

% SAVING
save("study1AggregatedData.mat", "patients", "subjectsTotalFeatures", "metabolitsTable")
patients = load("study1AggregatedData.mat");


%% -------------------- Error Bar Effort Chosen depending on the task level

[breathingRatePhysicalHChoice1, breathingRatePhysicalLChoice1, ...
    breathingRatePhysicalHEffort1, breathingRatePhysicalLEffort1, ...
    breathingRateMentalHChoice1, breathingRateMentalLChoice1, ...
    breathingRateMentalHEffort1, breathingRateMentalLEffort1] = getBR(patients, 1);

[breathingRatePhysicalHChoice2, breathingRatePhysicalLChoice2, ...
    breathingRatePhysicalHEffort2, breathingRatePhysicalLEffort2, ...
    breathingRateMentalHChoice2, breathingRateMentalLChoice2, ...
    breathingRateMentalHEffort2, breathingRateMentalLEffort2]  = getBR(patients, 2);

[breathingRatePhysicalHChoice3, breathingRatePhysicalLChoice3, ...
    breathingRatePhysicalHEffort3, breathingRatePhysicalLEffort3, ...
    breathingRateMentalHChoice3, breathingRateMentalLChoice3, ...
    breathingRateMentalHEffort3, breathingRateMentalLEffort3]  = getBR(patients, 3);


%% -------------------- Plot Error Bar Effort Chosen depending on the task level -- YOU CAN GO FASTER BY USING CRTL+F and 
%% -------------------- changing Physical/Mental and Effort/Choice


physHMental = [nanmean(breathingRateMentalHChoice1); nanmean(breathingRateMentalHChoice2); nanmean(breathingRateMentalHChoice3)];
physLChoice = [nanmean(breathingRateMentalLChoice1); nanmean(breathingRateMentalLChoice2); nanmean(breathingRateMentalLChoice3)];

errPhysHChoice = [sem(breathingRateMentalHChoice1, 1); sem(breathingRateMentalHChoice2, 1); sem(breathingRateMentalHChoice3, 1)];
errPhysLChoice = [sem(breathingRateMentalLChoice1, 1); sem(breathingRateMentalLChoice2, 1); sem(breathingRateMentalLChoice3, 1)];

handleChoice = errorbar(physHChoice, errPhysHChoice);
hold on
handleChoice = errorbar(physLChoice',errPhysLChoice);
legend('High Effort Chosen', 'Low Effort Chosen')
xlabel("High Effort Level")
ylabel("Breathing Rate")
title("Mental Choice")


%% -------------------- Correlations Metabolits
[correlation, pvalE, th2]= corrplot([featureE studyE], 'varNames', {'BR', 'Tau'}); 
[pvalE] = correlationResp(patients.patients.patients, patients.metabolitsTable.Tau, , 'Ep', 'Tau', 'BR');
disp(pvalE)

%% -------------------- t-test 

[ betaPhysicalHEffort, betaPhysicalHChoice, betaPhysicalLEffort, betaPhysicalLChoice,  ...
    betaMentalHEffort, betaMentalHChoice, betaMentalLEffort, betaMentalLChoice ] = getBetas(patients);

disp(length(betaPhysicalHEffort));
disp(length(betaPhysicalLEffort));

[~,PhysHLEffort] = ttest(betaPhysicalHEffort, betaPhysicalLEffort);
[~,PhysHLChoice] = ttest(betaPhysicalHChoice, betaPhysicalLChoice);
[~,MentHLEffort] = ttest(betaMentalHEffort, betaMentalLEffort);
[~,MentHLChoice] = ttest(betaMentalHChoice, betaMentalLChoice);

pvals = [PhysHLEffort, PhysHLChoice, MentHLEffort, MentHLChoice];
disp(pvals)




%% -------------------- Predict level effort with brething rate 

 [tableBr] = getBrethingRate(patients);

idxm = strcmp(patients.patients.typeArray, "Em");
idxp = strcmp(patients.patients.typeArray, "Ep");
disp(idxm)
handlePhys = swarmchart(tableBr.effortMean(idxp), tableBr.effort(idxp));
hold on
handleMent= swarmchart(tableBr.effortMean(idxm), tableBr.effort(idxm));

xlim([0 3])
ylim([-1 2])
legend('Physical Effort', 'Mental Effort')
xlabel("Breathing Rate")
ylabel("Effort Level %")
title("Physical Effort")

a = load('CID001_LGCMot_run1.mat');
plot(a.signal)
hold on
a1 =load('s_CID001_LGCMot_run1.mat');
plot(a1.cleanedRespiData)
hold on
a2 =load('f_CID001_LGCMot_run1.mat');
plot(a2.signalFiltered)
hold on
legend('raw signal', 'smoothed signal', 'filtered signal')
xlabel("Time")
ylabel("Amplitude")
title("Comparison between smoothing (differentiation approach) and band pass filtering")