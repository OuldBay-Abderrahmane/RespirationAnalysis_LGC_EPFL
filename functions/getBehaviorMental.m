function [timings, EChosen, Emax, RChosen] = getBehaviorMental(file, time, freq)
    % [timings, EChosen, Emax,  RChosen] = getBehaviorPhysical(file, time, freq)
    % Give the values of interest during a mental task
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
    preDispChoiceCrossT = findTimings(time, freq, behaviorStruct.mentalE_perf.onsets.preChoiceCross, T0);
    preDispChoice= findTimings(time, freq, behaviorStruct.mentalE_perf.onsets.choice, T0);
    preEffortCrossT = findTimings(time, freq, behaviorStruct.mentalE_perf.onsets.preEffortCross, T0);
    fbk = findTimings(time, freq, behaviorStruct.mentalE_perf.onsets.fbk, T0);
    
    %% Isolate Effort Period to decomment to get it
%     effortPeriod = [];
%     for i = 1:length(preDispChoiceCrossT)
%         effort = behaviorStruct.mentalE_perf.onsets.effortPeriod{i}.nb_1;
%         effortPeriod = [effortPeriod, effort];
%     end
%     effortPeriodT = findTimings(time, freq, effortPeriod, T0);

    %% Select depending on EFFORT_LEVEL_TRESHOLD 
    EChosen = behaviorStruct.mentalE_perf.E_chosen; 
    idxs = find(EChosen >= EFFORT_LEVEL_TRESHOLD);
    EChosen = EChosen(idxs);

    RChosen = behaviorStruct.mentalE_perf.R_chosen; 
    RChosen = RChosen(idxs);
    
    %% Get Timings
    timings = [preDispChoiceCrossT(idxs); preDispChoice(idxs); preEffortCrossT(idxs); fbk(idxs)];
end