function [inhaleDurations, exhaleDurations] = data_analysis_respi_breath_duration(Bm)

inhaleDurations = zeros(1,length(Bm.inhaleOnsets));
exhaleDurations = zeros(1,length(Bm.exhaleOnsets));


% calculate inhale durations
for i = 1:length(Bm.inhaleOnsets)
    if ~isnan(Bm.inhaleOffsets(i))
        inhaleDurations(i) = Bm.inhaleOffsets(i)-Bm.inhaleOnsets(i);
    else
        inhaleDurations(i) = nan;
    end
end

% calculate exhale durations
for e=1:length(Bm.exhaleOnsets)
    if ~isnan(Bm.exhaleOffsets(e))
        exhaleDurations(e) = Bm.exhaleOffsets(e)-Bm.exhaleOnsets(e);
    else
        exhaleDurations(e) = nan;
    end
end


% normalize back into real time
inhaleDurations = inhaleDurations ./ Bm.srate;
exhaleDurations = exhaleDurations ./ Bm.srate;
