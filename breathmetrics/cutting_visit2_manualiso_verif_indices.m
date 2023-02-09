%% indices order: verification lines 
%
% written by Catherine Bratschi
% october 2022

maxStartScenario = 1 % if scenario starts on that key, then =1, if the actual start of the scenario is before, put the difference
startSample = 4000000
verifRange = [keyloggCol(startSample-maxStartScenario:end)]
verif_diff = diff(verifRange ~=0)
verif_indices = find(verif_diff==1)+1
verif_data = cutdata(startSample-maxStartScenario:startSample-maxStartScenario+length(verifRange)-1, :)
verif_DIX = verif_data(verif_indices, 5)

% find(verif_DIX ~=0)
