function [interpolatedData, badSamplesIndex, NSatClusters, NNaNClusters, NInterpClusters, sampleStatus] = interpol_1d_data_no_oversaturation(rawData, saturationThresholds, dispInterp)
%[interpolatedData, interpolIndex] = interpol_1d_data_no_oversaturation_peaks_window_length(rawData, saturationThresholds, dispInterp)
% interpol_1d_data_no_oversaturation_peaks_window_length will interpolate the 1D data inside the rawData vector
% based on the lower and upper thresholds defined in saturationThresholds.
% The function will also apply interpolation on missing data if those data
% are indicated by NaN values.
%
% INPUTS
% rawData: 1D data containing samples to interpolate (either because empty
% data or because saturated data)
%
% saturationThresholds: [x1 x2] = [lower and higher] thresholds defining
% saturation in rawData values
%
% dispInterp: display interpolated data and original data (1) or no figure
% at all (0)
%
% OUTPUTS
% dataInterpolated: 1D data same size as rawData entered in inputs but with
% bad samples replaced by interpolated data
%
% interpolIndex: index of the samples that were replaced by interpolated
% data
%
% NSatClusters: number of saturated clusters
% NNaNClusters: number of clusters that were NANified
% NInterpClusters: number of clusters that were interpolated
%

%% extract field from structure
% firstField = fieldnames(rawDataStruct)
% rawData = rawDataStruct.(firstField{1});

%% extract index for all sample
% nSamples = length(rawData);
% x = 1:nSamples;

%% extract thresholds for saturation
lowThreshold = saturationThresholds(1);
highThreshold = saturationThresholds(2);

%% FORCING SATURATION ON ALL NON VALID DATA
forcedSaturation = rawData;
highSat_idx = (forcedSaturation >= highThreshold);
forcedSaturation (highSat_idx) = highThreshold;
lowSat_idx = (forcedSaturation <= lowThreshold);
forcedSaturation (lowSat_idx) = lowThreshold;

%% ADD TWO SAMPLES BEFORE AND AFTER THE ACTUAL DATA 
% This step is necessary to avoid getting infinite values at the beginning
% and the end of the dataset when interpolation is run
    % midstep1_vectorForInterp =(zeros(1,nSamples))';
    % midstep2_vectorForInterp = [midstep1_vectorForInterp forcedSaturation midstep1_vectorForInterp];
    % bigVectorForInterp = midstep2_vectorForInterp(nSamples-1:(2*nSamples)+2)';
bigVectorForInterp = [0 0 forcedSaturation' 0 0];
nSamplesForSat = length(bigVectorForInterp);

%% DEFINE SAMPLES WHERE SATURATION HAPPENS
[badSamplesNaN, badSamplesSaturation] = deal(zeros(1,nSamplesForSat));
for iSample = 1:nSamplesForSat
    
    %% . PUT MARKERS ON ALL MISSING SAMPLES
    if isnan(bigVectorForInterp(iSample))
        badSamplesNaN(iSample) = 1;
    end
    
    %% . PUT MARKERS ON SAMPLES REACHING SATURATION (at lower or at higher threshold)
    if (bigVectorForInterp(iSample) == highThreshold) ||...
            (bigVectorForInterp(iSample) == lowThreshold)
            badSamplesSaturation(iSample) = 1;
    end
end % loop through all samples

%% PUT MARKERS ON SAMPLES THAT NEED TO BE NANIFIED

    %% . LOCATING CLUSTERS
% indexes of where the bad samples are located (ie. 200th-250th pt)
badSamplesIndex = find(badSamplesSaturation | badSamplesNaN);

% calculate derivative to the number of samples the saturation lasted
interpolIndexDerivative = diff(badSamplesSaturation);

% find where(=at which samples) the clusters start and stop
clusterStart = find(interpolIndexDerivative == 1)+1;
clusterStop = find(interpolIndexDerivative == -1);

%if ~isempty(clusterStart) && ~isempty(clusterStop) 
    
if abs(length(clusterStart) - length(clusterStop)) == 1
% remove first/last stops/starts if needed, this should never happen given
% that I added two poitns at both extremities
    if length(clusterStart) > length(clusterStop)
        clusterStart = clusterStart(1:end-1);
    elseif length(clusterStart) < length(clusterStop)
        clusterStop = clusterStop(2:end);
    end
elseif abs(length(clusterStart) - length(clusterStop)) > 1
    error('cluster length sucks.')
end

% collect all normal cycles
idxs = 1:length(bigVectorForInterp);

if length(clusterStart) ~= length(clusterStop) % Sanity check
errormsg = 'clusterStart and clusterStop are not the same length';
error(errormsg);
end

all_freqs = [];

    %% . LOCATE WINDOWS BEFORE AND AFTER EACH CLUSTER
for iCluster = 1:length(clusterStart)
    %% . . REMOVE SATURATIONS AT THE BEGINNING AND AT THE END IF NEEDED
    if iCluster == 1
        if clusterStart(1) < 500
           % Do not interpolate those, write a NaN marker for them
           badSamplesNaN(clusterStart(iCluster):clusterStop(iCluster)) = 1;
           badSamplesSaturation(clusterStart(iCluster):clusterStop(iCluster)) = 0;             
        end   

    elseif iCluster == length(clusterStart)
        if clusterStop(end) > length(bigVectorForInterp)-500
           % Do not interpolate those, write a NaN marker for them
           badSamplesNaN(clusterStart(iCluster):clusterStop(iCluster)) = 1;
           badSamplesSaturation(clusterStart(iCluster):clusterStop(iCluster)) = 0;    
        end
        
    %% . . ALL OTHER CASES
    else
    %% . . . WINDOWS FOR SATURATIONS ON HIGH THRESHOLDS
        if bigVectorForInterp(clusterStart(iCluster)+1) == highThreshold
        abnormalInterv = bigVectorForInterp(clusterStart(iCluster):clusterStop(iCluster));
        clusterL = length(abnormalInterv);
    
        [~, pks_locs_start] = findpeaks(bigVectorForInterp(1:clusterStart(iCluster)));
        [~, pks_locs_end] = findpeaks(bigVectorForInterp((clusterStop(iCluster)+1):end));
    
%     pks_start_saturated_high = pks_locs_start(pks_start == 1.97);
%     pks_start_saturated_low = pks_locs_start(pks_start == -4.89);
%     pks_end_saturated_high = pks_locs_end(pks_end == 1.97);
%     pks_end_saturated_low = pks_locs_end(pks_end == -4.89);
 
%     pks_locs_start(pks_start_saturated_high) = length(abnormalInterv)/2;
%     pks_locs_start(pks_start_saturated_low) = length(abnormalInterv)/2;
%     pks_locs_end(pks_end_saturated_high) =
%     clusterStart(pks_locs_end(pks_end_saturated_low))+length(clusterStart(pks_locs_end(pks_end_saturated_low)):clusterStop();
%     pks_locs_end(pks_end_saturated_low) = clusterStart();
     
            if isempty(pks_locs_start)
                pks_locs_start(1) = 0;
            end

            if isempty(pks_locs_end)
                pks_locs_end(1) = 0;
            end

            if length(pks_locs_start) < 4
                window_size_start = 1;
            else
                window_size_start = pks_locs_start(end-3);  % -3 because end is counted as first element
            end

            if length(pks_locs_end) < 4
                window_size_end = length(bigVectorForInterp);
            else
                window_size_end = clusterStop(iCluster) + pks_locs_end(4); % we have to include clusterStop(iCluster here because pks_locs_end start from the clusterStop(iCluster), if we remove it we will not take the correct samples into account
            end
    
            all_freqs = [all_freqs, clusterL];
    
    %% . . . WINDOW FOR SATURATIONS ON LOW THRESHOLDS
        elseif bigVectorForInterp(clusterStart(iCluster)+1) == lowThreshold
        abnormalInterv = bigVectorForInterp(clusterStart(iCluster):clusterStop(iCluster));
        clusterL = length(abnormalInterv);
    
        [~, trs_locs_start] = findpeaks(-bigVectorForInterp(1:clusterStart(iCluster)));
        [~, trs_locs_end] = findpeaks(-bigVectorForInterp((clusterStop(iCluster)+1):end));
        
            if isempty(trs_locs_start)
                trs_locs_start(1) = 0;
            end
        
            if isempty(trs_locs_end)
                trs_locs_end(1) = 0;
            end
    
            if length(trs_locs_start) < 4
                window_size_start = 1;
            else
                window_size_start = trs_locs_start(end-3);  % -3 because end is counted as first element
            end
    
            if length(trs_locs_end) < 4
                window_size_end = length(bigVectorForInterp);
            else
                window_size_end = clusterStop(iCluster) + trs_locs_end(4); % we have to include clusterStop(iCluster here because pks_locs_end start from the clusterStop(iCluster), if we remove it we will not take the correct samples into account
            end
    
            all_freqs = [all_freqs, clusterL];
            
        else
            errormsg2 = 'saturation is happening at another threshold than the usual high and low thresholds.';
            error(errormsg2);
        end
        
    %% . MARK SAMPLES THAT SHOULD BE NANIFIED
    %% . . CONSIDER VALUES INSIDE THE WINDOW: REFRAME IF CONTAINS NAN
    
        wdwBefore = bigVectorForInterp(window_size_start:clusterStart(iCluster));
% ATTEMPT TO TELL IT TO NOT INCLUDE NANS IN THE WINDOWS BEFORE AND AFTER,
% BUT IT DOES NOT MAKE SENSE, BECAUSE RECONSTRUCTION IS BASED ON THIS. I'LL
% COME BACK TO IT IF POSSIBLE
%         index_modif_pks_locs = 0;
%      
%         if (sum(find(wdwBefore == highThreshold))/sum(find ...
%                 (wdwBefore == highThreshold)) == 1) || ...
%                 (sum(find(wdwBefore == lowThreshold))/sum(find ...
%                 (wdwBefore == lowThreshold)) == 1)
%             wdwBefore_earliestNAN = 5 - find((wdwBefore == highThreshold),1);
%             index_modif_pks_locs = index_modif_pks_locs + wdwBefore_earliestNAN;               
%             window_size_start = pks_locs_start(end-3-index_modif_pks_locs);
%             wdwBefore = bigVectorForInterp(window_size_start:clusterStart(iCluster));
%         end

        wdwBeforeL = length(wdwBefore);
        wdwBeforeL_cycle = wdwBeforeL/3;
        wdwBeforeStd = std(wdwBefore);
    
        wdwAfter = bigVectorForInterp(clusterStop(iCluster):window_size_end);
        wdwAfterL = length(wdwAfter);
        wdwAfterL_cycle = wdwAfterL/3;
        wdwAfterStd = std(wdwAfter);
    
        if window_size_start < 4
            if clusterL > 1.25*wdwAfterL_cycle
            % Do not interpolate those, write a NaN marker for them
             badSamplesNaN(clusterStart(iCluster):clusterStop(iCluster)) = 1;
             badSamplesSaturation(clusterStart(iCluster):clusterStop(iCluster)) = 0;
            end
    
        elseif window_size_end < 4
            if clusterL > 1.25*wdwBeforeL_cycle
                % Do not interpolate those, write a NaN marker for them
                badSamplesNaN(clusterStart(iCluster):clusterStop(iCluster)) = 1;
                badSamplesSaturation(clusterStart(iCluster):clusterStop(iCluster)) = 0;
            end
    
        else
            if clusterL > 1.25*max(wdwBeforeL_cycle, wdwAfterL_cycle)
            % Do not interpolate those, write a NaN marker for them
            badSamplesNaN(clusterStart(iCluster):clusterStop(iCluster)) = 1;
            badSamplesSaturation(clusterStart(iCluster):clusterStop(iCluster)) = 0;
%       else  % useless to specify?
%           badSamples(clusterStart(iCluster):clusterStop(iCluster)) = true;
%           bigVectorForInterp(clusterStart(iCluster):clusterStop(iCluster)) = nan;

%           a = bigVectorForInterp(wdw_start:wdw_end);
%           b = a;
%           x = 1:length(a);
%           a(isnan(a)) = interp1(x(~isnan(a)), a(~isnan(a)), x(isnan(a)), 'spline') ;
%           bigVectorForInterp(wdw_start:wdw_end) = a;
            end
        end
    end
end

NSatClusters = ['Number of saturated clusters: ', num2str(length(clusterStop)/3)];

%% NANIFICATION OF SAMPLES MARKED
% define samples that need to be overwritten with nan
samplesToBeNAN = find(badSamplesNaN == 1);
% visual check of NANification
if  isempty(samplesToBeNAN)
    NNaNClusters = 'Number of samples that were NANified: 0';
else 
    NNaNClusters = ['Number of samples that were NANified: ', num2str(sum(samplesToBeNAN)/3)];
end
% NANify all samples that need to be NANified
bigVectorForInterp(samplesToBeNAN) = NaN;
% turn marker off to 0 so that it does not mess up the interpolation later
badSamplesSaturation(samplesToBeNAN) = 0;
isolatingInterpMarkers = false(1,nSamplesForSat); % needed to be a logical data type
isolatingInterpMarkers(badSamplesSaturation == 0) = false;
isolatingInterpMarkers(badSamplesSaturation == 1) = true;
NInterpClusters = ['Number of samples that were interpolated: ', num2str(sum(isolatingInterpMarkers)/3)];

%% INTERPOLATION OF SAMPLES MARKED 1 IN badSamplesSaturation
% define bad samples
samplesToBeInterpolated = find(isolatingInterpMarkers == 1);
% define good samples (ie where no interpolation is needed)
goodSamples = 1:nSamplesForSat;
% remove all bad samples
goodSamples(isolatingInterpMarkers) = [];
% perform the interpolation
interpDataSamples = interp1(goodSamples,...
    bigVectorForInterp(goodSamples),samplesToBeInterpolated,'spline');
% replace bad samples by interpolated data
bigVectorDataInterpolated = NaN(1,nSamplesForSat);
bigVectorDataInterpolated(goodSamples) = bigVectorForInterp(goodSamples);
bigVectorDataInterpolated(isolatingInterpMarkers) = interpDataSamples;
    
    %% . REMOVE ADDITIONAL DATA POINTS
% doing this will remove the added data points that should not be
% part of the analysis.
interpolatedData = bigVectorDataInterpolated(3:end-2);

    %% . INDICATE STATUS OF EACH SAMPLE
sampleStatus = cell(1, length(interpolatedData));
sampleStatus(isnan(interpolatedData)) = {'rejected'};
sampleStatus(~isnan(interpolatedData)) = {'valid'};
sampleStatus = sampleStatus';

%% DISPLAY ORIGINAL V. INTERPOLATED DATA
if dispInterp == 1
%     figure;
%     % display original data
%     plot(x, forcedSaturation,'-','Color','k');
%        hold on;
    % display interpolated data
%     figure(2);
    plot(1:length(interpolatedData), interpolatedData,'-','Color','r');
    
    legend('forcedSaturation', 'interpolatedData');
    
end % display data
end % function