% Needed for decoding: 
% - Encoded data (X_huff)
% - Normalisation values (q_norm)
% - Length of the encoded data (X_huff_l)

% ----- Function ----- %
% function [X_huff, X_Huff_l, q_norm] = cense_enc(rec_path)
% ----- END - Function ----- %
% ----- Script ----- %
clear all, close all, clc;
rec_path = '../../../decoded_samples/web_examples/clean.wav';
% ----- END - Script ----- %

sr = 32000; % Sampling rate (Hz)
l_frame = 4096; % STFT frame duration, sr/8 rounded to next power of 2 - approx. 128 ms
l_hop = l_frame; % STFT hop size
q = 8; % Quantized word size

% ----- Matlab ----- %
% The following steps are implemented in matlab only

%% File reading and preprocessing
[x, sr_temp] = audioread(rec_path); % ADC input
x = x./max(abs(x)); % Normalise
x = resample(x(:, 1), sr, sr_temp); % Resample to 32kHz
if mod(size(x, 1)-l_frame, l_hop)
    x = [x; zeros(l_hop-mod(size(x, 1)-l_frame, l_hop), 1)]; % Rounding of x size in frames
end

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

% If the weights are stored in vectors, 7% of matrix memory usage
for ind_band = 1:size(H_st, 1)
    f_band{ind_band} = [find(H_st(ind_band,:)~=0, 1) 1+size(H_st, 2)-find(flip(H_st(ind_band,:))~=0, 1)]; % Start and end non-zero weight fft bins
    H_band{ind_band} = H_st(ind_band, H_st(ind_band, :)~=0); % Only keep non-zero weights
end

%% Huffman dictionnary
load dict;

imp_ver = 1;
% ----- END - Matlab ----- %

if ~imp_ver
    %% All-at-once version

    % w = hanning(l_frame, 'periodic');
    w = rectwin(l_frame);
    fft_norm = sum(w.^2)*(l_frame/2+1)/(l_frame^2);

    %% STFT
    n_win = floor(1+(length(x)-l_frame)/l_hop); % Number of windows
    X_st = zeros(l_frame, n_win);
    for ind_frame = 1:n_win
        x_frame = x((ind_frame-1)*l_hop+1:(ind_frame-1)*l_hop+l_frame).*w; % Windowing
        X_st(:, ind_frame) = fft(x_frame); % FFT
    end
    clear ind_frame n_win x_frame;

    %% Magnitude spectrogram
    X_st = X_st(1:end/2+1,:); % Only keep the first half
    X_st = abs(X_st).^2; % Squared magnitude
    X_st = X_st/fft_norm; % Normalize to conserve the energy of x
    
    %% Third-octave bands analysis
    X_tob = H_st*X_st; % Filtering with weight matrix, adds many multiplications by zero and sum terms
    % or
    for ind_band = 1:length(H_band) % Filtering band by band
        X_tob(ind_band, :) = H_band{ind_band}*X_st(f_band{ind_band}(1):f_band{ind_band}(2), :);
    end
    
    X_tob(X_tob == 0) = eps; % Should never happen on real data
    X_tob = 10*log10(X_tob); % dB scale

    %% Quantization
    q_norm(1) = min(min(X_tob));
    X_tob = X_tob-q_norm(1); % Everything has to be positive
    q_norm(2) = max(max(X_tob));
    X_tob = round((2^(q-1)-1)*X_tob./q_norm(2)); % Normalisation + Quantization

    %% Delta encoding along time dimension
    X_delta = zeros(size(X_tob));
    prev = zeros(size(X_tob, 1), 1);
    for ind_frame = 1:size(X_tob, 2);
        X_delta(:, ind_frame) = X_tob(:, ind_frame) - prev;
        prev = X_tob(:, ind_frame);
    end

    %% Huffman encoding
    X_delta = X_delta(:); % To vector
    X_huff = huffmanenco(X_delta, dict);
    X_huff_l = length(X_huff); % Workaround to allow correct decoding of the last byte, needed because the huffman code is not necessarily a multiple of 8

else
    %% Alternative version - Texture frames
    % A certainly more realistic implementation would process each frame
    % sequentially, then group windows in texture frames for encoding
    % and transmission

    w = rectwin(l_frame);
    fft_norm = sum(w.^2)*(l_frame/2+1)/(l_frame^2);

    n_frames = (length(x)-l_frame)/l_hop+1;
    l_tf = 8; % Texture frame length in windows
    f_cnt = 0; % Current frame count
    q_norm = cell(0, 1); X_huff = cell(0, 1); X_huff_l = cell(0, 1);
    
    for ind_frame = 1:n_frames
        f_cnt = f_cnt+1;
        
        %% FFT
        X = fft(x((ind_frame-1)*l_hop+1:(ind_frame-1)*l_hop+l_frame).*w); % FFT of current frame

        %% Magnitude spectrogram
        X = abs(X).^2; % Squared magnitude
        X = X/fft_norm; % Normalize to conserve the energy of x
        X = X(1:end/2+1); % Only keep the first half
        
        %% Third-octave bands analysis
        X_tob(:, f_cnt) = H_st*X; % Filtering with matrix multiplication
        % or
        for ind_band = 1:length(H_band) % Filtering band by band
            X_tob(ind_band, f_cnt) = H_band{ind_band}*X(f_band{ind_band}(1):f_band{ind_band}(2));
        end
        
        X_tob(X_tob == 0) = eps; % Avoid -Inf, Should never happen on real data
        X_tob(:, f_cnt) = 10*log10(X_tob(:, f_cnt)); % dB scale

        if f_cnt == l_tf || ind_frame == n_frames
            %% Quantization
            q_norm{end+1}(1) = min(min(X_tob));
            X_tob = X_tob-q_norm{end}(1); % Everything has to be positive
            q_norm{end}(2) = max(max(X_tob));
            X_tob = round((2^(q-1)-1)*X_tob./q_norm{end}(2)); % Normalisation + Quantization

            %% Delta encoding along time dimension
            X_delta = zeros(size(X_tob));
            prev = zeros(size(X_tob, 1), 1);
            for ind_f = 1:size(X_tob, 2);
                X_delta(:, ind_f) = X_tob(:, ind_f) - prev;
                prev = X_tob(:, ind_f);
            end
            
            %% Huffman encoding
            X_delta = X_delta(:); % To vector
            X_huff{end+1} = huffmanenco(X_delta, dict);
            X_huff_l{end+1} = length(X_huff{end}); % Workaround to allow correct decoding of the last byte, needed because the huffman code is not necessarily a multiple of 8

            % Send X_huff, X_huff_l, q_norm

            f_cnt = 0;
        end
    end
end
