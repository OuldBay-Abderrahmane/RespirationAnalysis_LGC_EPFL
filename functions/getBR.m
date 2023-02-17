function [breathingRatePhysicalHEChoice, breathingRatePhysicalLEChoice, ...
    breathingRatePhysicalHEEffort, breathingRatePhysicalLEEffort, ...
    breathingRateMentalHEChoice, breathingRateMentalLEChoice, ...
    breathingRateMentalHEEffort, breathingRateMentalLEEffort]  = getBR(patients, task)
    
    % [__] = getBR(patients, task)
    % Compute the breathing rate of the patients table depabding the the
    % effort level task chosen
    %
    % INPUT
    % - patients: table of patients
    % - task: Task level
    %
    % OUTPUT :
    % arrays of High and Low chosen efforts for both mental and physical
    % tasks
    %
    % Developed by Abderrahmane Ould Bay - 15/02/2023

    %% Initialization
    breathingRatePhysicalHEChoice = [];
    breathingRatePhysicalLEChoice = [];

    breathingRatePhysicalHEEffort = [];
    breathingRatePhysicalLEEffort = [];
    
    breathingRateMentalHEChoice = [];
    breathingRateMentalLEChoice = [];

    breathingRateMentalHEEffort  = [];
    breathingRateMentalLEEffort  = [];
    
    %% Looping of patients and saving the results
    for i = 1:height(patients.subjectsTotalFeatures)
        subjectsFeatures = patients.subjectsTotalFeatures{i, 3};
        choice = subjectsFeatures(1, :);
        effort = subjectsFeatures(2, :);

        %% Get the intersection of maximum effort displayed to the patient and the effort he chose
        Emax = find(patients.subjectsTotalFeatures{i, 5} == task);
%         [EHigh, iChosenHigh, iMaxHigh] = intersect(patients.subjectsTotalFeatures{i, 4}, patients.subjectsTotalFeatures{i, 5}(Emax));
%         [ELow, iChosenLow] = setdiff(patients.subjectsTotalFeatures{i, 4}, patients.subjectsTotalFeatures{i, 5}(Emax));
        diffE = patients.subjectsTotalFeatures{i, 5}(Emax) - patients.subjectsTotalFeatures{i, 4}(Emax);
        iChosenHigh = find(diffE==0);
        iChosenLow = find(diffE ~= 0);
        %% Get the average for each high and low efforts the patient chose
        averageChoiceHigh = averageFeature(choice(iChosenHigh));
        averageEffortHigh = averageFeature(effort(iChosenHigh));

        averageChoiceLow = averageFeature(choice(iChosenLow));
        averageEffortLow = averageFeature(effort(iChosenLow));



        %% Discriminate between Mental an Physical Efforts
        if patients.subjectsTotalFeatures{i, 1} == 'Ep' 
            breathingRatePhysicalHEChoice = [breathingRatePhysicalHEChoice; averageChoiceHigh];
            breathingRatePhysicalHEEffort = [breathingRatePhysicalHEEffort; averageEffortHigh];
            breathingRatePhysicalLEChoice = [breathingRatePhysicalLEChoice; averageChoiceLow];
            breathingRatePhysicalLEEffort = [breathingRatePhysicalLEEffort; averageEffortLow];

        elseif patients.subjectsTotalFeatures{i, 1} == 'Em' 
            breathingRateMentalHEChoice = [breathingRateMentalHEChoice; averageChoiceHigh];
            breathingRateMentalHEEffort = [breathingRateMentalHEEffort; averageEffortHigh];
            breathingRateMentalLEChoice = [breathingRateMentalLEChoice; averageChoiceLow];
            breathingRateMentalLEEffort = [breathingRateMentalLEEffort; averageEffortLow];
        end
   end
end