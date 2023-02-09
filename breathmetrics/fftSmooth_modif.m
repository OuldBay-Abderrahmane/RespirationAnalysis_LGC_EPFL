function y = fftSmooth_modif(resp,srateCorrectedSmoothedWindow)

% create the window
L      = length(resp);
window = zeros(1,L);

% in case signal is smaller than 60s (which is the usual sliding window size)
if L < srateCorrectedSmoothedWindow
    srateCorrectedSmoothedWindow = L-1;
end

NANcase = 0;
% isolate + mark nan and convert them to =0
if sum(find(isnan(resp)))/sum(find(isnan(resp))) == 1
    isoNAN = find(isnan(resp));
    resp(isoNAN)= 0;
    NANcase = 1;
end

window(floor((L-srateCorrectedSmoothedWindow+1)/2):floor((L+srateCorrectedSmoothedWindow)/2))=1;

% check the size of the input
if size(resp',2) == size(window,2),   resp = resp'; end

% zero phase low pass filtering
tmp = ifft(fft(resp).*fft(window)/srateCorrectedSmoothedWindow);
y = -1*ifft(fft(-1*tmp).*fft(window)/srateCorrectedSmoothedWindow);

% check if y is column vector
if size(y,1)< size(y,2), y = y';end
    
% return = 0 to nan values
if NANcase == 1
    resp(isoNAN) = NaN;
end  
end