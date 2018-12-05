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
l_tf = 0.5;

% ----- Matlab ----- %
% The following steps are implemented in matlab only

%% File reading and preprocessing
[x, sr_temp] = audioread(rec_path); % ADC input
x = x./max(abs(x)); % Normalise
x = resample(x(:, 1), sr, sr_temp); % Resample to 32kHz

sig_type = 'White noise';
sig_type = 'Sweep';
%sig_type = 'Sine_440';
%sig_type = 'Sine_440_emb';

switch sig_type
    case 'White noise'
        x = randn(1*sr, 1);
        res_file = fopen('res_wn.txt', 'w');
    case 'Sweep'
        t = (0:1/sr:1)';
        x = chirp(t, 0, 1, 15000);
        res_file = fopen('res_sweep.txt', 'w');
    case 'Sine_440'
        t = (0:1/sr:1)';
        x = sin(2*pi*440*t/sr);
        res_file = fopen('res_sine440.txt', 'w');
    case 'Sine_440_emb'
        x = csvread('sinus_440_emb.txt');
        x = x(1:end-1)';
        res_file = fopen('res_sine440emb.txt', 'w');
    otherwise
end


if mod(size(x, 1)-l_frame, l_hop)
    x = [x; zeros(l_hop-mod(size(x, 1)-l_frame, l_hop), 1)]; % Rounding of x size in frames
end

%% Weight matrix, constant
% N = 2^(ceil(log2(l_frame)));
% N_filt = 2^20; % Design with a much higher precision
% G = third_octave_filterbank(sr, N_filt, -17:11, 3);
% G = G.^2;
% G_mean(:, 1) = mean(G(:, 1:1+round(N_filt/(2*N))), 2);
% G_mean(:, N/2+1) = mean(G(:, 1+(N/2)*round(N_filt/N)-round(N_filt/(2*N)):end), 2);
% for ind_f = 2:N/2
%     G_mean(:, ind_f) = mean(G(:, 1+(ind_f-1)*round(N_filt/N)-round(N_filt/(2*N)):1+(ind_f-1)*round(N_filt/N)+round(N_filt/(2*N))), 2);
% end
% H_st = G_mean;
% clear ind_f N_filt G G_mean;
% save('tob_m_4096.mat', 'H_st');
% 
% % If the weights are stored in vectors, 7% of matrix memory usage
% for ind_band = 1:size(H_st, 1)
%     f_band{ind_band} = [find(H_st(ind_band,:)~=0, 1) 1+size(H_st, 2)-find(flip(H_st(ind_band,:))~=0, 1)]; % Start and end non-zero weight fft bins
%     H_band{ind_band} = H_st(ind_band, H_st(ind_band, :)~=0); % Only keep non-zero weights
% end
% save('tob_a_4096.mat', 'f_band', 'H_band');

% load tob_m_4096; % Matrix weights
load tob_a_4096; % Array weights

%% Write weights in file
tob_file = fopen('tob_filterbank.txt', 'w');
for ind_band = 1:length(f_band)
    fwrite(tob_file, ['double f_band_' num2str(ind_band) '[' num2str(length(f_band{ind_band})) '] = {' num2str(f_band{ind_band}(1)) ', ' num2str(f_band{ind_band}(2)) '};' 10]);
    fwrite(tob_file, ['double H_band_' num2str(ind_band) '[' num2str(length(H_band{ind_band})) '] = {']);
    for ind_weight = 1:length(H_band{ind_band})-1
        fwrite(tob_file, [num2str(H_band{ind_band}(ind_weight)) ', ']);
    end
    fwrite(tob_file, [num2str(H_band{ind_band}(end))]);
    fwrite(tob_file, ['};' 10 10]);
end
fclose(tob_file);

%% Huffman dictionnary
load dict;

imp_ver = 1;

fwrite(res_file, ['// ----- White noise results -----' 10]);
fwrite(res_file, ['// Parameters:' 10]);
fwrite(res_file, ['//  - Sample rate (Hz) = ' num2str(sr) 10]);
fwrite(res_file, ['//  - Analysis frame duration (Samples) = ' num2str(l_frame) 10]);
fwrite(res_file, ['//  - Analysis frame overlap (Samples) = ' num2str(l_hop) 10]);
fwrite(res_file, ['//  - Quantization parameter q = ' num2str(q) 10]);
fwrite(res_file, ['//  - Texture frame duration (s) = ' num2str(l_tf) 10]);
fwrite(res_file, ['//  - Signal: ' sig_type 10]);
fwrite(res_file, [10]);

fwrite(res_file, ['// Audio' 10]);
fwrite(res_file, ['double x[' num2str(length(x)) '] = {']);
n_line = 0;
for ind_x = 1:length(x)-1
    n_line = n_line+1;
    fwrite(res_file, [num2str(x(ind_x)) ', ']);
    if n_line == 100
        n_line = 0;
        fwrite(res_file, [10]);
    end
end
fwrite(res_file, [num2str(x(end))]);
fwrite(res_file, ['};' 10 10]);


% ----- END - Matlab ----- %

if ~imp_ver
    %% All-at-once version

    % w = hanning(l_frame, 'periodic');
    w = rectwin(l_frame);
    fft_norm = sum(w.^2)/l_frame;
    
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
%     X_tob = H_st*X_st; % Filtering with weight matrix, adds many multiplications by zero and sum terms
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
    X_delta_v = X_delta(:); % To vector
    X_huff = huffmanenco(X_delta_v, dict);
    X_huff_l = length(X_huff); % Workaround to allow correct decoding of the last byte, needed because the huffman code is not necessarily a multiple of 8

else
    %% Alternative version - Texture frames
    % A certainly more realistic implementation would process each frame
    % sequentially, then group windows in texture frames for encoding
    % and transmission

    w = rectwin(l_frame);
    fft_norm = sum(w.^2)*(l_frame/2+1)/(l_frame^2);

    n_frames = (length(x)-l_frame)/l_hop+1;
    l_tf = 4; % Texture frame length in windows
    f_cnt = 0; % Current frame count
    q_norm = cell(0, 1); X_huff = cell(0, 1); X_huff_l = cell(0, 1);
    ind_tf = 0;
    
    for ind_frame = 1:n_frames
        f_cnt = f_cnt+1;

        %% FFT
        X = fft(x((ind_frame-1)*l_hop+1:(ind_frame-1)*l_hop+l_frame).*w); % FFT of current frame

        %% Magnitude spectrogram
        X = X(1:end/2+1); % Only keep the first half
        X = abs(X).^2; % Squared magnitude
        X = X/fft_norm; % Normalize to conserve the energy of x

        fwrite(res_file, ['// RFFT + Magnitude Spectrum (Frame' num2str(ind_frame) ')' 10]);
        fwrite(res_file, ['double X_' num2str(ind_frame) '[' num2str(length(X)) '] = {']);
        n_line = 0;
        for ind_x = 1:length(X)-1
            n_line = n_line+1;
            fwrite(res_file, [num2str(X(ind_x)) ', ']);
            if n_line == 100
                n_line = 0;
                fwrite(res_file, [10]);
            end
        end
        fwrite(res_file, [num2str(X(end))]);
        fwrite(res_file, ['};' 10 10]);


        %% Third-octave bands analysis
%         X_tob(:, f_cnt) = H_st*X; % Filtering with matrix multiplication
        % or
        for ind_band = 1:length(H_band) % Filtering band by band
            X_tob(ind_band, f_cnt) = H_band{ind_band}*X(f_band{ind_band}(1):f_band{ind_band}(2));
        end

        X_tob(X_tob == 0) = eps; % Avoid -Inf, Should never happen on real data
        X_tob(:, f_cnt) = 10*log10(X_tob(:, f_cnt)); % dB scale

        plot(X_tob)
        fwrite(res_file, ['// Third Octave Analysis + log10 (Frame' num2str(ind_frame) ')' 10]);
        fwrite(res_file, ['double X_tob' num2str(ind_frame) '[' num2str(size(X_tob, 1)) '] = {']);
        n_line = 0;
        for ind_x = 1:size(X_tob, 1)-1
            n_line = n_line+1;
            fwrite(res_file, [num2str(X_tob(ind_x, f_cnt)) ', ']);
            if n_line == 100
                n_line = 0;
                fwrite(res_file, [10]);
            end
        end
        fwrite(res_file, [num2str(X_tob(end, f_cnt))]);
        fwrite(res_file, ['};' 10 10]);

        if f_cnt == l_tf || ind_frame == n_frames
            ind_tf = ind_tf+1;
            %% Quantization
            q_norm{end+1}(1) = min(min(X_tob));
            X_tob = X_tob-q_norm{end}(1); % Everything has to be positive
            q_norm{end}(2) = max(max(X_tob));
            X_tob = round((2^(q-1)-1)*X_tob./q_norm{end}(2)); % Normalisation + Quantization

            if n_frames>1
                fwrite(res_file, ['// Quantization (Texture frame' num2str(ind_tf) ')' 10]);
                fwrite(res_file, ['double X_tob_q' num2str(ind_tf) '[' num2str(size(X_tob, 1)) '][' num2str(size(X_tob, 2)) '] = {']);
                for ind_f = 1:size(X_tob, 2)-1
                    n_line = 0;
                    fwrite(res_file, ['{']);
                    for ind_x = 1:size(X_tob, 1)-1
                        n_line = n_line+1;
                        fwrite(res_file, [num2str(X_tob(ind_x, ind_f)) ', ']);
                        if n_line == 100
                            n_line = 0;
                            fwrite(res_file, [10]);
                        end
                    end
                    fwrite(res_file, [num2str(X_tob(end, ind_f))]);
                    fwrite(res_file, ['}, ' 10]);
                end
                n_line = 0;
                fwrite(res_file, ['{']);
                for ind_x = 1:size(X_tob, 1)-1
                    n_line = n_line+1;
                    fwrite(res_file, [num2str(X_tob(ind_x, ind_f)) ', ']);
                    if n_line == 100
                        n_line = 0;
                        fwrite(res_file, [10]);
                    end
                end
                fwrite(res_file, [num2str(X_tob(end, ind_f))]);
                fwrite(res_file, ['}']);
                fwrite(res_file, ['};' 10 10]);
            else
                fwrite(res_file, ['// Quantization (Texture frame' num2str(ind_tf) ')' 10]);
                fwrite(res_file, ['double X_tob_q' num2str(ind_tf) '[' num2str(size(X_tob, 1)) '] = {']);
                for ind_x = 1:size(X_tob, 1)-1
                    fwrite(res_file, [num2str(X_tob(ind_x)) ', ']);
                end
                fwrite(res_file, [num2str(X_tob(end))]);
                fwrite(res_file, ['}' 10 10]);
            end

            %% Delta encoding along time dimension
            X_delta = zeros(size(X_tob));
            prev = zeros(size(X_tob, 1), 1);
            for ind_f = 1:size(X_tob, 2);
                X_delta(:, ind_f) = X_tob(:, ind_f) - prev;
                prev = X_tob(:, ind_f);
            end

            if n_frames>1
                fwrite(res_file, ['// Delta Compression (Texture frame' num2str(ind_tf) ')' 10]);
                fwrite(res_file, ['double X_delta' num2str(ind_tf) '[' num2str(size(X_delta, 1)) '][' num2str(size(X_delta, 2)) '] = {']);
                for ind_f = 1:size(X_delta, 2)-1
                    n_line = 0;
                    fwrite(res_file, ['{']);
                    for ind_x = 1:size(X_delta, 1)-1
                        n_line = n_line+1;
                        fwrite(res_file, [num2str(X_delta(ind_x, ind_f)) ', ']);
                        if n_line == 100
                            n_line = 0;
                            fwrite(res_file, [10]);
                        end
                    end
                    fwrite(res_file, [num2str(X_delta(end, ind_f))]);
                    fwrite(res_file, ['}, ' 10]);
                end
                n_line = 0;
                fwrite(res_file, ['{']);
                for ind_x = 1:size(X_delta, 1)-1
                    n_line = n_line+1;
                    fwrite(res_file, [num2str(X_delta(ind_x, ind_f)) ', ']);
                    if n_line == 100
                        n_line = 0;
                        fwrite(res_file, [10]);
                    end
                end
                fwrite(res_file, [num2str(X_delta(end, ind_f))]);
                fwrite(res_file, ['}']);
                fwrite(res_file, ['};' 10 10]);
            else
                fwrite(res_file, ['// Delta Compression (Texture frame' num2str(ind_tf) ')' 10]);
                fwrite(res_file, ['double X_delta' num2str(ind_tf) '[' num2str(size(X_delta, 1)) '] = {']);
                for ind_x = 1:size(X_delta, 1)-1
                    fwrite(res_file, [num2str(X_delta(ind_x)) ', ']);
                end
                fwrite(res_file, [num2str(X_delta(end))]);
                fwrite(res_file, ['}' 10 10]);
            end


            %% Huffman encoding
            X_delta_v = X_delta(:); % To vector
            X_huff{end+1} = huffmanenco(X_delta_v, dict);
            X_huff_l{end+1} = length(X_huff{end}); % Workaround to allow correct decoding of the last byte, needed because the huffman code is not necessarily a multiple of 8

            % Send X_huff, X_huff_l, q_norm

            fwrite(res_file, ['// Huffman Compression (Texture frame' num2str(ind_tf) ')' 10]);
            fwrite(res_file, ['double X_huff' num2str(ind_tf) '[' num2str(size(X_huff{end}, 1)) '] = {']);
            n_line = 0;
            for ind_x = 1:length(X_huff{end})-1
                n_line = n_line+1;
                fwrite(res_file, [num2str(X_huff{end}(ind_x)) ', ']);
                if n_line == 100
                    n_line = 0;
                    fwrite(res_file, [10]);
                end
            end
            fwrite(res_file, [num2str(X_huff{end}(end))]);
            fwrite(res_file, ['};' 10 10]);

            f_cnt = 0;
        end
    end
end

% ----- Matlab ----- %
fclose(res_file);
save('data_enc.mat', 'X_huff', 'X_huff_l', 'q_norm');
% ----- END - Matlab ----- %
