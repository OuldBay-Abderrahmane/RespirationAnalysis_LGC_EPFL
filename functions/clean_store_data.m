function [patients, featuresTable, metabolitsTable] = ...
    clean_store_data(folders, commonPath, filePattern, filterBand, ...
    freq, behavior, metabolits_file, metabolits, features)
    
    
    [subjectNumberArray, runNumberArray, bmObjArray, ...
        typeArray, kEm, kEp] = deal([], [], [], [], [], []);
    
    metabolits_save = {};
    metabolits_save{1, length(metabolits)} = [];

    features_save = {};
    features_save{1, length(features)} = [];

    counter = 0;
    for iFolders = 1:length(folders)
        rootDir = fullfile(commonPath, folders(iFolders).name, filePattern);
        folderPath = fullfile(commonPath, folders(iFolders).name);
        fileNames = dir(rootDir);
        subjectNumber = erase(folders(iFolders).name, 'CID');

%       Cell Array of 2 x features size
% Ep    []  []  [] ...  []
% Em    []  []  [] ...  []
        exerciseFeatures = {};
        exerciseFeatures{2, length(features)} = [];


        if ismember(subjectNumber, behavior.subject_id) && ismember(subjectNumber, metabolits_file.subject_id)
            indexE = find(strcmp(cellstr(subjectNumber), behavior.subject_id));
            indexdmPFC = find(strcmp(cellstr(subjectNumber), metabolits_file.subject_id));

            expressionRun = 'n[0-9]*';
            run = runs_definition('study1', subjectNumber, 'respiration_and_noSatRun');   
            

            [EmPrev, EpPrev] = deal(0, 0);

            for iFiles = 1:length(fileNames)
                runNumber = erase(regexp( fileNames(iFiles).name, expressionRun,'match'), 'n');
                runNumber = str2num(runNumber{1});
   
                if ismember(runNumber, run.runsToKeep)
                    counter = counter + 1;
                    
                    [signalFiltered, time, start] = filterSignal(folderPath, fileNames(iFiles).name, filterBand, freq);
                    signalCleaned = slider(signalFiltered, time, 300, fileNames(iFiles).name);
                    
                    for i = 1:length(metabolits)
                        metabolits_save{1, i} = [metabolits_save{1, i} getMetabolit(metabolits_file, metabolits{i}, indexdmPFC)];
                    end

                    bmObj = data_analysis_respi_functions(signalCleaned, 50, 'humanBB');
                    bmObj.baselineCorrectedRespiration = signalCleaned;
                    bmObj = estimateAllRespiFeatures( bmObj, 0, 'simple', 1, 0 );


                    subjectNumberArray = [subjectNumberArray; subjectNumber];
                    runNumberArray = [runNumberArray; runNumber];
                    bmObjArray = [bmObjArray; bmObj];
                    
                    if ismember(runNumber, [run.Ep.runsToKeep])
                        typeArray = [typeArray; 'Ep'];
                        kEp = [kEp; behavior.kEp(indexE)];
                        kEm = [kEm; NaN];

                        for i = 1:length(exerciseFeatures)
                            exerciseFeatures{1, i} = [exerciseFeatures{1, i} bmObj.secondaryFeatures(features{i})];
                        end
%                         
                        if EpPrev == 0
                            for i = 1:length(features_save)
                                features_save{1, i}(counter) = getAverageSecondaryFeature(features{i},exerciseFeatures{1, i}); 
                            end
                            EpPrev = counter;
                        else
                            for i = 1:length(features_save)
                                features_save{1, i}([EpPrev counter]) = getAverageSecondaryFeature(features{i},exerciseFeatures{1, i}); 
                            end
                            EpPrev=0;
                        end
                    elseif ismember(runNumber, [run.Em.runsToKeep])
                        typeArray = [typeArray; 'Em'];
                        kEm = [kEm; behavior.kEm(indexE)];
                        kEp = [kEp; NaN];

                        for i = 1:length(exerciseFeatures)
                            exerciseFeatures{2, i} = [exerciseFeatures{2, i} bmObj.secondaryFeatures(features{i})];
                        end

                        if EmPrev == 0
                            for i = 1:length(features_save)
                                features_save{1, i}(counter) = getAverageSecondaryFeature(features{i},exerciseFeatures{2, i}); 
                            end
                            EmPrev = counter;
                        else
                            for i = 1:length(features_save)
                                features_save{1, i}([EmPrev counter]) = getAverageSecondaryFeature(features{i},exerciseFeatures{2, i}); 
                            end
                            EmPrev=0;
                        end
                    end
                end
            end

        end
    end
    for i = 1:length(metabolits_save)
        metabolits_save{i} = metabolits_save{i}';
    end
    metabolits_save = cell2mat(metabolits_save);
    metabolitsTable = array2table(metabolits_save, 'VariableNames',metabolits);
    for i = 1:length(features_save)
        features_save{i} = features_save{i}';
    end
    features_save = cell2mat(features_save);
    featuresTable = array2table(features_save, 'VariableNames',features);

    patients = table(subjectNumberArray, runNumberArray, bmObjArray, typeArray, kEm, kEp);

end
