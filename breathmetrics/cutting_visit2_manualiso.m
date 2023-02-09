%% CUT VISIT 2 manual isolation cutting tool for visit2 all phases
% written by Catherine Bratschi
% august/september 2022
%
%% Start by defining rootpath and markers of phases
rootDir = fullfile('\\', 'svfas5.epfl.ch', 'Sandi-Lab', 'Catherine', 'XP VIBES', 'STUDY 1', ...
    'ANALYSIS', 'RAW','ACQ', 'MAT ext', 'V2');
externalDriveDir = fullfile('E:', 'VIBES', 'ACQ', 'RAW', 'MAT ext', 'V2');
fileNames = ls([rootDir, filesep,'V*.mat']);
resultFolderNames = {'1 BASELINE EYES CLOSED', '2 BASELINE EYES OPENED', ...
    '3 ANXIETY OPEN FIELD', '4 ANXIETY ELEVATED PLATFORM WAY UP', ...
    '5 ANXIETY ELEVATED PLATFORM TOP', '6 ANXIETY ELEVATED PLATFORM WAY DOWN', ...
    '7 ANXIETY ELEVATED PLATFORM FULL', '8 ANXIETY DARK MAZE', ...
    '9 STRESS MIST TRAINING', '10 STRESS MIST EXPERIMENT PHASE 1',...
    '11 STRESS MIST EXPERIMENT PHASE 2', '12 STRESS MIST EXPERIMENT PHASE 3', ...
    '13 STRESS MIST EXPERIMENT PHASE 4', '14 STRESS MIST EXPERIMENT FULL', ...
    '15 NEUTRAL CONTROL'};

events = {'ECB',        67, 1, 0,  0, 300000,   'eyesClosedBaseline'; ...
          'EOB',        79, 1, 0,  0, 300000,   'eyesOpenedBaseline'; ...
          'AOF',        18, 1, 21, 1, 90000,    'anxietyOpenField'; ...
          'AEPwup',     18, 2, 21, 2, 26000,    'anxietyElevatedPlatformWUP'; ...
          'AEPtop',     18, 3, 21, 3, 90000,    'anxietyElevatedPlatformTOP'; ...
          'AEPwdn',     18, 4, 21, 4, 8700,     'anxietyElevatedPlatformWDN'; ...
          'AEPf',       18, 2, 21, 4, 130000,   'anxietyElevatedPlatformFULL'; ...
          'ADM',        18, 5, 21, 5, 90000,    'anxietyDarkMaze'; ...
          'SMISTt',     40, 1, 41, 1, 90000,    'stressMISTtraining'; ...
          'SMISTep1',   41, 1, 46, 1, 155000,   'stressMISTexperimentPHASE1'; ...
          'SMISTep2',   46, 1, 47, 1, 155000,   'stressMISTexperimentPHASE2'; ...
          'SMISTep3',   47, 1, 48, 1, 155000,   'stressMISTexperimentPHASE3'; ...
          'SMISTep4',   48, 1, 45, 0, 155000,   'stressMISTexperimentPHASE4'; ...
          'SMISTef',    41, 1, 45, 0, 720000,   'stressMISTexperimentFULL'; ...
          'NC',         78, 1, 0,  0, 600000,   'neutralControl'};
% in events: 1st column is event abreviation (see vectors definition
% below for full names), 2nd column is key code value, 3rd column is
% start_sampling (if no issue), 4th column is endSampling (unit: samples),
% 5th column is full name
nFolders = length(events(:,2));
nFiles = length(fileNames);
errorsStartSample=cell(nFolders,nFiles);
errorsEndSample=cell(nFolders,nFiles);
rowErrors = 1;
    
%% Loop through all raw files (format needs to be in .mat)
for iFiles = 50%1:length(fileNames)
    currentDataFileName = fileNames(iFiles, :);
    rawData = load(fullfile(rootDir, currentDataFileName));
    
    disp(strcat('File', currentDataFileName, ': loading completed'))
    cutdata = rawData.data(:,[1 2 3 4 15]); 
    keyloggCol = cutdata(:,5);
    
    keyNumber = 15;
    
    %% Localize the start of the phase in raw data
    for iFolders = 15%1:length(events(:,2))
        startKeyCodeIso = cell2mat(events(keyNumber, 2));
        startKeyCodeDiff = diff(keyloggCol == startKeyCodeIso);
        startKeyCodeIndices = find(startKeyCodeDiff == 1) +1; % add a +1 to the position otherwise it returns a number located right before the actual pressing of the key
        eventPhaseIso = events(keyNumber, 7);
        eventPhaseName = string(eventPhaseIso); % just to know which phase we're talking about later
        
    %% Identify if scenarios were launched multiple times 
%                 errors(rowErrors, :) = strcat(' partial error in V',...
%                 num2str(currentDataFileName(iFiles,2:4)), ...
%                 'too many keys pressed for event ', eventPhaseName,...
%                 ' of visit2, the last occurence of the event was taken, keyCode = ',...
%                 keyCode);
%                 rowErrors = rowErrors + 1;
%         elseif ismember(startKeyCodeIso,[40 41 46 47 48 78])
%              if numel(startKeyCodeIndices) > 1
%                  startKeyCodeIndices = startKeyCodeIndices(end);
% %                 cutter = startKeyCodeIndices(end)-2;
% %                 cutdata = cutdata(cutter:end, :);
% %                 keyloggCol = keyloggCol(cutter:end, :);
% %                 startKeyCodeDiff = diff(keyloggCol == startKeyCodeIso);
% %                 startKeyCodeIndices = find(startKeyCodeDiff == 1) +1; % add a +1 to the position otherwise it returns a number located right before the actual pressing of the key
% %                 errors(rowErrors, :) = strcat(' partial error in V',...
% %                 num2str(currentDataFileName(iFiles,2:4)), ...
% %                 'too many keys pressed for event ', eventPhaseName,...
% %                 ' of visit2, the last occurence of the event was taken, keyCode = ',...
% %                 keyCode);
% %                 rowErrors = rowErrors + 1;
%              end
        
        
    %% Localize the end of the phase
        if (numel(startKeyCodeIso) >= 1) && (numel(startKeyCodeIndices) >= 1)
            
            % three phases don't have end markers, their end was set to the
            % approximation of 1000samples/s *phaseDuration (5min for
            % baselines, 10min for neutralControl)
            if ismember(startKeyCodeIso, [67 79 78])
                if numel(startKeyCodeIndices) > 1
                    startSample = startKeyCodeIndices(end);
                else
                    start_sampling = cell2mat(events(keyNumber, 3));
                    startSample = startKeyCodeIndices(start_sampling);
                end
                endKeyCodeIso = cell2mat(events(keyNumber, 4)); % useless for cutting this particular phase but needed by a part of the code below (last if-statement before the toggle while loop)
                end_sampling = cell2mat(events(keyNumber, 6));
                endSample = startSample + end_sampling;
                
            % two phases don't have end markers, but there is another
            % marker that can be used instead (last feedback from 
            % calculations in MIST)
            elseif ismember(eventPhaseName,{'stressMISTexperimentPHASE4',...
                    'stressMISTexperimentFULL'})
                start_sampling = cell2mat(events(keyNumber, 3));
                startSample = startKeyCodeIndices(start_sampling);
                endKeyCodeIso = cell2mat(events(keyNumber, 4));
                endKeyCodeDiff = diff(keyloggCol == endKeyCodeIso);
                endKeyCodeIndices = find(endKeyCodeDiff == 1) +1;
                end_sampling = length(endKeyCodeIndices);
                endSample = endKeyCodeIndices(end_sampling); %% added because I was not understanding where the endSample was?!            
                
            % localize end of phases based on their end markers
            else          
                start_sampling = cell2mat(events(keyNumber, 3));
                startSample = startKeyCodeIndices(start_sampling);
                endKeyCodeIso = cell2mat(events(keyNumber, 4));
                endKeyCodeDiff = diff(keyloggCol == endKeyCodeIso);
                endKeyCodeIndices = find(endKeyCodeDiff == 1) +1;
                end_sampling = cell2mat(events(keyNumber, 5));
                
                if end_sampling > numel(endKeyCodeIndices)
                   end_sampling = cell2mat(events(keyNumber, 6));
                   endSample = startSample + end_sampling;
                else
                   endSample = endKeyCodeIndices(end_sampling); % had to add one otherwise it would not take the last one into account
                end
            end
            
            % if-statements accounting for special cases
            if(startKeyCodeIso == 18) && (numel(startKeyCodeIndices) > 5) 
                startKeyCodeIndices = startKeyCodeIndices(end-4:end); 
                start_sampling = cell2mat(events(keyNumber, 3));
                startSample = startKeyCodeIndices(start_sampling);
                endKeyCodeIndices = endKeyCodeIndices(end-4:end); 
                end_sampling = cell2mat(events(keyNumber, 5));
                endSample = endKeyCodeIndices(end_sampling);
            elseif (ismember(startKeyCodeIso, [40 41 46 47 48])) && ...
                   (numel(startKeyCodeIndices) > 1 ) 
                if startSample > endSample
                 %||(startKeyCodeIndices(end) > endKeyCodeIndices(end))
                        startSample = startKeyCodeIndices(end-1);
                        endSample = endKeyCodeIndices(end);
                else
                        start_sampling = length(find(endSample > startKeyCodeIndices));
                        startSample = startKeyCodeIndices(start_sampling);
                end
            end

            if (ismember(endKeyCodeIso,[46 47 48])) && ...
                    (numel(endKeyCodeIndices) > 1) 
%                    endCutter = startSample;
%                    endCutdata = cutdata(endCutter:end, :);
%                    endKeyloggCol = keyloggCol(endCutter:end);
%                    endKeyCodeDiff = diff(endKeyloggCol == endKeyCodeIso);
               endKeyCodeIndices = find(endKeyCodeDiff == 1) +1;
               end_sampling = find(endKeyCodeIndices > startSample, 1);
%                end_sampling = length(find(startSample < endKeyCodeIndices));

               endSample = endKeyCodeIndices(end_sampling);
            end
            
            if numel(endSample) < 1
               string_to_be_added = strcat('error with endSample in V',...
                    num2str(currentDataFileName(2:4)), 'for event ', ...
                    eventPhaseName, ' of visit2, keyCode = ', events(keyNumber, 4));
               errorsEndSample{iFolders,iFiles} = string_to_be_added;
               cutdataset = [];
            else
               string_to_be_added = 0;
               errorsEndSample{iFolders,iFiles} = string_to_be_added;
            end
           
    %% Initiate toggle and cutdataset vector
            i = 0;
            row = 1;
            cutdataset = [];
            toggle = true;
            
        %% cut data based on the localizations of start and end samples
            while toggle
                sampling = startSample + i;
                cutdataset(row,:) = cutdata(sampling,:);
                i = i + 1;
                row = row + 1;
                     if (sampling == endSample) || ...
                             (sampling > length(keyloggCol)-1)
                     toggle = false;
                    end
            end
            
            string_to_be_added = 0;
            errorsStartSample{iFolders,iFiles} = string_to_be_added;
            
         else
             %              in case of errors
            string_to_be_added = strcat('error with startSample in V',...
                 num2str(currentDataFileName(2:4)), 'for event ', ...
                 eventPhaseName, ' of visit2, keyCode = ', events(keyNumber, 4));
            errorsStartSample{iFolders,iFiles} = string_to_be_added;
            cutdataset = [];
            
        end
        
%       eval([num2str(eventPhaseName) '=cutdataset;']);                 
        keyNumber = keyNumber + 1;
        clear endSample;
        clear endKeyCodeIndices;
        clear startSample;
        clear startKeyCodeIndices;
        
     %% Save the cut data vector    
         resultDir = fullfile('\\','svfas5.epfl.ch', 'Sandi-Lab', 'Catherine', 'XP VIBES', 'STUDY 1', ... 
         'ANALYSIS', 'CLEAN', 'PHYSIO', 'CUTDATA', 'V2', ...
         resultFolderNames{iFolders});
 
         save(strcat(resultDir, filesep, currentDataFileName(1:4), '_V2_',...
             eventPhaseName, '.mat'), 'cutdataset');
         
         disp(strcat(eventPhaseName, ' of participant ', ' ', currentDataFileName(1:4), ...
             ' has successfully been uploaded in folder ', ' ', ...
             resultFolderNames{iFolders}))
    end
    clc
end

resultDirERRORS = fullfile('\\','svfas5.epfl.ch', 'Sandi-Lab', ...
    'Catherine', 'XP VIBES', 'STUDY 1', 'ANALYSIS', 'CLEAN', 'PHYSIO', ...
    'CUTDATA', 'V2');
% save(strcat(resultDirERRORS, filesep,'errorsStartSample'),'errorsStartSample');
% save(strcat(resultDirERRORS, filesep, 'errorsEndSample'), 'errorsEndSample');
% disp('the error files have successfully been uploaded in Catherine > XP VIBES > STUDY 1 > ANALYSIS > CLEAN > PHYSIO > CUTDATA > V2')

%% done