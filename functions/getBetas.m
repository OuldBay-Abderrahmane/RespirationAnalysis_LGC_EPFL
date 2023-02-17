function [ betaPhysicalHEffort, betaPhysicalHChoice, betaPhysicalLEffort, betaPhysicalLChoice,  ...
    betaMentalHEffort, betaMentalHChoice, betaMentalLEffort,betaMentalLChoice ] = getBetas(patients)

    betaPhysicalHEffort = [];
    betaPhysicalHChoice = [];
    betaPhysicalLEffort = [];
    betaPhysicalLChoice = [];

    betaMentalHEffort = [];
    betaMentalHChoice = [];
    betaMentalLEffort = [];
    betaMentalLChoice = [];


    %% Looping of patients and saving the results
    for i = 1:height(patients.subjectsTotalFeatures)
        subjectsFeatures = patients.subjectsTotalFeatures{i, 3};
        choice = subjectsFeatures(1, :);
        effort = subjectsFeatures(2, :);

        %% Get the intersection of maximum effort displayed to the patient and the effort he chosen
%         Emax = find(patients.subjectsTotalFeatures{1, 5});
        a = patients.subjectsTotalFeatures{i, 5} - patients.subjectsTotalFeatures{i, 4};
        iChosenHigh = find(a==0);
        iChosenLow = find(a ~= 0);

        choiceHigh = choice(iChosenHigh);
        effortHigh = effort(iChosenHigh);
        
        choiceLow = choice(iChosenLow);        
        effortLow = effort(iChosenLow);

        HChoice = [];
        HEffort = [];
        LChoice = [];
        LEffort = [];


        for w = 1:length(iChosenHigh)
            if ~isempty(getBRInsideCell(effortHigh, w)) && ~isempty(getBRInsideCell(choiceHigh, w))
                if ~isnan(getBRInsideCell(effortHigh, w)) && ~isnan(getBRInsideCell(choiceHigh, w))
                    HChoice = [HChoice getBRInsideCell(choiceHigh, w)];
                    HEffort = [HEffort getBRInsideCell(effortHigh, w)];
                else
                    iChosenHigh(w) = NaN;
                end
            else 
                iChosenHigh(w) = NaN;
            end
        end

        for w = 1:length(iChosenLow)
            if ~isempty(getBRInsideCell(choiceLow, w)) && ~isempty(getBRInsideCell(effortLow, w))
                if ~isnan(getBRInsideCell(choiceLow, w)) && ~isnan(getBRInsideCell(effortLow, w))
                    LChoice = [LChoice getBRInsideCell(choiceLow, w)];
                    LEffort = [LEffort getBRInsideCell(effortLow, w)];
                else
                    iChosenLow(w) = NaN;
                end
            else
                iChosenLow(w) = NaN;
            end
        end

        iChosenLow(isnan(iChosenLow)) = [];
        iChosenHigh(isnan(iChosenHigh)) = [];

        if patients.subjectsTotalFeatures{i, 1} == 'Ep' 
            if ~isempty(LEffort) && ~isempty(HChoice)
                [betas, pval, xSort, yFit] = linear_fit(HEffort', patients.subjectsTotalFeatures{i, 4}(iChosenHigh)');
                betaPhysicalHEffort = [betaPhysicalHEffort; betas];
                
                [betas, pval, xSort, yFit] = linear_fit( LEffort', patients.subjectsTotalFeatures{i, 4}(iChosenLow)' );
                betaPhysicalLEffort = [betaPhysicalLEffort; betas];
                 
            end
            if ~isempty(HChoice) && ~isempty(LChoice)
                [betas, pval, xSort, yFit] = linear_fit( HChoice', patients.subjectsTotalFeatures{i, 4}(iChosenHigh)');
                betaPhysicalHChoice = [betaPhysicalHChoice; betas];
                
                [betas, pval, xSort, yFit] = linear_fit( LChoice', patients.subjectsTotalFeatures{i, 4}(iChosenLow)' );
                betaPhysicalLChoice = [betaPhysicalLChoice; betas]; 
            end

        elseif patients.subjectsTotalFeatures{i, 1} == 'Em' 
            if ~isempty(HEffort) && ~isempty(LEffort)
                [betas, pval, xSort, yFit] = linear_fit(HEffort', patients.subjectsTotalFeatures{i, 4}(iChosenHigh)' );
                betaMentalHEffort = [betaMentalHEffort; betas];
                
                [betas, pval, xSort, yFit] = linear_fit(LEffort', patients.subjectsTotalFeatures{i, 4}(iChosenLow)' );
                betaMentalLEffort = [betaMentalLEffort; betas];
                
            end
            if ~isempty(HChoice) && ~isempty(LChoice)
                [betas, pval, xSort, yFit] = linear_fit( HChoice', patients.subjectsTotalFeatures{i, 4}(iChosenHigh)');
                betaMentalHChoice = [betaMentalHChoice; betas]; 
    
                [betas, pval, xSort, yFit] = linear_fit(LChoice', patients.subjectsTotalFeatures{i, 4}(iChosenLow)' );            
                betaMentalLChoice = [betaMentalLChoice; betas]; 
            end
        end
    end

end