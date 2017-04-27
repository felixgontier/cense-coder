function [config, store, obs] = ceco4decoder(config, setting, data)              
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
if nargin==0, censeCoder('do', 4, 'mask', {}); return; else store=[]; obs=[]; end
                                                                                 
%% TODO: Swap steps 3 and 4 for a cleaner structure as decoding requires step 2 output

addpath(genpath('C:\Program Files\MATLAB\R2015b\toolbox\rastamat'));

load_data = expLoad(config, [], 2);

sr = 44100;
l_frame = 4096;
l_hop = 0.5*l_frame;
if setting.fps % 0 means none
    n_fps = (sr+l_hop-l_frame)/l_hop; % Number of frames per second with base settings
    n_avg = ceil(n_fps/setting.fps); % Number of consecutive frames to average into one
end


x_mel_mat = [];
for indframe = 1:numel(load_data.x_huff)
    %% Matlab needs binary vectors
    x_huff = str2num(reshape(dec2bin(load_data.x_huff{indframe})', [], 1));
    x_huff = x_huff(1:load_data.huff_len(indframe));
    %% Huffman decoding
    switch setting.dictgen
        case 'local'
            x_delta = huffmandeco(x_huff, load_data.dict{indframe});
        case 'global'
            x_delta = huffmandeco(x_huff, load_data.dict);
    end
    %% Delta decoding
    x_frame = delta_dec(x_delta);
    %% Reformatting
    x_mel_mat = [x_mel_mat reshape(x_frame, [], setting.mel)'];
end

%% File reconstruction
mel_p = 0;
for ind_fold = 1:length(load_data.x_mel_max)
    for ind_file = 1:length(load_data.x_mel_max{ind_fold})
        %% Fold/File separation
        if setting.fps
            x_mel = x_mel_mat(:, mel_p+1:mel_p+load_data.n_frames_avg{ind_fold}{ind_file});
        else
            x_mel = x_mel_mat(:, mel_p+1:mel_p+load_data.n_frames{ind_fold}{ind_file});
        end
        mel_p = mel_p + size(x_mel, 2);
        
        %% Normalisation
        if setting.quant ~= 0
            x_mel = load_data.x_mel_max{ind_fold}{ind_file}*double(x_mel)/(2^(setting.quant-1)-1);
        end
        x_mel = exp(x_mel);
        
        %% Reconstruction of the linearly-scaled spectrogram
        x_spec = invaudspec(x_mel, sr, l_frame, 'mel', 0, sr/2, 1, 1);
        
        %% Averaging expansion
        if setting.fps
            x_spec = reshape(repmat(x_spec, n_avg, 1), size(x_spec, 1), []); % Replicate STFT
            x_spec = x_spec(:, 1:load_data.n_frames{ind_fold}{ind_file}); % Truncate to obtain same size as before averaging
        end
        x_spec(x_spec == 0) = eps;
        
        %% Signal/Phase reconstruction
        x{ind_fold}{ind_file} = invpowspec(x_spec, sr, l_frame/sr, l_hop/sr);
    end
end

sound(x{1}{1}, sr);
