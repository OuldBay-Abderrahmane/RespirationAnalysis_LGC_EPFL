function respirationStatistics = data_analysis_respi_features_calculations(Bm, verbose)

%calculates features of respiratory data. Running this method assumes that 
% you have already derived all possible features

if nargin < 2
    verbose = 0;
end

if verbose == 1
    disp('Calculating secondary respiratory features')
end
breathingRate_tot = []; 
interBreathInterval_tot = []; 
avgInhaleVolume_tot = []; 
avgExhaleVolume_tot = []; 
avgTidalVolume_tot = []; 
minuteVentilation_tot = []; 

inhaleDutyCycle_tot = []; 
exhaleDutyCycle_tot = []; 

CVInhaleDuration_tot = [];
CVExhaleDuration_tot = [];

avgInhaleDuration_tot = [];
avgExhaleDuration_tot = [];

cvBreathingRate_tot = []; 
CVTidalVolume_tot = []; 

% loop through nValidIntervals so that we can get all features
for iInterval = 1:Bm.nValidIntervals
    %generate indexes of where the segment starts and stops
    currentSegmentIdxs = Bm.intervalStart(iInterval):Bm.intervalStop(iInterval);
    % generate proportion of the segment compared to the full length
    if Bm.nValidIntervals == 1
        currentSegmentProportion = 1;
    else
        currentSegmentProportion = (((numel(currentSegmentIdxs))*100/(Bm.intervalStop(end)))/100);
    end
    
% first find valid breaths

% edited 4/11/20
% split nBreaths into inhales and exhales to fix indexing error from 
% myPeak error in findRespiratoryExtrema

currentInhaleOnsets = find(Bm.inhaleOnsets > currentSegmentIdxs(1) & Bm.inhaleOnsets < currentSegmentIdxs(end));
currentExhaleOnsets = find(Bm.exhaleOnsets > currentSegmentIdxs(1) & Bm.exhaleOnsets < currentSegmentIdxs(end));
    
nInhales=length(currentInhaleOnsets);
nExhales=length(currentExhaleOnsets);
if isempty(Bm.statuses(currentSegmentIdxs))
    validInhaleInds=currentInhaleOnsets;
    validExhaleInds=currentExhaleOnsets;
else
    IndexInvalid = strfind(Bm.statuses(currentSegmentIdxs),'rejected');
    invalidBreathInds = find(not(cellfun('isempty',IndexInvalid)));
    validInhaleInds=setdiff(1:nInhales,invalidBreathInds);
    validExhaleInds=setdiff(1:nExhales,invalidBreathInds);
    if isempty(validInhaleInds)
        warndlg('No valid breaths found. If the status of a breath is set to ''rejected'', it will not be used to compute secondary features');
    end
end

nValidInhales=length(validInhaleInds);
nValidExhales=length(validExhaleInds);

%%% Breathing Rate %%%
% breathing rate is the sampling rate over the average number of samples 
% in between breaths.

% this is tricky when certain breaths have been rejected
breathDiffs=nan(1,1);
vbIter=1;
for i = 1:nValidInhales-1
    thisBreath=validInhaleInds(i);
    nextBreath=validInhaleInds(i+1);
    % if there is no rejected breath between these breaths, they can be
    % used to compute breathing rate.
    if nextBreath == thisBreath+1
        breathDiffs(1,vbIter)=Bm.inhaleOnsets(nextBreath)-Bm.inhaleOnsets(thisBreath);
        vbIter=vbIter+1;
    end
end

breathingRate = Bm.srate/mean(breathDiffs);
breathingRate = breathingRate*currentSegmentProportion;


%%% Inter-Breath Interval %%%
% inter-breath interval is the inverse of breathing rate
interBreathInterval = 1/breathingRate;
interBreathInterval = interBreathInterval*currentSegmentProportion;

%%% Coefficient of Variation of Breathing Rate %%% 
% this describes variability in time between breaths
cvBreathingRate = std(breathDiffs)/mean(breathDiffs);
cvBreathingRate = cvBreathingRate*currentSegmentProportion;

if strcmp(Bm.dataType,'humanBB')
    
    %%% Breath Volumes %%%
    % the volume of each breath is the integral of the airflow

    % inhales
    validInhaleVolumes=excludeOutliers(Bm.inhaleVolumes, validInhaleInds);
    avgInhaleVolume = mean(validInhaleVolumes);
    avgInhaleVolume = avgInhaleVolume*currentSegmentProportion;

    % exhales
    validExhaleVolumes=excludeOutliers(Bm.exhaleVolumes, validExhaleInds);
    avgExhaleVolume = mean(validExhaleVolumes);
    avgExhaleVolume = avgExhaleVolume*currentSegmentProportion;
    
    %%% Tidal volume %%%
    % tidal volume is the total air displaced by inhale and exhale
    avgTidalVolume = avgInhaleVolume + avgExhaleVolume;
    avgTidalVolume = avgTidalVolume*currentSegmentProportion;


    %%% Minute Ventilation %%%
    % minute ventilation is the product of respiration rate and tidal volume
    minuteVentilation = breathingRate * avgTidalVolume;
    minuteVentilation = minuteVentilation*currentSegmentProportion;


    %%% Duty Cycle %%%
    % duty cycle is the percent of each breathing cycle that was spent in
    % a phase
    
    % get avg duration of each phase
    avgInhaleDuration = nanmean(Bm.inhaleDurations);
    avgInhaleDuration = avgInhaleDuration*currentSegmentProportion;

    avgExhaleDuration = nanmean(Bm.exhaleDurations);
    avgExhaleDuration = avgExhaleDuration*currentSegmentProportion;

    % because pauses don't necessarily occur on every breath, multiply this
    % value by total number that occured.
%     pctInhalePause=sum(~isnan(Bm.inhalePauseDurations))/nValidInhales;
%     avgInhalePauseDuration = nanmean(Bm.inhalePauseDurations(validInhaleInds)) * pctInhalePause;
%     
%     pctExhalePause=sum(~isnan(Bm.exhalePauseDurations))/nValidExhales;
%     avgExhalePauseDuration = nanmean(Bm.exhalePauseDurations(validExhaleInds)) * pctExhalePause;

    inhaleDutyCycle = avgInhaleDuration / interBreathInterval;
    inhaleDutyCycle = inhaleDutyCycle*currentSegmentProportion;
%     inhalePauseDutyCycle = avgInhalePauseDuration / interBreathInterval;
    exhaleDutyCycle = avgExhaleDuration / interBreathInterval;
    exhaleDutyCycle = exhaleDutyCycle*currentSegmentProportion;
%     exhalePauseDutyCycle = avgExhalePauseDuration / interBreathInterval;

    CVInhaleDuration = nanstd(Bm.inhaleDurations)/avgInhaleDuration;
    CVInhaleDuration = CVInhaleDuration*currentSegmentProportion;
%     CVInhalePauseDuration = nanstd(Bm.inhalePauseDurations)/avgInhalePauseDuration;
    CVExhaleDuration = nanstd(Bm.exhaleDurations)/avgExhaleDuration;
    CVExhaleDuration = CVExhaleDuration*currentSegmentProportion;
%     CVExhalePauseDuration = nanstd(Bm.exhalePauseDurations)/avgExhalePauseDuration;

    % if there were no pauses, the average pause duration is 0, not nan
%     if isempty(avgInhalePauseDuration) || isnan(avgInhalePauseDuration)
%             avgInhalePauseDuration=0;
%     end
% 
%     if isempty(avgExhalePauseDuration) || isnan(avgExhalePauseDuration)
%             avgExhalePauseDuration=0;
%     end

    % coefficient of variation in breath size describes variability of breath
    % sizes
    CVTidalVolume = std(validInhaleVolumes)/mean(validInhaleVolumes);
    CVTidalVolume = CVTidalVolume*currentSegmentProportion;

    
end

% if strcmp(Bm.dataType,'humanAirflow') || strcmp(Bm.dataType,'rodentAirflow')
%     % the following features can only be computed for airflow data
%     
%     %%% Peak Flow Rates %%%
%     % the maximum rate of airflow at each inhale and exhale
%     
%     % inhales
%     validInhaleFlows=excludeOutliers(Bm.peakInspiratoryFlows, validInhaleInds);
%     avgMaxInhaleFlow = mean(validInhaleFlows);
%     
%     % exhales
%     validExhaleFlows=excludeOutliers(Bm.troughExpiratoryFlows, validExhaleInds);
%     avgMaxExhaleFlow = mean(validExhaleFlows);

% assigning values for output
    % compute corrected values according to proportion of the signal.
breathingRate_tot = sum([breathingRate_tot breathingRate]); 
interBreathInterval_tot = sum([interBreathInterval_tot interBreathInterval]); 
avgInhaleVolume_tot = sum([avgInhaleVolume_tot avgInhaleVolume]); 
avgExhaleVolume_tot = sum([avgExhaleVolume_tot avgExhaleVolume]); 
avgTidalVolume_tot = sum([avgTidalVolume_tot avgTidalVolume]);
minuteVentilation_tot = sum([minuteVentilation_tot minuteVentilation]);

inhaleDutyCycle_tot = sum([inhaleDutyCycle_tot inhaleDutyCycle]);
exhaleDutyCycle_tot = sum([exhaleDutyCycle_tot exhaleDutyCycle]); 

CVInhaleDuration_tot = sum([CVInhaleDuration_tot CVInhaleDuration]);
CVExhaleDuration_tot = sum([CVExhaleDuration_tot CVExhaleDuration]);

avgInhaleDuration_tot = sum([avgInhaleDuration_tot avgInhaleDuration]);
avgExhaleDuration_tot = sum([avgExhaleDuration_tot avgExhaleDuration]);

cvBreathingRate_tot = sum([cvBreathingRate_tot cvBreathingRate]);
CVTidalVolume_tot = sum([CVTidalVolume_tot CVTidalVolume]); 

if strcmp(Bm.dataType,'humanAirflow') || strcmp(Bm.dataType,'rodentAirflow')
    keySet= {
        'Breathing Rate';
        'Average Inter-Breath Interval';
        
        'Average Peak Inspiratory Flow';
        'Average Peak Expiratory Flow';
        
        'Average Inhale Volume';
        'Average Exhale Volume';
        'Average Tidal Volume';
        'Minute Ventilation';
        
        'Duty Cycle of Inhale';
        'Duty Cycle of Inhale Pause';
        'Duty Cycle of Exhale';
        'Duty Cycle of Exhale Pause';
        
        'Coefficient of Variation of Inhale Duty Cycle';
        'Coefficient of Variation of Inhale Pause Duty Cycle';
        'Coefficient of Variation of Exhale Duty Cycle';
        'Coefficient of Variation of Exhale Pause Duty Cycle';
        
        'Average Inhale Duration';
        'Average Inhale Pause Duration';
        'Average Exhale Duration';
        'Average Exhale Pause Duration';
        
        'Percent of Breaths With Inhale Pause';
        'Percent of Breaths With Exhale Pause';
        
        'Coefficient of Variation of Breathing Rate';
        'Coefficient of Variation of Breath Volumes';
        
        };

    valueSet={
        breathingRate; 
        interBreathInterval; 
        
        avgMaxInhaleFlow; 
        avgMaxExhaleFlow; 
        
        avgInhaleVolume; 
        avgExhaleVolume; 
        avgTidalVolume; 
        minuteVentilation; 
        
        inhaleDutyCycle; 
        inhalePauseDutyCycle; 
        exhaleDutyCycle; 
        exhalePauseDutyCycle; 
        
        CVInhaleDuration;
        CVInhalePauseDuration;
        CVExhaleDuration;
        CVExhalePauseDuration;
        
        avgInhaleDuration;
        avgInhalePauseDuration;
        avgExhaleDuration;
        avgExhalePauseDuration;
        
        pctInhalePause
        pctExhalePause;
        
        cvBreathingRate; 
        CVTidalVolume;
        };
elseif strcmp(Bm.dataType,'humanBB') || strcmp(Bm.dataType,'rodentThermocouple') 
    keySet= {
        'BreathingRate';
        'AverageInterBreathInterval';
        
        'AverageInhaleVolume';
        'AverageExhaleVolume';
        'AverageTidalVolume';
        'MinuteVentilation';
        
        'DutyCycleofInhale';
        'DutyCycleofExhale';
        
        'CoefficientofVariationofInhaleDutyCycle';
        'CoefficientofVariationofExhaleDutyCycle';
        
        'AverageInhaleDuration';
        'AverageExhaleDuration';
        
        'CoefficientofVariationofBreathingRate';
        'CoefficientofVariationofBreathVolumes';

        };
    valueSet={
        breathingRate_tot; 
        interBreathInterval_tot; 
        avgInhaleVolume_tot; 
        avgExhaleVolume_tot; 
        avgTidalVolume_tot; 
        minuteVentilation_tot; 
        
        inhaleDutyCycle_tot; 
        exhaleDutyCycle_tot; 
        
        CVInhaleDuration_tot;
        CVExhaleDuration_tot;
        
        avgInhaleDuration_tot;
        avgExhaleDuration_tot;
        
        cvBreathingRate_tot; 
        CVTidalVolume_tot; 
        };
end

respirationStatistics = containers.Map(keySet,valueSet);

if verbose == 1
    disp('Secondary Respiratory Features')
    for this_key = 1:length(keySet)
        fprintf('%s : %0.5g', keySet{this_key},valueSet{this_key});
        fprintf('\n')
    end
end
end
end

function validVals=excludeOutliers(origVals,validBreathInds)
    
    % rejects values exceeding 2 stds from the mean
    
    upperBound=nanmean(origVals) + 2 * nanstd(origVals);
    lowerBound=nanmean(origVals) - 2 * nanstd(origVals);
    
    validValInds = find(origVals(origVals > lowerBound & origVals < upperBound));
    
    validVals = origVals(intersect(validValInds, validBreathInds));
    
end
