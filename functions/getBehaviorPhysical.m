function [timings, EChosen, Emax,  RChosen] = getBehaviorPhysical(file, time, freq)
    % [timings, EChosen, Emax,  RChosen] = getBehaviorPhysical(file, time, freq)
    % Give the values of interest during a physical task
    % 
    % INPUT
    % - file: file 
    % - time: time array of the task
    % - freq : sampling rate
    %
    % OUTPUT :
    % timings: indexes of the start of choice and effort phase
    % EChosen : effort level chosen
    % Emax : max effort level displayed
    % RChosen : reward earned
    % Developed by Abderrahmane Ould Bay - 15/02/2023

    %% Initialisation and get the T0
    behaviorStruct = load(file);
    EFFORT_LEVEL_TRESHOLD = 0; 

    T0 = behaviorStruct.onsets.T0;
    
    %% Get the max choice the patient had available
    leftOpt = behaviorStruct.choice_opt.E.left;
    rightOpt = behaviorStruct.choice_opt.E.right;
    Emax = max(leftOpt, rightOpt);

    %% Isolate Effort Period and Choice period
    preDispChoice= findTimings(time, freq, behaviorStruct.physicalPerf.onsets.choice, T0);
    preEffortCrossT = findTimings(time, freq, behaviorStruct.physicalPerf.onsets.preEffortCross, T0);
    fbk = findTimings(time, freq, behaviorStruct.physicalPerf.onsets.fbk, T0);
    
    %% Isolate Effort Period to decomment to get it
%     effortPeriod = [];
%     for i = 1:length(preDispChoiceCrossT)
%         effort = behaviorStruct.physicalPerf.onsets.effortPeriod{i}.effort_phase;
%         effortPeriod = [effortPeriod, effort];
%     end

    %% Select depending on EFFORT_LEVEL_TRESHOLD 
    EChosen = behaviorStruct.physicalPerf.E_chosen; 
    idxs = find(EChosen >= EFFORT_LEVEL_TRESHOLD);
    EChosen = EChosen(idxs);

    RChosen = behaviorStruct.physicalPerf.R_chosen; 
    RChosen = RChosen(idxs);
    
    %% Get Timings
    timings = [preDispChoice(idxs); preEffortCrossT(idxs); fbk(idxs)];
end