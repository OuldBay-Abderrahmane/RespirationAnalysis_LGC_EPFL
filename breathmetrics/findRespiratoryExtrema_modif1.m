function [correctedPeaks, correctedTroughs, validIntervalStart, validIntervalStop, nValidIntervals] = findRespiratoryExtrema_modif1( ...
    resp, srate, sampleStatus, customDecisionThreshold, swSizes)
%FIND_RESPIRATORY_PEAKS Finds peaks and troughs in respiratory data
%   resp : 1:n vector of respiratory trace
%   srate : sampling rate of respiratory trace
%   sw_sizes (OPTIONAL) : array of windows to use to find peaks. Default
%   values are sizes that work well for human nasal respiration data.
sampleStatus = sampleStatus';

valid_idx = (sampleStatus == "valid");
sampleStatus = valid_idx;

if nargin < 4
    srateAdjust = srate/1000;
    swSizes = [floor(100*srateAdjust),floor(300*srateAdjust), ...
        floor(700*srateAdjust), floor(1000*srateAdjust), ...
        floor(5000*srateAdjust)];
end

if nargin < 3
    customDecisionThreshold = 0;
end

% pad end with zeros to include tail of data missed by big windows
% otherwise
% padInd = min([length(resp)-1,max(swSizes)*2]);
% paddedResp = [resp, fliplr(resp(end-padInd:end))];

paddedResp = resp;

%initializing vector of all points where there is a peak or trough.
swPeakVect = zeros(1, size(paddedResp, 2));
swTroughVect = zeros(1, size(paddedResp, 2));

% identify if there is nan on the signal
if numel(find(sampleStatus==0))> 0
% calculate derivative to find where NAN clusters start and stop
    NANClusterIndexDerivative = diff(sampleStatus);
    NANClusterStarts = find(NANClusterIndexDerivative == -1)+1;
    NANClusterStops = find(NANClusterIndexDerivative == 1);
    nNANClusters = length(NANClusterStarts);
    nValidIntervals = nNANClusters +1;
    validIntervalStart = [1 NANClusterStarts];
    validIntervalStop = [NANClusterStops length(paddedResp)];
else
    nValidIntervals = 1;
    validIntervalStart = 1;
    validIntervalStop = length(paddedResp);
end 
% Adapt if needed, otherwise remove.
% if abs(length(clusterStart) - length(clusterStop)) == 1
% % remove first/last stops/starts if needed, this should never happen given
% % that I added two poitns at both extremities
%     if length(clusterStart) > length(clusterStop)
%         clusterStart = clusterStart(1:end-1);
%     elseif length(clusterStart) < length(clusterStop)
%         clusterStop = clusterStop(2:end);
%     end
% elseif abs(length(clusterStart) - length(clusterStop)) > 1
%     error('cluster length sucks.')
% end
correctedPeaks = [];
correctedTroughs = [];

toggle = true;
iInterval = 1;

    % find peaks and troughs that alternate in each vector created from the
    % full original signal that contains nan
    while toggle
        paddedRespInterval = paddedResp(validIntervalStart(iInterval):validIntervalStop(iInterval));

        if (numel(paddedRespInterval) <= 7000)
            if nValidIntervals == 1
                validIntervalStart = [];
                validIntervalStop = [];
            elseif nValidIntervals == 2
                if iInterval == 1
                    validIntervalStart = validIntervalStart(2);
                    validIntervalStop = validIntervalStop(2);
                else
                    validIntervalStart = validIntervalStart(1);
                    validIntervalStop = validIntervalStop(1);
                end
            else
                if iInterval == 1
                    validIntervalStart = [validIntervalStart(iInterval+1) validIntervalStart(length(validIntervalStart))];
                    validIntervalStop = [validIntervalStop(iInterval+1) validIntervalStop(length(validIntervalStop))];
                elseif iInterval == nValidIntervals
                    validIntervalStart = [validIntervalStart(1) validIntervalStart(iInterval-1)];
                    validIntervalStop = [validIntervalStop(1) validIntervalStop(iInterval-1)];
                else
                    validIntervalStart = [validIntervalStart(1:(iInterval-1)) validIntervalStart((iInterval+1):(length(validIntervalStart)))];
                    validIntervalStop = [validIntervalStop(1:(iInterval-1)) validIntervalStop((iInterval+1):(length(validIntervalStop)))];
                end
            end
            nValidIntervals = nValidIntervals-1;
            assert(numel(validIntervalStart) == numel(validIntervalStop), "number of elements in validIntervalStart and validIntervalStop is inconsistent.");
            assert(numel(validIntervalStart) == nValidIntervals, "number of elements in validIntervalStart is inconsistent with number of valid intervals (nValidIntervals)");
        else 
        
        % peaks and troughs must exceed this value. Sometimes algorithm finds mini
        % peaks in flat traces
        peakThreshold = mean(resp(1,:),'omitnan') + nanstd(resp(1,:)) / 2;
        troughThreshold = mean(resp(1,:),'omitnan') - nanstd(resp(1,:)) / 2;

        % shifting window to be unbiased by starting point
        SHIFTS = 1:3;
        nWindows=length(swSizes)*length(SHIFTS);

        % find maxes in each sliding window, in each shift, and return peaks that
        % are agreed upon by majority windows.

        % find extrema in each window of the data using each window size and offset
        for win = 1:length(swSizes)

            sw = swSizes(win);
            % cut off end of data based on sw size
            nIters  = floor(length(paddedRespInterval) / sw)-1; 

            for shift = SHIFTS
                % store maxima and minima of each window
                argmaxVect = zeros(1, nIters);
                argminVect = zeros(1, nIters);

                %shift starting point of sliding window to get unbiased maxes
                windowInit = (sw - floor(sw / shift)) + 1;

                % iterate by this window size and find all maxima and minima
                windowIter=windowInit;
                for i = 1:nIters
                    thisWindow = paddedRespInterval(1, windowIter:windowIter + sw - 1);
                    [maxVal,maxInd] = max(thisWindow);

                    % make sure peaks and troughs are real.
                    if maxVal > peakThreshold
                        % index in window + location of window in original resp time
                        argmaxVect(1,i)=windowIter + maxInd-1;
                    end
                    [minVal,minInd] = min(thisWindow);
                    if minVal < troughThreshold
                        % index in window + location of window in original resp time
                        argminVect(1,i)=windowIter+minInd-1;
                    end
                    windowIter = windowIter + sw;
                end
                % add 1 to consensus vector
                swPeakVect(1, nonzeros(argmaxVect)) = ...
                    swPeakVect(1,nonzeros(argmaxVect)) + 1;
                swTroughVect(1, nonzeros(argminVect)) = ...
                    swTroughVect(1, nonzeros(argminVect)) + 1;
            end
        end


        % find threshold that makes minimal difference in number of extrema found
        % similar idea to knee method of k-means clustering

        nPeaksFound = zeros(1, nWindows);
        nTroughsFound = zeros(1, nWindows);
        for threshold_ind = 1:nWindows
            nPeaksFound(1, threshold_ind) = sum(swPeakVect > threshold_ind);
            nTroughsFound(1, threshold_ind) = sum(swTroughVect > threshold_ind);
        end

        [~,bestPeakDiff] = max(diff(nPeaksFound));
        [~,bestTroughDiff] = max(diff(nTroughsFound));


        bestDecisionThreshold = floor(mean([bestPeakDiff, bestTroughDiff]));


        % % temporary peak inds. Eacy point where there is a real peak or trough
        peakInds = find(swPeakVect >= bestDecisionThreshold);
        troughInds = find(swTroughVect >= bestDecisionThreshold);


        % sometimes there are multiple peaks or troughs in series which shouldn't 
        % be possible. This loop ensures the series alternates peaks and troughs.

        % first we must find the first peak
        offByN = 1;
        tri = 1;
        while offByN
            if isempty(peakInds) || isempty(troughInds)
                offByN=0;
            elseif peakInds(tri)> troughInds(tri)
                troughInds = troughInds(1, tri + 1:end);
            else
                offByN=0;
            end
        end

        correctedPeaks_tmp = [];
        correctedTroughs_tmp = [];

        pki=1; % peak ind
        tri=1; % trough ind

        % variable to decide whether to record peak and trough inds.
        proceedCheck = 1;

            % find peaks and troughs that alternate
        while pki <length(peakInds)-1 && tri<length(troughInds)-1

            % time difference between peak and next trough
            peakTroughDiff = troughInds(tri) - peakInds(pki);

            % check if two peaks in a row
            peakPeakDiff = peakInds(pki+1) - peakInds(pki);

            if peakPeakDiff < peakTroughDiff
                % if two peaks in a row, take larger peak
                [~, nxtPk] = max([paddedRespInterval(peakInds(pki)), ...
                    paddedRespInterval(peakInds(pki+1))]);
                if nxtPk == 1
                    % forget this peak. keep next one.
                    pki = pki+1;
                else
                    % forget next peak. keep this one.
                    peakInds = setdiff(peakInds, peakInds(1, pki+1));
                end
                % there still might be another peak to remove so go back and check
                % again
                proceedCheck=0;
            end

            % if the next extrema is a trough, check for trough series
            if proceedCheck == 1

                % check if trough is after this trough.
                troughTroughDiff = troughInds(tri + 1) - troughInds(tri);
                troughPeakDiff = peakInds(pki + 1) - troughInds(tri);

                if troughTroughDiff < troughPeakDiff
                    % if two troughs in a row, take larger trough
                    [~, nxtTr] = min([paddedRespInterval(troughInds(tri)), ...
                        paddedRespInterval(troughInds(tri + 1))]);
                    if nxtTr == 2
                        % take second trough
                        tri = tri + 1;
                    else
                        % remove second trough
                        troughInds = setdiff(troughInds, troughInds(1, tri + 1));
                    end
                    % there still might be another trough to remove so go back and 
                    % check again
                    proceedCheck=0;
                end
            end

            % if both of the above pass we can save values
            if proceedCheck == 1
                % if peaks aren't ahead of troughs
                if peakTroughDiff > 0
                    %time_diff_pt = [time_diff_pt peak_trough_diff*srate_adjust];
                    correctedPeaks_tmp = [correctedPeaks_tmp peakInds(pki)];
                    correctedTroughs_tmp = [correctedTroughs_tmp troughInds(tri)];

                    % step forward
                    tri=tri+1;
                    pki=pki+1;
                else
                    % peaks got ahead of troughs. This shouldn't ever happen.
                    disp('Peaks got ahead of troughs. This shouldnt happen.');
                    disp(strcat('Peak ind: ', num2str(peakInds(pki))));
                    disp(strcat('Trough ind: ', num2str(troughInds(tri))));
                    raise('unexpected error. stopping');
                end
            end
            proceedCheck=1;
        end
        correctedPeaks = [correctedPeaks correctedPeaks_tmp];
        correctedTroughs = [correctedTroughs correctedTroughs_tmp];
        end
% remove any peaks or troughs in padding
correctedPeaks = correctedPeaks(correctedPeaks < length(resp));
correctedTroughs = correctedTroughs(correctedTroughs < length(resp));

    if iInterval >= nValidIntervals;
        toggle = false;
    end

iInterval = iInterval +1;

    end
end

