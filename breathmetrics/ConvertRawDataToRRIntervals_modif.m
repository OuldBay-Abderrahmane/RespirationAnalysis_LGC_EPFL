function [t,rr,jqrs_ann,SQIjw, StartSQIwindows_jw] = ConvertRawDataToRRIntervals_modif(ECG_RawData ,HRVparams, subjectID)
%   [t,rr,jqrs_ann,sqijs, StartIdxSQIwindows_jw] = ConvertRawDataToRRIntervals(ECG_RawData ,HRVparams, subjectID)  
%
%	OVERVIEW:
%       Load raw signal perfom QRS detection & Signal Quality Index SQI
%       and extract RR intervals from ECG signal 
%       (single lead ECG signal)
%
%   INPUT:
%       ECG_RawData : vector containing the 'raw' ECG signal (in mV) 
%       HRVparam    : struct of settings for hrv_toolbox analysis
%       subjectID   : name that identify the analyzed signal 
%
%   OUTPUT:
%       rr                  :  (seconds) Vector containing RR interval
%       t                   :  (seconds) Time of the rr interval data 
%       SQIjs               :  Signal Quality Index values comparing jqrs and wqrsm 
%       StartSQIwindows_jw  :  time of SQI windows
%
%   DEPENDENCIES & LIBRARIES:
%       PhysioNet Cardiovascular Signal Toolbox
%       https://github.com/cliffordlab/PhysioNet-Cardiovascular-Signal-Toolbox
%
%   REFERENCE: 
%   Vest et al. "An Open Source Benchmarked HRV Toolbox for Cardiovascular 
%   Waveform and Interval Analysis" Physiological Measurement (In Press), 2018. 
%
%	REPO:       
%       https://github.com/cliffordlab/PhysioNet-Cardiovascular-Signal-Toolbox%   ORIGINAL SOURCE AND AUTHORS:     
%       Written by Giulia Da Poian (giulia.dap@gmail.com) 
%       Dependent scripts written by various authors 
%       (see functions for details)       
%	COPYRIGHT (C) 2018 
%   LICENSE:    
%       This software is offered freely and without warranty under 
%       the GNU (v3 or later) public license. See license file for
%       more information
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 

if nargin < 3
    error('Wrong number of arguments in ConvertRawDataToRRIntervals')
end

% run_sqrs and wqrsm detectors require ECG in digital values
% thus ECG data input that is in physical units will multiply the value
% GainQrsDetect

GainQrsDetect = 2000; % Default value for gain (adu/physical unit) 

if size(ECG_RawData,1)<size(ECG_RawData,2)
    ECG_RawData = ECG_RawData';
end

ECG_RawData = ECG_RawData(:,1); % If more the one leads use only the first

% QRS Dection 1 - jqrs
jqrs_ann = run_qrsdet_by_seg(ECG_RawData,HRVparams);

% QRS Detection 2 - sqrs (need single channel of ECG in digital values)
sqrs_ann = run_sqrs(ECG_RawData*GainQrsDetect,HRVparams,0);

% QRS Detection 3 - wqrs
wqrs_ann = wqrsm_fast(ECG_RawData*GainQrsDetect,HRVparams.Fs);

% QRS SQI analysis
[SQIjs, StartSQIwindows_js] = bsqi(jqrs_ann(:),sqrs_ann(:),HRVparams);
[SQIjw, StartSQIwindows_jw] = bsqi(jqrs_ann(:),wqrs_ann(:),HRVparams);


% Translate anotations to rr intervals
rr = diff(jqrs_ann./HRVparams.Fs);
t = jqrs_ann(2:end)./HRVparams.Fs;






