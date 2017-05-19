function [config, store, obs] = ceco1representation(config, setting, data)       
% ceco1representation REPRESENTATION step of the expLanes experiment censeCoder  
%    [config, store, obs] = ceco1representation(config, setting, data)           
%      - config : expLanes configuration state                                   
%      - setting   : set of factors to be evaluated                              
%      - data   : processing data stored during the previous step                
%      -- store  : processing data to be saved for the other steps               
%      -- obs    : observations to be saved for analysis                         
                                                                                 
% Copyright: felix                                                               
% Date: 20-Apr-2017                                                              
                                                                                 
% Set behavior for debug mode                                                    
if nargin==0, censeCoder('do', 1, 'mask', {}); return; else store=[]; obs=[]; end
                                                                                 
addpath(genpath('C:\Program Files\MATLAB\R2015b\toolbox\rastamat'));
addpath(genpath('util'));

sr = 44100;
%% Analysis window definition
if strcmp(setting.desc, 'mel')
    l_frame = 1024;
    l_hop = 0.5*l_frame;
    if setting.fps % 0 means none
        n_fps = (sr+l_hop-l_frame)/l_hop; % Number of frames per second with base settings
        n_avg = round(n_fps/setting.fps); % Number of consecutive frames to average into one
        disp(['Chosen FPS is ' num2str(setting.fps) ', actual one is ' num2str(n_fps/n_avg) '.']);
    end
elseif strcmp(setting.desc, 'tob')
    l_frame = (round(0.125*sr)-mod(round(0.125*sr), 2)); % Approximately 125ms, "fast" Leq
    l_hop = l_frame; % No overlap
    %% Filterbank calculation, can be replaced with constant matrix
    N = 2^13;
    N_filt = 2^17; % Design with a much greater precision
    G = third_octave_filterbank(sr, N_filt, -17:13);
    G = G(:, 1:round(N_filt/N):end); % Only take the resolution needed
    H = G.^2; % Frequency weights matrix
%     HH = H'*H;
%     iH = H'./(repmat(max(mean(diag(HH))/100, sum(HH))',1,size(H, 1))); % Inverse frequency weights matrix
%     iH(isnan(iH)) = 0; % Some frequencies are outside analysis range, ie we divide by zero
end

%% Wave files paths
switch setting.dataset
    case 'speech'
        if ispc; datapath = [config.inputPath 'rush\']; else datapath = [config.inputPath 'rush/']; end
        rush_dir = dir(datapath);
        rush_names = {rush_dir.name};
        ind_wav = 0; % Real number of .wav files
        for ind_file = 1:numel(rush_names)
            if length(rush_names{ind_file}) > 4 && strcmp(rush_names{ind_file}(end-3:end), '.wav')
                ind_wav = ind_wav+1;
                file_path{1}{ind_wav} = [datapath rush_names{ind_file}];
            end
        end
    case 'urbansound8k'
        for ind_fold = 1:10
            if ispc; datapath = [config.inputPath 'UrbanSound8K\audio\fold' num2str(ind_fold) '\']; else datapath = [config.inputPath 'UrbanSound8K/audio/fold' num2str(ind_fold) '/']; end
            us8k_dir = dir(datapath);
            us8k_names = {us8k_dir.name};
            ind_wav = 0; % Real number of .wav files
            for ind_file = 1:numel(us8k_names)
                if length(us8k_names{ind_file}) > 4 && strcmp(us8k_names{ind_file}(end-3:end), '.wav')
                    ind_wav = ind_wav+1;
                    file_path{ind_fold}{ind_wav} = [datapath us8k_names{ind_file}];
                    wav_name{ind_fold}{ind_wav} = us8k_names{ind_file};
                end
            end
        end
end

%% Wave files
q_norm = cell(1, length(file_path));
q_loss = [];
for ind_fold = 1:length(file_path)
    disp(['Analysis: Processing fold ' num2str(ind_fold) ' of ' num2str(length(file_path)) '...']);
    for ind_file = 1:length(file_path{ind_fold})
        [x, Fs_temp] = audioread(file_path{ind_fold}{ind_file});
        x = resample(x(:, 1), sr, Fs_temp);
        x = x./max(abs(x));
        x(x==0) = eps;
        % Should never happen
        if length(x)<l_frame; x=[x;zeros(l_frame-length(x),1)]; end
        % Rounding of x size
        x = [x; zeros(l_hop-mod(size(x, 1)-l_frame, l_hop), 1)]; % Sup
        
        if strcmp(setting.desc, 'mel')
            %% Magnitude spectrogram via STFT
            X = powspec(x, sr, l_frame/sr, l_hop/sr, 0);
            n_frames{ind_fold}{ind_file} = size(X, 2); % Number of STFT windows before averaging, needed for reconstruction
            %% Averaging over time
            if setting.fps % 0 means none
                x_spec_avg = [];
                for ind_oframe = 1:ceil(size(X, 2)/n_avg)
                    x_spec_avg(:, end+1) = mean(X(:, (ind_oframe-1)*n_avg+1:min(ind_oframe*n_avg, end)), 2);
                end
                X = x_spec_avg;
                n_frames_avg{ind_fold}{ind_file} = size(X, 2); % Number of STFT windows after averaging, needed for file separation when decoding
            end
            %% FFT bins to MEL bins
            Xm{ind_fold}{ind_file} = audspec(X, sr, setting.mel, 'mel', 0, sr/2, 1, 1);
            Xm{ind_fold}{ind_file} = log(Xm{ind_fold}{ind_file});
            %% Quantization
            if setting.quant ~= 0
                Xm_clean = Xm{ind_fold}{ind_file};
                q_norm{ind_fold}{ind_file} = max(max(Xm{ind_fold}{ind_file})); % Needed for reconstruction
                Xm{ind_fold}{ind_file} = int16((2^(setting.quant-1)-1)*Xm{ind_fold}{ind_file}./q_norm{ind_fold}{ind_file}); % Datatype size minus 1 for the delta-comp
                Xm{ind_fold}{ind_file}(Xm{ind_fold}{ind_file}<0) = 0; % Low values elimination
                % q_loss(end+1) = 10*log10(mean(mean(abs(exp(double(Xm{ind_fold}{ind_file}).*q_norm{ind_fold}{ind_file}./(2^(setting.quant-1)-1))-exp(Xm_clean)))));
                q_loss(end+1) = mean(mean(abs(10*log10(exp(double(Xm{ind_fold}{ind_file}).*q_norm{ind_fold}{ind_file}./(2^(setting.quant-1)-1)))-10*log10(exp(Xm_clean)))));
                if isnan(q_loss(end)) || isinf(q_loss(end))
                    disp(['NaN or Inf found at file ' num2str(ind_file) ' in fold ' num2str(ind_fold) '.']);
                    q_loss = q_loss(1:end-1);
                end
            end
        elseif strcmp(setting.desc, 'tob')
            %% Magnitude spectrogram via STFT, with zero padding
            X = stft(x, l_frame, l_hop, 'rect', 1)/sqrt(l_frame/2+1); % Energy conservation (Parseval theorem)
            n_frames{ind_fold}{ind_file} = size(X, 2); % Number of STFT windows before averaging, needed for reconstruction
            Xi{ind_fold}{ind_file} = H*(abs(X).^2);
            Xi{ind_fold}{ind_file} = 10*log10(Xi{ind_fold}{ind_file}/N);
            %% Quantization
            if setting.quant ~= 0
                q_norm{ind_fold}{ind_file} = zeros(2, 1);
                Xi_clean = Xi{ind_fold}{ind_file}; % For loss calculation
                q_norm{ind_fold}{ind_file}(1) = min(min(Xi{ind_fold}{ind_file}));
                Xi{ind_fold}{ind_file} = Xi{ind_fold}{ind_file}-q_norm{ind_fold}{ind_file}(1); % Everything has to be positive
                q_norm{ind_fold}{ind_file}(2) = max(max(Xi{ind_fold}{ind_file}));
                Xi{ind_fold}{ind_file} = int16((2^(setting.quant-1)-1)*Xi{ind_fold}{ind_file}./q_norm{ind_fold}{ind_file}(2)); % Normalisation + Quantization
                assert(isempty(find(Xi{ind_fold}{ind_file}<0, 1))); % Should never happen
                q_loss(end+1) = mean(mean(abs(((double(Xi{ind_fold}{ind_file}).*q_norm{ind_fold}{ind_file}(2)./(2^(setting.quant-1)-1))+q_norm{ind_fold}{ind_file}(1))-Xi_clean)));
                if isnan(q_loss(end)) || isinf(q_loss(end))
                    disp(['NaN or Inf found at file ' num2str(ind_file) ' in fold ' num2str(ind_fold) '.']);
                    q_loss = q_loss(1:end-1);
                end
            end
        end
    end
end

%% Outputs
% Store
if setting.quant; store.q_norm = q_norm; end
if strcmp(setting.desc, 'mel')
    store.X_desc = Xm;
    if setting.fps; store.n_frames_avg = n_frames_avg; end
elseif strcmp(setting.desc, 'tob')
    store.X_desc = Xi;
end
if strcmp(setting.dataset, 'urbansound8k'); store.wav_name = wav_name; end
store.n_frames = n_frames;

% Observations
obs.q_loss = q_loss;
            
