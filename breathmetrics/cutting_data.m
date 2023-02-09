%% PIPELINE TO CUT THE PHASES OF INTEREST FROM THE BIG DATASET INTO FOCUSED MATRICES

% KEYLOGGER KEYS:
% 67 = eyes closed in keylogger
% 79 = eyes opened in keylogger
% 87 = anticipation in keylogger


% Columns of the matrices:
% 1 = Respiration
% 2 = PPG
% 3 = ECG
% 4 = EDA
% 5 = Keylogger entries

% CHANGES IN EACH PHASE:
% 1st line =  replace number at the end if needed (according to the 
%             labbook and what happened during the experiment, e.g. double 
%             press?) to tell matlab which key entry you want to start from

% 2nd line =  change number of samples been looked at if needed
%             (1 second = 2000 samples, if no issues, usually set to 
%             5 min = 600000 samples)

% 5th line =  change the i value to fit with what is best according to the
%             data (try first a bit before 0, then at 0 and then check for
%             overlaps and finally visualize th data to make sure your 
%             i is in this area) if i should start after the key was
%             actually pressed, then simply write the new value in i,
%             otherwise if i should start before the key was pressed put a
%             minus sign - just before the new value in i

% OVERLAP CHECKS:
% [1] do not add semicolons ; after the following lines because you want
%     to see the results these lines get you
% [2] these checks are just to be sure that we are not overstepping on other 
%     phases; if we are indeed overstepping on another phase, change the 
%     number of samples been looked to last sample before the next phase in 
%     all three loops

% PROTOCOL:
% [0] make sure the file is on your desktop
% [1] load the datafile into the buffer as a structure
% [2] create an intermediate matrix
% [3] cut the data into a new matrix
% [4] check that there is no overlap
% [5] if there was an overlap, repeat [3] with endSampling value
% [6] visually inspect the data
% [7] repeat [3] to [6] on each phase
% [8] save matrices

%% load the datafile into the buffer as a structure

% replace the name of the file here with the name of the file you want 
% to cut
                                                    % change here
rawData = load('M:\Catherine\XP VIBES\STUDY 1\ANALYSIS\RAW\ACQ\MAT ext\V1\V031_visit1.mat'); 

%% create an intermediate matrix with only the data of interest

cutdata = rawData.data(:,[1 2 3 4 15]); 

%% eyes closed baseline

start_sampling = find(cutdata(:,5) == 67,1);    % change last number if needed (Labbook: double press?)
endSampling = 300000;                           % change endSampling if needed
eyesClosedBaseline = []; 
toggle = true;
i = 0;                                          % change i value if needed (it's where the sampling will start)
row = 1;

while toggle
    eyesClosedBaseline (row, :) = cutdata(start_sampling + i,:);

    i = i + 1;
    row = row+1;
    
    if i == endSampling
       toggle = false;
    end
end

%% eye closed baseline: overlap check

sum(eyesClosedBaseline(:,5)~=0)                             % if value is under 10, then all is well 
overstep_check = find(eyesClosedBaseline(:,5)~=0)           % find where overstep is happening
display_overstep = eyesClosedBaseline(overstep_check,:)     % display values (column 5 = keylogger entries)

%% eyes closed baseline : visual inspection

% display eyesClosedBaseline
figure(1);
ecblength = 1:length(eyesClosedBaseline);
ecbRESP = eyesClosedBaseline(:,1);
ecbPPG = eyesClosedBaseline(:,2);
ecbECG = eyesClosedBaseline(:,3);
ecbEDA = eyesClosedBaseline(:,4);
    
    % Plot respiration data
    ecbax1 = nexttile;
    plot(ecbax1, ecblength, ecbRESP,'-','Color','b');
    title(ecbax1, 'Respiration data');
    xlabel(ecbax1, 'sample');
    ylabel(ecbax1, 'value');
    
    % Plot PPG data
    ecbax2 = nexttile;
    plot(ecbax2, ecblength, ecbPPG,'-','Color','k');
    title(ecbax2, 'PPG data');
    xlabel(ecbax2, 'sample');
    ylabel(ecbax2, 'value');

    % Plot ECG data
    ecbax3 = nexttile;
    plot(ecbax3, ecblength, ecbECG,'-','Color','r');
    title(ecbax3, 'ECG data');
    xlabel(ecbax3, 'sample');
    ylabel(ecbax3, 'value');

    % Plot EDA data
    ecbax4 = nexttile;
    plot(ecbax4, ecblength, ecbEDA,'-','Color','g');
    title(ecbax4, 'EDA data');
    xlabel(ecbax4, 'sample');
    ylabel(ecbax4, 'value');
    
    
%% eyes opened baseline

start_sampling = find(cutdata(:,5) == 79,1);
endSampling = 300000;
eyesOpenedBaseline = []; 
toggle = true;
i = 0;
row = 1;

while toggle
    eyesOpenedBaseline (row, :) = cutdata(start_sampling + i,:);

    i = i + 1;
    row = row+1;
    
    if i == endSampling
       toggle = false;
    end
end

%% eye opened baseline: overlap check

sum(eyesOpenedBaseline(:,5)~=0)
overstep_check = find(eyesOpenedBaseline(:,5)~=0)
display_overstep = eyesOpenedBaseline(overstep_check,:)


%% eyes opened baseline : visual inspection

% display eyesOpenedBaseline
figure(2);
eoblength = 1:length(eyesOpenedBaseline);
eobRESP = eyesOpenedBaseline(:,1);
eobPPG = eyesOpenedBaseline(:,2);
eobECG = eyesOpenedBaseline(:,3);
eobEDA = eyesOpenedBaseline(:,4);
    
    % Plot respiration data
    eobax1 = nexttile;
    plot(eobax1, eoblength, eobRESP,'-','Color','b');
    title(eobax1, 'Respiration data');
    xlabel(eobax1, 'sample');
    ylabel(eobax1, 'value');
    
    % Plot PPG data
    eobax2 = nexttile;
    plot(eobax2, eoblength, eobPPG,'-','Color','k');
    title(eobax2, 'PPG data');
    xlabel(eobax2, 'sample');
    ylabel(eobax2, 'value');

    % Plot ECG data
    eobax3 = nexttile;
    plot(eobax3, eoblength, eobECG,'-','Color','r');
    title(eobax3, 'ECG data');
    xlabel(eobax3, 'sample');
    ylabel(eobax3, 'value');

    % Plot EDA data
    eobax4 = nexttile;
    plot(eobax4, eoblength, eobEDA,'-','Color','g');
    title(eobax4, 'EDA data');
    xlabel(eobax4, 'sample');
    ylabel(eobax4, 'value');
    
    
%% anticipation TSST phase

start_sampling = find(cutdata(:,5) == 87,1);
endSampling = 629334;
anticipationTSST = []; 
toggle = true;
i = 329334;
row = 1;

while toggle
    anticipationTSST (row, :) = cutdata(start_sampling + i,:);

    i = i + 1;
    row = row+1;
    
    if i == endSampling
       toggle = false;
    end
end

%% anticipationTSST: overlap check

sum(anticipationTSST(:,5)~=0)
overstep_check = find(anticipationTSST(:,5)~=0)
display_overstep = anticipationTSST(overstep_check,:)

%% anticipationTSST: visual inspection

% display anticipationTSST
figure(3);
atsstlength = 1:length(anticipationTSST);
atsstRESP = anticipationTSST(:,1);
atsstPPG = anticipationTSST(:,2);
atsstECG = anticipationTSST(:,3);
atsstEDA = anticipationTSST(:,4);
    
    % Plot respiration data
    atsstax1 = nexttile;
    plot(atsstax1, atsstlength, atsstRESP,'-','Color','b');
    title(atsstax1, 'Respiration data');
    xlabel(atsstax1, 'sample');
    ylabel(atsstax1, 'value');
    
    % Plot PPG data
    atsstax2 = nexttile;
    plot(atsstax2, atsstlength, atsstPPG,'-','Color','k');
    title(atsstax2, 'PPG data');
    xlabel(atsstax2, 'sample');
    ylabel(atsstax2, 'value');

    % Plot ECG data
    atsstax3 = nexttile;
    plot(atsstax3, atsstlength, atsstECG,'-','Color','r');
    title(atsstax3, 'ECG data');
    xlabel(atsstax3, 'sample');
    ylabel(atsstax3, 'value');

    % Plot EDA data
    atsstax4 = nexttile;
    plot(atsstax4, atsstlength, atsstEDA,'-','Color','g');
    title(atsstax4, 'EDA data');
    xlabel(atsstax4, 'sample');
    ylabel(atsstax4, 'value');
    
    

%% save the matrices in .mat

% BE CAREFUL to ALWAYS change the name of the file right after having 
% named the directory, otherwise it will override another file

% eyesClosedBaseline matrix                                                           change name here
save('M:\Catherine\XP VIBES\STUDY 1\ANALYSIS\CLEAN\PHYSIO\CUTDATA\V1\BASELINE EYES CLOSED\V031_V1_eyesClosedBaseline.mat', 'eyesClosedBaseline');

% eyesOpenedBaseline matrix                                                           change name here
save('M:\Catherine\XP VIBES\STUDY 1\ANALYSIS\CLEAN\PHYSIO\CUTDATA\V1\BASELINE EYES OPENED\V031_V1_eyesOpenedBaseline.mat', 'eyesOpenedBaseline');

% anticipationTSST matrix                                                     change name here
save('M:\Catherine\XP VIBES\STUDY 1\ANALYSIS\CLEAN\PHYSIO\CUTDATA\V1\ANTICIPATION\V031_V1_anticipationTSST.mat', 'anticipationTSST');

%% done