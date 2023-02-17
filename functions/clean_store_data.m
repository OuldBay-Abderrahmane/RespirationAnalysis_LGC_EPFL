function [patients, subjectsTotalFeatures, metabolitsTable] = ...
    clean_store_data(folders, foldersBehaviors, commonPath, commonPathBehavior, filePattern, filterBand, ...
    freq, behavior, metabolits_file, metabolits, features)

    % [patients, subjectsTotalFeatures, metabolitsTable] = ...
    %   clean_store_data(folders, foldersBehaviors, commonPath, commonPathBehavior, filePattern, filterBand, ...
    %   freq, behavior, metabolits_file, metabolits, features)
    % Give all tables and features of all subjects
    % 
    % INPUT :
    % - folders: folders for resp data directory list ex: dir(fullfile(commonPath, 'CID*')) 
    % - foldersBehaviors: folders for resp data directory list ex: dir(fullfile(commonPath, 'CID*')) 
    % - commonPath : path to resp experiment folders
    % - commonPathBehavior: path to behavior experiment folders 
    % - filePattern: regex pattern of the file we extract ex: 'CID*.resp'
    % - filterBand : filter band ex : [0.1 1]
    % - freq : sampling rate
    % - behavior: file of the behaviors
    % - metabolits_file: file of the metabolits measures
    % - metabolits : array of metabolits to study
    % - features : array of features to study
    %
    % OUTPUT :
    % patients: oragnized table of patients basics measures 
    % subjectsTotalFeatures : array of features for each run
    % metabolitsTable : table of metabolits measures
    % 
    % Developed by Abderrahmane Ould Bay - 15/02/2023

    %% Initializations
    % File naming structure to get the run number
    expressionRun = 'n[0-9]*';

    [subjectNumberArray, runNumberArray, ...
        typeArray, kEm, kEp] = deal([], [], [], [], []);

    metabolits_save = {};
    metabolits_save{1, length(metabolits)} = [];

    subjectsTotalFeatures = [];
    
    %% Looping on all folders and files to get our measurments
    for iFolders = 1:length(folders)
        rootDir = fullfile(commonPath, folders(iFolders).name, filePattern);
        folderPath = fullfile(commonPath, folders(iFolders).name);
        fileNames = dir(rootDir);
        subjectNumber = erase(folders(iFolders).name, 'CID');

        rootDirBehavior = fullfile(commonPathBehavior, foldersBehaviors(iFolders).name, 'CID*_task.mat');
        folderPathBehavior = fullfile(commonPathBehavior, foldersBehaviors(iFolders).name);
        fileNamesBehavior = dir(rootDirBehavior);

        %% Verify if the measures are in both matabolits and behavior, if a subject only has one measure we discard it
        if ismember(subjectNumber, behavior.subject_id) && ismember(subjectNumber, metabolits_file.subject_id)
            indexE = find(strcmp(cellstr(subjectNumber), behavior.subject_id));
            indexdmPFC = find(strcmp(cellstr(subjectNumber), metabolits_file.subject_id));

            run = runs_definition('study1', subjectNumber, 'respiration_and_noSatRun');   

            for iFiles = 1:length(fileNames)
                %% Regex manipulation to keep the subject number
                runNumber = erase(regexp( fileNames(iFiles).name, expressionRun,'match'), 'n');
                runNumber = str2double(runNumber{1});
                
                behaviorFiles =  strjoin(split([fileNamesBehavior.name],'.mat'), '.mat ') ;
                behaviorFile = regexp(behaviorFiles, strcat('\w*n', num2str(runNumber), '\w*.mat') ,'match');

                %% Verify if the run is in the run_definitions file
                if ismember(runNumber, run.runsToKeep) 
                    [signalFiltered, time, start] = filterSignal(folderPath, fileNames(iFiles).name, filterBand, freq);
                    [signalCleaned, signal_binary] = slider(signalFiltered, time, 300, fileNames(iFiles).name);
                    
                    if sum(signal_binary)/length(signal_binary) > 0.5
                        for i = 1:length(metabolits)
                            metabolits_save{1, i} = [metabolits_save{1, i} getMetabolit(metabolits_file, metabolits{i}, indexdmPFC)];
                        end
                        
                        %% Initialization of the time after cleaning and putting it to the T0
                        newTime = 0:1/freq:time(length(signalCleaned))- time(start);
                        newTime = newTime( newTime>=0 );
                        removeFirst = length(signalCleaned)-length(newTime);
                        signalCleaned = signalCleaned(removeFirst:end);
                        
                        %% Saving the subject information
                        subjectNumberArray = [subjectNumberArray; subjectNumber];
                        runNumberArray = [runNumberArray; runNumber];

                        NUMBER_OF_PHASES = 2;
                        %% Separation between physical and mental runs
                        if ismember(runNumber, [run.Ep.runsToKeep]) 

                            %% Separate the different phases  using the schematic 
                            %   Choice Phase = fbx {i-1} => choice{i}
                            %   Effort Phase = preEffortCross {i-1} => fbx {i-1}
                            [timings, EChosen, Emax, RChosen] = getBehaviorPhysical(fullfile(folderPathBehavior, behaviorFile{1}), newTime, freq);

                            %% Objects for saving the features that we extract
                            phase_save = {};
                            phase_save{2, length(EChosen)-1} = [];
                            
                            exerciseFeatures = {};
                            exerciseFeatures{1, length(features)} = [];

                            % j being the number of cycle in the run
                            % i being the number of phase by cycle
                            for j = 2:length(EChosen)
                                for i = 1:NUMBER_OF_PHASES
                                    try
                                        if i == 1
                                            signal = signalCleaned(timings(3, j-1):timings(1, j));
                                        else 
                                            signal = signalCleaned(timings(i, j):timings(3, j));
                                        end

                                        %% Create data_analysis_respi_functions object and estimate the features and save them
                                        bmObj = data_analysis_respi_functions(signal, 50, 'humanBB');
                                        bmObj.baselineCorrectedRespiration = signal;
                                        bmObj = estimateAllRespiFeatures( bmObj, 0, 'simple', 1 , 0 );

                                        for w = 1:length(exerciseFeatures)
                                            exerciseFeatures{1, w} =  bmObj.secondaryFeatures(features{w});
                                        end
                                        % FORM: phase_save = [breathObject {BreathingRate, AvgTidalVolume, MinuteVentilation} duration]
                                        phase_save{i, j-1} = {bmObj exerciseFeatures};
                                    catch 
                                        phase_save{i, j-1} = {bmObj exerciseFeatures};
                                    end
                                end
                            end
                            %% Save the patients specific values, the phases, option choosed, max option displayed, reward
                            subjectsTotalFeatures = [subjectsTotalFeatures ; {'Ep', subjectNumber, phase_save, EChosen(2:end), Emax(2:end), RChosen(2:end)}];

                            typeArray = [typeArray; 'Ep'];
                            kEp = [kEp; behavior.kEp(indexE)];
                            kEm = [kEm; NaN];
                                         
                        
                        elseif ismember(runNumber, [run.Em.runsToKeep]) 

                            %% Separate the different phases  using the schematic 
                            %   Choice Phase = fbx {i-1} => choice{i}
                            %   Effort Phase = preEffortCross {i-1} => fbx {i-1}
                            [timings, EChosen, Emax, RChosen] = getBehaviorMental(fullfile(folderPathBehavior, behaviorFile{1}), newTime, freq);
                            
                            %% Objects for saving the features that we extract
                            phase_save = {};
                            phase_save{2, length(EChosen)-1} = [];
                            
                            exerciseFeatures = {};
                            exerciseFeatures{1, length(features)} = [];

                            % j being the number of cycle in the run
                            % i being the number of phase by cycle
                            for j = 2:length(EChosen)
                                for i = 1:NUMBER_OF_PHASES
                                    try
                                        if i == 1
                                            signal = signalCleaned(timings(3, j-1):timings(1, j));
                                        else 
                                            signal = signalCleaned(timings(i, j):timings(3, j));
                                        end
                                        %% Create data_analysis_respi_functions object and estimate the features and save them
                                        bmObj = data_analysis_respi_functions(signal, 50, 'humanBB');
                                        bmObj.baselineCorrectedRespiration = signal;
                                        bmObj = estimateAllRespiFeatures( bmObj, 0, 'simple', 1 , 0 );

                                        for w = 1:length(exerciseFeatures)
                                            exerciseFeatures{1, w} =  bmObj.secondaryFeatures(features{w});
                                        end
                                        % FORM: phase_save = [breathObject {BreathingRate, AvgTidalVolume, MinuteVentilation} duration]
                                        phase_save{i, j-1} = {bmObj exerciseFeatures};
                                    catch 
                                        phase_save{i, j-1} = {bmObj exerciseFeatures};
                                    end
                                end
                            end
                            %% Save the patients specific values, the phases, option choosed, max option displayed, reward
                            subjectsTotalFeatures = [subjectsTotalFeatures ; {'Em', subjectNumber, phase_save, EChosen(2:end), Emax(2:end), RChosen(2:end)}];

                            typeArray = [typeArray; 'Em'];
                            kEm = [kEm; behavior.kEm(indexE)];
                            kEp = [kEp; NaN];
                        end
                    end
                end
            end
        end
    end
    
    %% Final save in the form of tables of all the infos
    for i = 1:length(metabolits_save)
        metabolits_save{i} = metabolits_save{i}';
    end
    metabolits_save = cell2mat(metabolits_save);
    metabolitsTable = array2table(metabolits_save, 'VariableNames',metabolits);

    patients = table(subjectNumberArray, runNumberArray, typeArray, kEm, kEp);

end
