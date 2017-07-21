function [config, store, obs] = toer1cense(config, setting, data)              
% toer1cense CENSE step of the expLanes experiment tobError                    
%    [config, store, obs] = toer1cense(config, setting, data)                  
%      - config : expLanes configuration state                                 
%      - setting   : set of factors to be evaluated                            
%      - data   : processing data stored during the previous step              
%      -- store  : processing data to be saved for the other steps             
%      -- obs    : observations to be saved for analysis                       
                                                                               
% Copyright: felix                                                             
% Date: 12-Jul-2017                                                            
                                                                               
% Set behavior for debug mode                                                  
if nargin==0, tobError('do', 1, 'mask', {}); return; else store=[]; obs=[]; end
                                                                               
sr = 32000;

l_frame = round(setting.framelen*sr);
if setting.framelen == 0.125; l_hop = 1*l_frame; else l_hop = 0.5*l_frame; end

N = 2^(ceil(log2(l_frame)));
N_filt = 2^20; % Design with a much higher precision
G = third_octave_filterbank(sr, N_filt, -17:11, 3);
switch setting.gcalc
    case 'sub'
        G = G(:, 1:round(N_filt/N):end); % Only take the resolution needed
        H_st = G.^2;
    case 'mean'
        G = G.^2;
        G_mean(:, 1) = mean(G(:, 1:1+round(N_filt/(2*N))), 2);
        G_mean(:, N/2+1) = mean(G(:, 1+(N/2)*round(N_filt/N)-round(N_filt/(2*N)):end), 2);
        for ind_f = 2:N/2
            G_mean(:, ind_f) = mean(G(:, 1+(ind_f-1)*round(N_filt/N)-round(N_filt/(2*N)):1+(ind_f-1)*round(N_filt/N)+round(N_filt/(2*N))), 2);
        end
        H_st = G_mean;
        clear ind_f G_mean;
    case 'dec'
        for ind_b = 1:size(G, 1)
            G_temp(ind_b, :) = decimate(G(ind_b, :), round(N_filt/N));
%             G_temp(ind_b, :) = resample(G(ind_b, :), N, N_filt);
        end
        H_st = (G_temp./G_temp(end, end)).^2;
end
clear G N_filt;


switch setting.wintype % Other windows to implement
    case 'hamming'
        w = hamming(l_frame, 'periodic');
    case 'hanning'
        w = hanning(l_frame, 'periodic');
    case 'blackmanharris'
        w = blackmanharris(l_frame, 'periodic');
    case 'bartlett'
        w = bartlett(l_frame);
    case 'bartletthann'
        w = barthannwin(l_frame);
    case 'gaussian'
        w = gausswin(l_frame);
    case 'kaiser'
        w = kaiser(l_frame, 0.25);
    case 'tukey01'
        w = tukeywin(l_frame, 0.1);
    case 'tukey02'
        w = tukeywin(l_frame, 0.2);
    case 'tukey03'
        w = tukeywin(l_frame, 0.3);
    case 'tukey04'
        w = tukeywin(l_frame, 0.4);
    case 'tukey05'
        w = tukeywin(l_frame, 0.5);
    case 'tukey06'
        w = tukeywin(l_frame, 0.6);
    case 'tukey07'
        w = tukeywin(l_frame, 0.7);
    case 'tukey08'
        w = tukeywin(l_frame, 0.8);
    case 'tukey09'
        w = tukeywin(l_frame, 0.9);
    case 'rect'
        w = ones(l_frame, 1);
end

switch setting.dataset
    case 'noise'
    case 'speech'
        datapath = [config.inputPath 'rush/'];
        rush_dir = dir(datapath);
        rush_names = {rush_dir.name};
        ind_wav = 0; % Real number of .wav files
        for ind_file = 1:numel(rush_names)
            if length(rush_names{ind_file}) > 4 && strcmp(rush_names{ind_file}(end-3:end), '.wav')
                ind_wav = ind_wav+1;
                file_path{ind_wav} = [datapath rush_names{ind_file}];
            end
        end
    case 'urbansound8k'
        ind_wav = 0; % Real number of .wav files
        for ind_fold = 1:5
            datapath = [config.inputPath 'UrbanSound8K/audio/fold' num2str(ind_fold) '/'];
            us8k_dir = dir(datapath);
            us8k_names = {us8k_dir.name};
            for ind_file = 1:numel(us8k_names)
                if length(us8k_names{ind_file}) > 4 && strcmp(us8k_names{ind_file}(end-3:end), '.wav')
                    ind_wav = ind_wav+1;
                    file_path{ind_wav} = [datapath us8k_names{ind_file}];
                    wav_name{ind_wav} = us8k_names{ind_file};
                end
            end
        end
end

switch setting.dataset
    case 'noise'
        if exist(['noise_' num2str(setting.reflen) '.mat'], 'file')
            load(['noise_' num2str(setting.reflen) '.mat']);
            for ind_wav = 1:100
                assert(setting.reflen>=setting.framelen);
                x = x_noise{ind_wav};
                X_st = (abs(stft(x, l_frame, l_hop, setting.wintype, 1)).^2)/(sum(w.^2)*(l_frame/2+1)/l_frame);
                X_tob_cen{ind_wav} = H_st*X_st;
            end
        else
            for ind_wav = 1:100
                assert(setting.reflen>=setting.framelen);
                x = randn(setting.reflen*sr, 1);
                if mod(size(x, 1)-l_frame, l_hop)
                    x = [x; zeros(l_hop-mod(size(x, 1)-l_frame, l_hop), 1)]; % Sup
                end
                X_st = (abs(stft(x, l_frame, l_hop, setting.wintype, 1)).^2)/(sum(w.^2)*(l_frame/2+1)/l_frame);
                X_tob_cen{ind_wav} = H_st*X_st;
                x_noise{ind_wav} = x;
            end
            save(['noise_' num2str(setting.reflen) '.mat'], 'x_noise');
        end
    case 'speech'
        for ind_wav = 1:length(file_path)
            disp(['Processing file ' num2str(ind_wav) ' of ' num2str(length(file_path)) '...']);
            [x, sr2] = audioread(file_path{ind_wav});
            x = resample(x(:, 1), sr, sr2);
            % Analysis
            if mod(size(x, 1)-l_frame, l_hop)
                x = [x; zeros(l_hop-mod(size(x, 1)-l_frame, l_hop), 1)]; % Sup
            end
            X_st = (abs(stft(x, l_frame, l_hop, setting.wintype, 1)).^2)/(sum(w.^2)*(l_frame/2+1)/l_frame);
            X_tob_cen{ind_wav} = H_st*X_st;
        end
    case 'urbansound8k'
        ind_wav2 = 0;
        for ind_wav = 1:length(file_path)
%             disp(['Processing file ' num2str(ind_wav) ' of ' num2str(length(file_path)) '...']);
            [x, sr2] = audioread(file_path{ind_wav});
            x = resample(x(:, 1), sr, sr2);
            if length(x)>round(setting.reflen*sr)
                ind_wav2 = ind_wav2+1;
                % Analysis
                if mod(size(x, 1)-l_frame, l_hop)
                    x = [x; zeros(l_hop-mod(size(x, 1)-l_frame, l_hop), 1)]; % Sup
                end
                X_st = (abs(stft(x, l_frame, l_hop, setting.wintype, 1)).^2)/(sum(w.^2)*(l_frame/2+1)/l_frame);
                X_tob_cen{ind_wav2} = H_st*X_st;
            end
        end
end

% if strcmp(setting.dataset, 'noise'); store.x_noise = x_noise; end
store.X_tob_cen = X_tob_cen;


