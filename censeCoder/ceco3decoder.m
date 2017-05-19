function [config, store, obs] = ceco3decoder(config, setting, data)              
% ceco4decoder DECODER step of the expLanes experiment censeCoder                
%    [config, store, obs] = ceco4decoder(config, setting, data)                  
%      - config : expLanes configuration state                                   
%      - setting   : set of factors to be evaluated                              
%      - data   : processing data stored during the previous step                
%      -- store  : processing data to be saved for the other steps               
%      -- obs    : observations to be saved for analysis                         
                                                                                 
% Copyright: felix                                                               
% Date: 27-Apr-2017                                                              
                                                                                 
% Set behavior for debug mode                                                    
if nargin==0, censeCoder('do', 3, 'mask', {}); return; else store=[]; obs=[]; end
                                                                                 
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
    HH = H'*H;
    iH = H'./(repmat(max(mean(diag(HH))/100, sum(HH))',1,size(H, 1))); % Inverse frequency weights matrix
    iH(isnan(iH)) = 0; % Some frequencies are outside analysis range, ie we divide by zero
end

if setting.quant
    X_desc_mat = [];
    for indframe = 1:numel(data.X_huff)
        %% Matlab needs binary vectors
        X_huff = str2num(reshape(dec2bin(data.X_huff{indframe})', [], 1));
        X_huff = X_huff(1:data.huff_len(indframe));
        %% Huffman decoding
        switch setting.dictgen
            case 'local'
                X_delta = huffmandeco(X_huff, data.dict{indframe});
            case 'global'
                X_delta = huffmandeco(X_huff, data.dict);
        end
        %% Delta decoding
        X_frame = delta_dec(X_delta);
        %% Reformatting
        if strcmp(setting.desc, 'mel')
            X_desc_mat = [X_desc_mat reshape(X_frame, [], setting.mel)'];
        elseif strcmp(setting.desc, 'tob')
            X_desc_mat = [X_desc_mat reshape(X_frame, [], size(H, 1))'];
        end
    end

    %% File reconstruction
    desc_p = 0;
    for ind_fold = 1:length(data.q_norm)
        for ind_file = 1:length(data.q_norm{ind_fold})
            %% Fold/File separation
            if strcmp(setting.desc, 'mel') && setting.fps
                X_desc{ind_fold}{ind_file} = X_desc_mat(:, desc_p+1:desc_p+data.n_frames_avg{ind_fold}{ind_file});
            else
                X_desc{ind_fold}{ind_file} = X_desc_mat(:, desc_p+1:desc_p+data.n_frames{ind_fold}{ind_file});
            end
            desc_p = desc_p + size(X_desc{ind_fold}{ind_file}, 2);
        end
    end
else
    X_desc = data.X_desc;
end

for ind_fold = 1:length(X_desc)
    for ind_file = 1:length(X_desc{ind_fold})
        if strcmp(setting.desc, 'mel')
            %% Normalisation
            if setting.quant ~= 0
                X_desc{ind_fold}{ind_file} = data.q_norm{ind_fold}{ind_file}*double(X_desc{ind_fold}{ind_file})/(2^(setting.quant-1)-1);
            end
            X_desc{ind_fold}{ind_file} = exp(X_desc{ind_fold}{ind_file});

            %% Reconstruction of the linearly-scaled spectrogram
            X = invaudspec(X_desc{ind_fold}{ind_file}, sr, l_frame, 'mel', 0, sr/2, 1, 1);

            %% Averaging expansion
            if setting.fps
                X = reshape(repmat(X, n_avg, 1), size(X, 1), []); % Replicate STFT
                X = X(:, 1:data.n_frames{ind_fold}{ind_file}); % Truncate to obtain same size as before averaging
            end
            X(X == 0) = eps;

            %% Signal/Phase reconstruction
            switch setting.phaserec
                case 'WNS' % White noise spectrogram scaling
                    x{ind_fold}{ind_file} = invpowspec(X, sr, l_frame/sr, l_hop/sr);
                case 'GL' % Griffin and Lim algorithm
                    n_iter = 20;
                    n_win = size(X, 2);
                    win = hanning(l_frame, 'periodic');
                    x_temp = randn(l_frame+(n_win-1)*l_hop, 1); % Random values initialisation
                    iter = 1;
                    while iter < n_iter+1
                        disp(['Iteration ' num2str(iter) ' of ' num2str(n_iter) '...']);
                        iter = iter+1;
                        x_stft = specgram(x_temp, l_frame, sr, win, l_hop);
                        b = (sqrt(X)/32768).*x_stft./abs(x_stft); % As described in G&L paper
                        % b = (sqrt(x_spec)/32768).*exp(1i*angle(x_stft)); % Also works
                        x_temp = istft(b, l_frame, l_hop, 'hanning');
                    end
                    x{ind_fold}{ind_file} = x_temp;
            end
        elseif strcmp(setting.desc, 'tob')
            %% Normalisation
            if setting.quant ~= 0
                X_desc{ind_fold}{ind_file} = (double(X_desc{ind_fold}{ind_file}).*data.q_norm{ind_fold}{ind_file}(2)./(2^(setting.quant-1)-1))+data.q_norm{ind_fold}{ind_file}(1);
            end
            
            X_desc{ind_fold}{ind_file} = (10.^(X_desc{ind_fold}{ind_file}./10))*N;
            %% Spectrogram reconstruction
            X = iH*X_desc{ind_fold}{ind_file};
            Xn = stft(randn(l_frame+l_hop*(size(X, 2)-1), 1), l_frame, l_hop, 'rect', 1);
            x{ind_fold}{ind_file} = istft(sqrt(l_frame/2+1)*sqrt(X).*exp(1i*angle(Xn)), l_frame, l_hop, 'rect');
        end
    end
end
if strcmp(setting.desc, 'mel')
    audiowrite(['..\..\decoded_samples\Sample_fps' num2str(setting.fps) '_mel' num2str(setting.mel) '_quant' num2str(setting.quant) '_' setting.phaserec '.wav'], x{1}{1}./max(abs(x{1}{1})), sr);
elseif strcmp(setting.desc, 'tob')
    audiowrite(['..\..\decoded_samples\Sample_th_oct_quant' num2str(setting.quant) '.wav'], x{1}{1}./max(abs(x{1}{1})), sr);
end
%% Outputs
% Store
store.x_rec = x;

% Observations
