function [tableBr] = getBrethingRate(patients)
    
    tableBr = table();

    for i = 1:height(patients.subjectsTotalFeatures)

        [breathingRateHChoice, breathingRateHEffort,breathingRateLChoice, breathingRateLEffort] = deal([],[],[],[]);
        [choiceCount, effortCount] = deal([],[]);

        subjectsFeatures = patients.subjectsTotalFeatures{i, 3};
        choice = subjectsFeatures(1, :);
        effort = subjectsFeatures(2, :);

        diffE = patients.subjectsTotalFeatures{i, 5} - patients.subjectsTotalFeatures{i, 4};
        iChosenHigh = find(diffE == 0);
        iChosenLow = find(diffE ~= 0);

        choiceHigh = choice(iChosenHigh);
        effortHigh = effort(iChosenHigh);

        choiceLow = choice(iChosenLow);
        effortLow = effort(iChosenLow);

        for w = 1:length(iChosenHigh)
            breathingRateHChoice = [breathingRateHChoice getBRInsideCell(choiceHigh, w)];
            breathingRateHEffort = [breathingRateHEffort getBRInsideCell(effortHigh, w)];
            if ~isempty(getBRInsideCell(choiceHigh, w)) && ~isempty(getBRInsideCell(effortHigh, w))
                if ~isnan(getBRInsideCell(choiceHigh, w))
                    choiceCount = [choiceCount 1];
                elseif ~isnan(getBRInsideCell(effortHigh, w))
                    effortCount = [effortCount 1];
                end
            end

        end
        for w = 1:length(iChosenLow)
            breathingRateLChoice = [breathingRateLChoice getBRInsideCell(choiceLow, w)];
            breathingRateLEffort = [breathingRateLEffort getBRInsideCell(effortLow, w)];
            if ~isempty(getBRInsideCell(choiceLow, w)) && ~isempty(getBRInsideCell(effortLow, w))
                if ~isnan(getBRInsideCell(choiceLow, w))
                    choiceCount = [choiceCount 0];
                elseif  ~isnan(getBRInsideCell(effortLow, w))
                    effortCount = [effortCount 0];
                end
            end
        end

        proportionEffort = sum(effortCount)/length(effortCount);
        proportionChoice = sum(choiceCount)/length(choiceCount);

        if isnan(proportionEffort)
            proportionEffort = 0;
        end
        if isnan(proportionChoice)
            proportionChoice = 0;
        end

        effortMean = nanmean(breathingRateHChoice)*proportionChoice + nanmean(breathingRateLChoice)*(1-proportionChoice);
        choiceMean = nanmean(breathingRateHEffort)*proportionEffort+ nanmean(breathingRateLEffort)*(1-proportionEffort);

        newTable = table();
        newTable.effortMean = effortMean;
        newTable.choiceMean = choiceMean;
        newTable.choice = proportionChoice;
        newTable.effort = proportionEffort;

        tableBr = [tableBr; newTable];
    end
end