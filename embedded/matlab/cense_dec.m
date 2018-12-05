% Needed for decoding: 
% - Encoded data (X_huff)
% - Normalisation values (q_norm)
% - Length of the encoded data (X_huff_l)

% ----- Function ----- %
% function cense_dec(X_huff, X_Huff_l, q_norm)
% ----- END - Function ----- %
% ----- Script ----- %
clear all, close all, clc;
load data_enc;
% ----- END - Script ----- %

sr = 32000; % Sampling rate (Hz)
l_frame = 4096; % STFT frame duration, sr/8 rounded to next power of 2 - approx. 128 ms
l_hop = l_frame; % STFT hop size
q = 8; % Quantized word size

% ----- Matlab ----- %
% The following steps are implemented in matlab only

%% Weight matrix, constant
N = 2^(ceil(log2(l_frame)));
N_filt = 2^20; % Design with a much higher precision
G = third_octave_filterbank(sr, N_filt, -17:11, 3);
G = G.^2;
G_mean(:, 1) = mean(G(:, 1:1+round(N_filt/(2*N))), 2);
G_mean(:, N/2+1) = mean(G(:, 1+(N/2)*round(N_filt/N)-round(N_filt/(2*N)):end), 2);
for ind_f = 2:N/2
    G_mean(:, ind_f) = mean(G(:, 1+(ind_f-1)*round(N_filt/N)-round(N_filt/(2*N)):1+(ind_f-1)*round(N_filt/N)+round(N_filt/(2*N))), 2);
end
H_st = G_mean;
clear ind_f N_filt G G_mean;

% Approximate inverse operation
HH = H_st'*H_st;
iH = H_st'./(repmat(max(mean(diag(HH))/100, sum(HH))',1,size(H_st, 1))); % Inverse frequency weights matrix
iH(isnan(iH)) = 0; % Some frequencies are outside analysis range, ie we divide by zero

%% Huffman dictionnary
load dict;

imp_ver = 1;
% ----- END - Matlab ----- %

if ~imp_ver
    %% All-at-once version
    
    % w = hanning(l_frame, 'periodic');
    w = rectwin(l_frame);
    fft_norm = sum(w.^2)*(l_frame/2+1)/(l_frame^2);

    %% Huffman decoding
    X_huff = X_huff(1:X_huff_l);
    X_delta = huffmandeco(X_huff, dict);
    X_delta = reshape(X_delta, size(H_st, 1), []); % To matrix
    
    %% Delta decoding
    X_tob = zeros(size(X_delta));
    prev = zeros(size(X_delta, 1), 1);
    for ind_frame = 1:size(X_delta, 2);
        X_tob(:, ind_frame) = X_delta(:, ind_frame) + prev;
        prev = X_tob(:, ind_frame);
    end
    
    %% Quantization
    X_tob = q_norm(2)*X_tob./(2^(q-1)-1)+q_norm(1);
    
    %% Third-octave bands to spectrogram
    X_tob = 10.^(X_tob/10);
    X_st = iH*X_tob; % Estimate the spectrogram
    
    %% Magnitude spectrogram to STFT
    
    X_st = X_st*fft_norm; % Normalize to conserve the energy of x
    X_st = sqrt(X_st);
    
    n_iter = 20;
    n_frames = size(X_st, 2);
    x_temp = randn(l_frame+(n_frames-1)*l_hop, 1); % Random values initialisation
    iter = 1;
    while iter < n_iter+1 % Griffin and Lim
        disp(['Iteration ' num2str(iter) ' of ' num2str(n_iter) '...']);
        iter = iter+1;
        x_stft = stft(x_temp, l_frame, l_hop, 'rect', 0);
        b = sqrt(sum(w(1:end/2+1)))*X_st.*x_stft./(abs(x_stft)+eps); % As described in G&L paper
        % b = (sqrt(x_spec)/32768).*exp(1i*angle(x_stft)); % Also works
        x_temp = istft(b, l_frame, l_hop, 'rect');
    end
    x_r = x_temp./max(abs(x_temp));
    
else
    %% Alternative version - Texture frames
    % A certainly more realistic implementation would process each frame
    % sequentially, then group windows in texture frames for encoding
    % and transmission

    w = rectwin(l_frame);
    fft_norm = sum(w.^2)*(l_frame/2+1)/(l_frame^2);

    
    
    X_st_all = [];
    l_tf = 8; % Texture frame length in windows
    for ind_tf = 1:length(X_huff_l)
        %% Huffman decoding
        X_delta = huffmandeco(X_huff{ind_tf}(1:X_huff_l{ind_tf}), dict);
        X_delta = reshape(X_delta, size(H_st, 1), []); % To matrix
        
        %% Delta decoding
        X_tob = zeros(size(X_delta));
        prev = zeros(size(X_delta, 1), 1);
        for ind_frame = 1:size(X_delta, 2);
            X_tob(:, ind_frame) = X_delta(:, ind_frame) + prev;
            prev = X_tob(:, ind_frame);
        end
        
        %% Quantization
        X_tob = q_norm{ind_tf}(2)*X_tob./(2^(q-1)-1)+q_norm{ind_tf}(1);
        
        %% Third-octave bands to spectrogram
        X_tob = 10.^(X_tob/10);
        X_st = iH*X_tob; % Estimate the spectrogram
        
        %% Magnitude spectrogram to STFT
        X_st = X_st*fft_norm; % Normalize to conserve the energy of x
        X_st_all(:, end+1:end+size(X_st, 2)) = sqrt(X_st);
    end
    
    n_iter = 20;
    n_frames = size(X_st_all, 2);
    x_temp = randn(l_frame+(n_frames-1)*l_hop, 1); % Random values initialisation
    iter = 1;
    while iter < n_iter+1 % Griffin and Lim
        disp(['Iteration ' num2str(iter) ' of ' num2str(n_iter) '...']);
        iter = iter+1;
        x_stft = stft(x_temp, l_frame, l_hop, 'rect', 0);
        b = sqrt(sum(w(1:end/2+1)))*X_st_all.*x_stft./(abs(x_stft)+eps); % As described in G&L paper
        % b = (sqrt(x_spec)/32768).*exp(1i*angle(x_stft)); % Also works
        x_temp = istft(b, l_frame, l_hop, 'rect');
    end
    x_r = x_temp./max(abs(x_temp));
    
end
