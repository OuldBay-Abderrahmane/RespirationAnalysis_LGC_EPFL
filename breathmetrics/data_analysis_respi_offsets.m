function [inhaleOffsets,exhaleOffsets] = data_analysis_respi_offsets(resp, ...
    inhaleOnsets, exhaleOnsets)

%FIND_RESPIRATORY_OFFSETS Finds where each inhale and exhale ends
    
inhaleOffsets = zeros(size(inhaleOnsets));
exhaleOffsets = zeros(size(exhaleOnsets));

% finding inhale offsets
for bi = 1:length(exhaleOnsets)
    inhaleOffsets(1, bi) = exhaleOnsets(bi)-1;
end

% finding exhale offsets
for bi = 1:length(exhaleOnsets) - 1
    exhaleOffsets(1, bi) = inhaleOnsets(bi + 1)-1;
end

% last exhale is different because there is no following inhale
final_window = resp(exhaleOnsets(end):end);
putativeExhaleOffset = find(final_window > 0, 1, 'first');

% check that there is a real exhale end that it isn't artifact
avgExhaleLen = mean(exhaleOffsets(1, 1:end-1) - exhaleOnsets(1, 1:end-1));
lowerLim = avgExhaleLen / 4;
upperLim = avgExhaleLen * 1.75;
if isempty(putativeExhaleOffset) || putativeExhaleOffset < lowerLim || ...
        putativeExhaleOffset >= upperLim
    % end of exhale cannot be calculated
    exhaleOffsets(1,end) = nan;
else
    exhaleOffsets(1,end) = exhaleOnsets(1,end) + putativeExhaleOffset - 1;
end

