function out = data_analysis_cardiac_features(InputSig,t,InputFormat,HRVparams,subID,ann,sqi,varargin)

%  ====== HRV Toolbox for PhysioNet Cardiovascular Signal Toolbox =========
%
%   Main_HRV_Analysis(InputSig,t,InputFormat,HRVparams,subID,ann,sqi,varargin)
%	OVERVIEW:
%       Main "HRV Toolbox for PhysioNet Cardiovascular Signal Toolbox" 
%       Configured to accept RR intervals as well as raw data as input file
%
%   INPUT:
%       InputSig    - (seconds) Vector containing RR intervals data
%                     or ECG/PPG waveform  
%       t           - (seconds) Time of the rr interval data  or
%                     leave empty for ECG/PPG input
%       InputFormat - String that specifiy if the input vector is: 
%                     'RRIntervals' for RR interval data 
%                     'ECGWaveform' for ECG waveform
%                     'PPGWaveform' for PPG signal
%       HRVparams   - struct of settings for hrv_toolbox analysis that can
%                     be obtained using InitializeHRVparams.m function 
%                     HRVparams = InitializeHRVparams();
%
%      
%   OPTIONAL INPUTS:
%       subID       - (optional) string to identify current subject
%       ann         - (optional) annotations of the RR data at each point
%                     indicating the type of the beat 
%       sqi         - (optional) Signal Quality Index; Requires a 
%                     matrix with at least two columns. Column 1 
%                     should be timestamps of each sqi measure, and 
%                     Column 2 should be SQI on a scale from 0 to 1.
%       Use InputSig, Type pairs for additional signals such as ABP 
%       or PPG signal. The input signal must be a vector containing
%       signal waveform and the Type: 'ABP' and\or 'PPG'.
%       
%
%   OUTPUS:
%       results         - HRV time and frequency domain metrics as well
%                         as AC and DC, SDANN and SDNNi
%       ResultsFileName - Name of the file containing the results
%
%       NOTE: before running this script review and modifiy the parameters
%             in "initialize_HRVparams.m" file accordingly with the specific
%             of the new project (see the readme.txt file for further details)   
%
%   EXAMPLES
%       - rr interval input
%       Main_HRV_Analysis(RR,t,'RRIntervals',HRVparams)
%       - ECG waveform input
%       Main_HRV_Analysis(ECGsig,[],'ECGWaveform',HRVparams,'101')
%       - ECG waveform and also ABP and PPG waveforms
%       Main_HRV_Analysis(ECGsig,[],'ECGWaveform',HRVparams,[],[],[], abpSig, 
%                         'ABP', ppgSig, 'PPG')
%
%   DEPENDENCIES & LIBRARIES:
%       HRV Toolbox for PhysioNet Cardiovascular Signal Toolbox
%       https://github.com/cliffordlab/PhysioNet-Cardiovascular-Signal-Toolbox
%
%   REFERENCE: 
%   Vest et al. "An Open Source Benchmarked HRV Toolbox for Cardiovascular 
%   Waveform and Interval Analysis" Physiological Measurement (In Press), 2018. 
%
%	REPO:       
%       https://github.com/cliffordlab/PhysioNet-Cardiovascular-Signal-Toolbox
%   ORIGINAL SOURCE AND AUTHORS:     
%       This script written by Giulia Da Poian
%       Dependent scripts written by various authors 
%       (see functions for details)       
%	COPYRIGHT (C) 2018 
%   LICENSE:    
%       This software is offered freely and without warranty under 
%       the GNU (v3 or later) public license. See license file for
%       more information
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
global phase
%clc;

if nargin < 4
    error('Wrong number of input arguments')
end
if nargin < 5
    subID = '0000';
end
if nargin < 6
    ann = [];
end
if nargin < 7
    sqi = [];
end


if length(varargin) == 1 || length(varargin) == 3
    error('Incomplete Signal-Type pair')
elseif length(varargin)  == 2
    extraSigType = varargin(2);
    extraSig = varargin{1};
elseif length(varargin)  == 4
    extraSigType = [varargin(2) varargin(4)];
    extraSig = [varargin{1} varargin{3}];
end

if isa(subID,'cell'); subID = string(subID); end


error_flag = [];

% Start HRV analysis
try   
    switch InputFormat
        case 'ECGWaveform'
            % Convert ECG waveform in rr intervals
%             if length(cardiacData) < 15000
%                 InputSig = [InputSig; InputSig(end:(-1):1)];
%                 mirror = 1;
%             end
            if phase == 6
               originalLength = length(InputSig);
               InputSig = [InputSig; InputSig(end:(-1):1)];
            end
            
            [t, rr, jqrs_ann, SQIvalue , tSQI] = ConvertRawDataToRRIntervals(InputSig, HRVparams, subID);
            sqi = [tSQI', SQIvalue']; 
            
            if phase == 6
                stopThis = find(jqrs_ann < originalLength);
                stopThis = stopThis(end);
                jqrs_ann=jqrs_ann(1:stopThis);
                t=t(1:stopThis-1);
                rr=rr(1:stopThis-1);
                SQIvalue=SQIvalue(1:(length(SQIvalue)/2));
                tSQI=tSQI(1:(length(tSQI)/2));                
                InputSig = InputSig(1:(originalLength));
            end
                
%               if mirror == 1
%                   t=[t(1:(length(t)/2))];
%                   InputSig = [InputSig(1:(length(InputSig)/2))];
%                       
%               end
            
        case 'PPGWaveform'
            [rr,t,sqi] = Analyze_ABP_PPG_Waveforms(InputSig,{'PPG'},HRVparams,[],subID);
        case 'RRIntervals'
            rr = InputSig; 
            if isempty(t)
                fprintf('\n*** Error!***\nFor input type "RRIntervals" must provide \nvetcor with time of the rr intervals \n')
                fprintf('***HRV analyis will not be perfomed!***\n')
                fprintf('\n');
                error_flag = 'Input Error: missing vetcor with time stamps of the rr interval';
            end
                
        otherwise
            fprintf('\n*** Wrong Input Type!***\nThis function accepts: ECGWaveform, PPGWaveform or RRIntervals! \n')
            fprintf('***No HRV analyis will be perfomed!***\n')
            fprintf('\n');
            error_flag = 'Input Error: wrong Input Type';
    end
    
    % added by jopr 17.11.2020
    HRVparams.windowlength = t(end);
    % 
    
    if t(end) < HRVparams.windowlength
        fprintf('\n*** Warning!***\nThe signal is shorter than the analysis window length \n')
        fprintf('***HRV analyis can fail!***\n')
        fprintf('\n');
        error_flag = 'Warning: input signal is shorter than the analysis window length';
    end
        
    % 1. Preprocess Data, AF detection, create Windows Indexes 
    error_flag = 'Data Preprocessing or AF detection failure';
    [NN, tNN, tWin, AFWindows,~] = PreparDataForHRVAnlysis(rr,t,ann,sqi,HRVparams,subID);
    error_flag = []; % clean error flag since preprocessing done
    % added by jopr 17.11.2020
    tWin = tWin(1);
    %
    
    HRVout = [tWin' (tWin+HRVparams.windowlength)'];
    HRVtitle = {'t_start' 't_end'};
   
    % 3. Calculate time domain HRV metrics - Using HRV Toolbox for PhysioNet 
    %    Cardiovascular Signal Toolbox Toolbox Functions        
    if HRVparams.timedomain.on 
        error_flag = 'Time Domain Analysis failure';
        TimeMetrics = EvalTimeDomainHRVstats(NN,tNN,sqi,HRVparams,tWin);
        % Export results
        HRVout = [HRVout cell2mat(struct2cell(TimeMetrics))'];
        HRVtitle = [HRVtitle fieldnames(TimeMetrics)'];
        error_flag = []; % clean error flag since time domain analysis done
    end
    
    % 4. Frequency domain  metrics (LF HF TotPow) 
    if HRVparams.freq.on 
        error_flag = 'Frequency Domain Analysis failure';
        FreqMetrics = EvalFrequencyDomainHRVstats(NN,tNN,sqi,HRVparams,tWin);
        % Export results
        HRVout = [HRVout cell2mat(struct2cell(FreqMetrics))'];
        HRVtitle = [HRVtitle fieldnames(FreqMetrics)'];
        error_flag = []; % clean error flag since frequency domain analysis done
    end
    
    % 5. PRSA, AC and DC values
    if HRVparams.prsa.on 
        error_flag = 'PRSA Analysis failure';
        [ac,dc,~] = prsa(NN, tNN, HRVparams, sqi, tWin );
        % Export results
        HRVout = [HRVout, ac(:), dc(:)];
        HRVtitle = [HRVtitle {'ac' 'dc'}];
        error_flag = []; % clean error flag since PRSA analysis done
    end
    
    % 6.Poincare Features
    if HRVparams.poincare.on
         error_flag = 'Poincare Analysis failure';
         [SD1, SD2, SD12Ratio] = EvalPoincareOnWindows(NN, tNN, HRVparams, tWin, sqi);
         % Export results
         HRVout = [HRVout, SD1(:),SD2(:),SD12Ratio(:)];
         HRVtitle = [HRVtitle {'SD1', 'SD2', 'SD1SD2'}];
         error_flag = []; % clean error flag since Poincare analysis done
    end
    
    % 7.Entropy Features
    if HRVparams.Entropy.on
        error_flag = 'Entropy Analysis failure';
        m = HRVparams.Entropy.patternLength;
        r = HRVparams.Entropy.RadiusOfSimilarity;
        [SampEn, ApEn] = EvalEntropyMetrics(NN, tNN, m ,r, HRVparams, tWin, sqi);
        % Export results
        HRVout = [HRVout, SampEn(:),ApEn(:)];
        HRVtitle = [HRVtitle {'SampEn', 'ApEn'}];
        error_flag = []; % clean error flag since Entropy analysis done
    end
    
    % Generates Output - Never comment out
    error_flag = 'Failure during output file generation';
    %ResultsFileName.HRV = SaveHRVoutput(subID,tWin,HRVout,HRVtitle, [],HRVparams, tNN, NN);
    out.HRVout = HRVout;
    out.HRVtitle = HRVtitle;
    out.tNN = tNN;
    out.NN = NN;
    
    error_flag = []; % clean error flag 
    

  
catch
    % Write subjectID on log file
    fid = fopen(strcat(HRVparams.writedata,filesep,'AnalysisError.txt'),'a');
    HRVout = NaN;
    ResultsFileName = '';
    fprintf(fid, 'Basic HRV Analysis faild for subject: %s, %s \n', subID, error_flag);
    fclose(fid); 
end % end of HRV analysis


end %== function ================================================================
%

function [NN, tNN, tWin,AFWindows,out] = PreparDataForHRVAnlysis(rr,t,annotations,sqi,HRVparams,subjectID)

    out = []; % Struct used to save DFA and MSE preprocessed data
 
    % Exclude undesiderable data from RR series (i.e., arrhytmia, low SQI, ectopy, artefact, noise)
    [NN, tNN] = RRIntervalPreprocess(rr,t,annotations, HRVparams);  
    tWin = CreateWindowRRintervals(tNN, NN, HRVparams);    % Create Windows for Time and Frequency domain 
    
    % Create Windows for MSE and DFA and preprocess
    if HRVparams.MSE.on || HRVparams.DFA.on
       % Additional pre-processing to deal with missing data for MSE and DFA analysis     
       [out.NN_gapFilled, out.tNN_gapFilled] = RR_Preprocessing_for_MSE_DFA( NN, tNN );
    end
    if HRVparams.MSE.on
       out.tWinMSE = CreateWindowRRintervals(out.tNN_gapFilled, out.NN_gapFilled, HRVparams,'mse');
    end
    if HRVparams.DFA.on
        out.tWinDFA = CreateWindowRRintervals(out.tNN_gapFilled, out.NN_gapFilled, HRVparams,'dfa');
    end    
    
    % 2. Atrial Fibrillation Detection
    if HRVparams.af.on 
        [AFtest, AfAnalysisWindows] = PerformAFdetection(subjectID,t,rr,sqi,HRVparams);
        fprintf('AF analysis completed for subject %s \n', subjectID);
        % Remove RRAnalysisWindows contating AF segments
        [tWin, AFWindows]= RemoveAFsegments(tWin,AfAnalysisWindows, AFtest,HRVparams);
        if HRVparams.MSE.on
            out.tWinMSE = RemoveAFsegments(out.tWinMSE,AfAnalysisWindows, AFtest,HRVparams);
        end
        if HRVparams.DFA.on 
            out.tWinDFA = RemoveAFsegments(out.tWinDFA,AfAnalysisWindows, AFtest,HRVparams);
        end
    else
        AFWindows = [];
    end
    
end

