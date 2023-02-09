function [pvalues, h1, h2] = correlationResp(patients, study, feature, studyName, featureName)
    
    patientsEp = strcmp(cellstr(patients.typeArray), 'Ep');
    patientsEm = strcmp(cellstr(patients.typeArray), 'Em');

    indexEp = find(patientsEp(:,1)==1);
    indexEm = find(patientsEm(:,1)==1);

    tableEp = unique(patients(indexEp,:),'rows');
    tableEm = unique(patients(indexEm,:),'rows');

    studyEp = study(indexEp);
    studyEm = study(indexEm);

    featureEp = feature(indexEp);
    featureEm = feature(indexEm);


    [correlation, pvalEp, th1]= corrplot([featureEp studyEp], 'varNames', {featureName, studyName}); 
    filenameEp = strcat('corrPlots\', studyName,'_', featureName, '_Ep', '.png');
    h1 = th1;
    [correlation, pvalEm, th2]= corrplot([featureEm studyEm], 'varNames', {featureName, studyName}); 
    filenameEm = strcat('corrPlots\', studyName,'_', featureName, '_Em', '.png');
    h2 = th2;
    pvalues = [{pvalEp, {featureName, studyName}, 'Ep'}, {pvalEm, {featureName, studyName}, 'Ep'}];

end