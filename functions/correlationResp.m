function [pvalE] = correlationResp(patients, study, feature, type, studyName, featureName)
    % [pvalE] = correlationResp(patients, study, feature, type, studyName, featureName)
    % Plot the correlation between patients caracteristics 
    %
    % INPUT
    % - patients: table of patients
    % - study: Fisrt studied caracter (matabolits, kEp, kEm)
    % - feature: Second studied caracter (breathing Rate, Tidal Volume)    
    % - Type: Em et Ep 
    % OUTPUT :
    % Plot of the correlation and the pvalues of the correlation
    %
    % Developed by Abderrahmane Ould Bay - 15/02/2023
    
    patientsE = strcmp(cellstr(patients.typeArray), type);
    indexE = find(patientsE(:,1)==1);
    studyE = study(indexE);
    featureE  = feature;
    
    [correlation, pvalE, th2]= corrplot([featureE studyE], 'varNames', {studyName, featureName});
end