function [interpolatedData, interpolIndex] = interpol_1d_data_no_oversaturation_peaks_window_meanfreq(rawData, saturationThresholds, dispInterp)
%[dataInterpolated, interpolIndex] = interpol_1d_data(rawData, saturationThresholds)
% interpol_1d_data will interpolate the 1D data inside the rawData vector
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

%% extract field from structure
% firstField = fieldnames(rawDataStruct)
% rawData = rawDataStruct.(firstField{1});

%% extract index for all sample
nSamples = length(rawData);
x = 1:nSamples;

%% extract thresholds for saturation
lowThreshold = saturationThresholds(1);
highThreshold = saturationThresholds(2);

%% FORCING SATURATION ON ALL NON VALID DATA
forcedSaturation = rawData;
highSat_idx = (forcedSaturation > highThreshold);
forcedSaturation (highSat_idx) = highThreshold;
lowSat_idx = (forcedSaturation < lowThreshold);
forcedSaturation (lowSat_idx) = lowThreshold;

%% ADD SYMETRIC BEFORE AND AFTER THE ACTUAL DATA 
% This step is necessary to avoid getting infinite values at the beginning
% and the end of the dataset when interpolation is run
bigVectorForInterp = [forcedSaturation(end:(-1):1);...
    forcedSaturation;
    forcedSaturation(end:(-1):1)];
nSamplesForSat = length(bigVectorForInterp);

%% define samples where saturation happens
badSamples = zeros(1,nSamplesForSat);
saturationNow_tmp = 0;
for iSample = 1:nSamplesForSat
    %% put a marker on all missing samples
    if isnan(bigVectorForInterp(iSample))
        badSamples(iSample) = -1;
    end
    
    %% put a marker on samples reaching saturation (at lower or at higher threshold)
    if (bigVectorForInterp(iSample) == highThreshold) ||...
            (bigVectorForInterp(iSample) == lowThreshold)
            badSamples(iSample) = 1;
    end
end % loop through all samples


%% PUTTING MARKERS ON SAMPLES THAT NEED TO BE NANIFIED

% indexes of where the bad samples are located (ie. 200th-250th pt)
interpolIndex = find(badSamples);

% calculate derivative to the number of samples the saturation lasted
interpolIndexDerivative = diff(badSamples);

% find where(=at which samples) the clusters start and stop
clusterStart = find(interpolIndexDerivative == 1);
clusterStop = find(interpolIndexDerivative == -1);

if ~isempty(clusterStart) && ~isempty(clusterStop) 
    
% remove first/last stops/starts if needed
if length(clusterStart) > length(clusterStop)
    clusterStart = clusterStart(1:end-1);
    
elseif length(clusterStart) < length(clusterStop)
    clusterStop = clusterStop(2:end);
    
end

% collect all normal cycles
idxs = 1:length(bigVectorForInterp);

assert(length(clusterStart) == length(clusterStop)); % Sanity check

normalCycles = (bigVectorForInterp(1:clusterStart(1)));

disp(['Number of saturated clusters: ', num2str(length(clusterStop))]);


for i = 1:length(clusterStop)-1
    normalCycles = {normalCycles; bigVectorForInterp(clusterStop(i):clusterStart(i+1))};
end

normalCycles = {normalCycles; bigVectorForInterp(clusterStop(end):length(bigVectorForInterp))};

% DETERMINE WINDOW SIZE

% window_size = 3000; fixed window size code if needed

pks_start = [];
pks_end = [];

pks_locs_start = zeros(1,length(nSamplesForSat));
pks_locs_end = zeros(1,length(nSamplesForSat));

% [peaksValues, peaksLocations] = findpeaks(bigVectorForInterp);

all_freqs = [];

for iCluster = 2:length(clusterStart)-1
    abnormalInterv = bigVectorForInterp(clusterStart(iCluster):clusterStop(iCluster));
    figure(2);
    hold on;
    if clusterStart(iCluster) > 821829/3 && clusterStart(iCluster)<2*821829/3
        scatter(clusterStart(iCluster)/1000-821829/3000,bigVectorForInterp(clusterStart(iCluster)), 50,...
            'o','filled','MarkerEdgeColor','k','MarkerFaceColor','k','LineWidth',3);
    end
    clusterF = 1/length(abnormalInterv);
    
    [pks_start, pks_locs_start] = findpeaks(bigVectorForInterp(1:clusterStart(iCluster)));
    [pks_end, pks_locs_end] = findpeaks(bigVectorForInterp(clusterStop(iCluster):end));
    
%     pks_start_saturated_high = pks_locs_start(pks_start == 1.97);
%     pks_start_saturated_low = pks_locs_start(pks_start == -4.89);
%     pks_end_saturated_high = pks_locs_end(pks_end == 1.97);
%     pks_end_saturated_low = pks_locs_end(pks_end == -4.89);
 
%     pks_locs_start(pks_start_saturated_high) = length(abnormalInterv)/2;
%     pks_locs_start(pks_start_saturated_low) = length(abnormalInterv)/2;
%     pks_locs_end(pks_end_saturated_high) = clusterStart(pks_locs_end(pks_end_saturated_low))+length(clusterStart(pks_locs_end(pks_end_saturated_low)):clusterStop()
%     pks_locs_end(pks_end_saturated_low) = clusterStart()
     
    if length(pks_locs_start) < 5
       window_size_start = clusterStart(iCluster) - clusterStart(iCluster)+1;
    else
       window_size_start = pks_locs_start(end-4);  % -4 because end is counted as first element
    end
    
    if length(pks_locs_end) < 5
       window_size_end = length(bigVectorForInterp);
    else
       window_size_end = clusterStop(iCluster) + pks_locs_end(5); % we have to include clusterStop(iCluster here because pks_locs_end start from the clusterStop(iCluster), if we remove it we will not take the correct samples into account
    end
    
    all_freqs = [all_freqs, clusterF];
    
    % Take last normal block
    % TODO: ensure that each block is sufficiently long
       
%     if clusterStart(iCluster) > window_size_start
%        wdw_start = clusterStart(iCluster) - window_size_start;   
%     else
%        wdw_start = clusterStart(iCluster) - clusterStart(iCluster)+1;  
%     end
%         
%     if clusterStop(iCluster) < length(bigVectorForInterp) - window_size_end
%        wdw_end = clusterStop(iCluster) + window_size_end;
%     else
%        wdw_end = clusterStop(iCluster) + length (bigVectorForInterp)+1;
%     end
%     
    wdwBefore = bigVectorForInterp(window_size_start:clusterStart(iCluster));
%     if isnan(wdwBefore)
%        wdwBeforeF = meanfreq(wdwBefore(~isnan(wdwBefore)));
%     else
    wdwBeforeF = meanfreq(wdwBefore);  
%     end
    wdwBeforeStd = std(wdwBefore);
    
    wdwAfter = bigVectorForInterp(clusterStop(iCluster):window_size_end);
    wdwAfterF = meanfreq(wdwAfter);
    wdwAfterStd = std(wdwAfter);
    
%     if  bigVectorForInterp(clusterStart(1)) == bigVectorForInterp(1(:)) ...
%         || bigVectorForInterp(clusterStop(end)) == bigVectorForInterp(end(:))
%         % erase these added symetric samples from the vector that constitute
%         % a problematic cluster
%         bigVectorForInterp = ~bigVectorForInterp(clusterStart(1): clusterStop(1))
        
    if  clusterF < 0.5*min(wdwBeforeF, wdwAfterF) 
%           ... && length(abnormalInterv) > 1 + max(wdwBeforeStd, wdwAfterStd) 
        % Do not interpolate those
        badSamples(clusterStart(iCluster):clusterStop(iCluster)) = -1;
            
%     else  % useless to specify?
%         badSamples(clusterStart(iCluster):clusterStop(iCluster)) = true;
%         bigVectorForInterp(clusterStart(iCluster):clusterStop(iCluster)) = nan;

%        count_normal = count_normal + 1;
        
%         disp(['interpolable: ', num2str(count_normal), '(', num2str(iCluster), ')'])
%         disp(clusterStart(iCluster));
%         disp(clusterStop(iCluster));


%         a = bigVectorForInterp(wdw_start:wdw_end);
%         b = a;
%         x = 1:length(a);
%         a(isnan(a)) = interp1(x(~isnan(a)), a(~isnan(a)), x(isnan(a)), 'spline') ;
%         bigVectorForInterp(wdw_start:wdw_end) = a;
        
%         if iCluster == 89
%         
%             figure;
%             plot((-window + clusterStart(iCluster) + (1:length(b)))/1000, b, 'k.-')
%             hold on;
%             plot((-window + clusterStart(iCluster) + (1:length(b)))/1000,a, 'r')
% 
%             legend('before', 'after')
% 
%             % plot(bigVectorForInterp(clusterStart(iCluster):clusterStop(iCluster)))
%             hold on;
%         end
    end
    
end

%% NANIFICATION OF SAMPLES MARKED -1
% define samples that need to be overwritten with nan
samplesToBeNAN = find(badSamples == -1);
% visual check of NANification
disp(['Number of samples that were NANified: ', num2str(sum(samplesToBeNAN))])
% NANify all samples that need to be NANified
bigVectorForInterp(samplesToBeNAN) = nan;
% turn marker off to 0 so that it does not mess up the interpolation later
badSamples(samplesToBeNAN) = 0;
isolatingInterpMarkers = false(1,nSamplesForSat); % needed to be a logical data type
isolatingInterpMarkers(badSamples == 0) = false;
isolatingInterpMarkers(badSamples == 1) = true;

%% INTERPOLATION OF SAMPLES MARKED 1
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
    
%% remove the added symetric data points on both ends
% doing this enables will remove the added data points that should not be
% part of the analysis.
interpolatedData = bigVectorDataInterpolated(nSamples+(1:nSamples));

%% display original vs interpolated  data
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

else
    disp(['Number of saturated clusters: ', num2str(length(clusterStop))]);
    interpolatedData = rawData;
end % function