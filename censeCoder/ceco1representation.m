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
l_frame = 1024;
l_hop = 0.5*l_frame;
if setting.fps % 0 means none
    n_fps = (sr+l_hop-l_frame)/l_hop; % Number of frames per second with base settings
    n_avg = round(n_fps/setting.fps); % Number of consecutive frames to average into one
    disp(['Chosen FPS is ' num2str(setting.fps) ', actual one is ' num2str(n_fps/n_avg) '.']);
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
x_mel = cell(1, length(file_path));
x_mel_max = cell(1, length(file_path));
for ind_fold = 1:length(file_path)
    disp(['Processing fold ' num2str(ind_fold) ' of ' num2str(length(file_path)) '...']);
    for ind_file = 1:length(file_path{ind_fold})
        [x, Fs_temp] = audioread(file_path{ind_fold}{ind_file});
        x = resample(x(:, 1), sr, Fs_temp);
        x = x./max(abs(x));
        x(x==0) = eps;
        if length(x)<l_frame; x=[x;zeros(l_frame-length(x),1)]; end
        % Rounding of x size
        x = [x; zeros(l_hop-mod(size(x, 1)-l_frame, l_hop), 1)]; % Sup
        %% Magnitude spectrogram via STFT
        x_spec = powspec(x, sr, l_frame/sr, l_hop/sr, 0);
        n_frames{ind_fold}{ind_file} = size(x_spec, 2); % Amount of STFT windows before averaging, needed for reconstruction
        %% Averaging over time
        if setting.fps % 0 means none
            x_spec_avg = [];
            for ind_oframe = 1:ceil(size(x_spec, 2)/n_avg)
                x_spec_avg(:, end+1) = mean(x_spec(:, (ind_oframe-1)*n_avg+1:min(ind_oframe*n_avg, end)), 2);
            end
            x_spec = x_spec_avg;
            n_frames_avg{ind_fold}{ind_file} = size(x_spec, 2); % Amount of STFT windows after averaging, needed for file separation when decoding
        end
        %% FFT bins to MEL bins
        x_mel{ind_fold}{ind_file} = audspec(x_spec, sr, setting.mel, 'mel', 0, sr/2, 1, 1);
        x_mel{ind_fold}{ind_file} = log(x_mel{ind_fold}{ind_file});
        %% Signed quantization. Because the Fourier transform is linear, rescaling the spectrogram only induces a change in sound volume at reconstruction
        x_mel_max{ind_fold}{ind_file} = max(max(x_mel{ind_fold}{ind_file})); % Needed for reconstruction
        if setting.quant ~= 0
            x_mel{ind_fold}{ind_file} = int16((2^(setting.quant-1)-1)*x_mel{ind_fold}{ind_file}./x_mel_max{ind_fold}{ind_file}); % Datatype size minus 1 for the delta-comp
            x_mel{ind_fold}{ind_file}(x_mel{ind_fold}{ind_file}<0) = 0; % Low values elimination, also divides by two the output word size
        end
    end
end

%% Outputs
% Store
store.x_mel_max = x_mel_max;
store.x_mel = x_mel;
if strcmp(setting.dataset, 'urbansound8k'); store.wav_name = wav_name; end
store.n_frames = n_frames;
if setting.fps; store.n_frames_avg = n_frames_avg; end

% Observations

            
