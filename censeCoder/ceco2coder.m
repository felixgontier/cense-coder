function [config, store, obs] = ceco2coder(config, setting, data)                
% ceco2coder CODER step of the expLanes experiment censeCoder                    
%    [config, store, obs] = ceco2coder(config, setting, data)                    
%      - config : expLanes configuration state                                   
%      - setting   : set of factors to be evaluated                              
%      - data   : processing data stored during the previous step                
%      -- store  : processing data to be saved for the other steps               
%      -- obs    : observations to be saved for analysis                         
                                                                                 
% Copyright: felix                                                               
% Date: 20-Apr-2017                                                              
                                                                                 
% Set behavior for debug mode                                                    
if nargin==0, censeCoder('do', 2, 'mask', {}); return; else store=[]; obs=[]; end
           
%% TODO: add support of global dict
sr = 44100;
l_frame = 4096;
l_hop = 0.5*l_frame;
if setting.fps % 0 means none
    n_fps = setting.fps; % Number of frames per second with custom settings
else
    n_fps = (sr+l_hop-l_frame)/l_hop; % Number of frames per second with base settings
end

%% Reformatting of x_mel
x_mel_mat = 0;
for ind_fold = 1:length(data.x_mel)
    for ind_file = 1:length(data.x_mel{ind_fold})
        x_mel_mat(1:setting.mel, end+1:end+size(data.x_mel{ind_fold}{ind_file}, 2)) = data.x_mel{ind_fold}{ind_file};
    end
end

%% 10-minutes frames encoding
l_frame = ceil(60*setting.textframe*n_fps); % length of a texture frame in windows
n_frames = ceil(size(x_mel_mat, 2)/l_frame);
for ind_frame = 1:n_frames
    disp(['Processing frame ' num2str(ind_frame) ' of ' num2str(n_frames) '...']);
    %% Frames
    x_frame = x_mel_mat(:, (ind_frame-1)*l_frame+1:min(ind_frame*l_frame, end))'; % Transpose to group by features rather than time windows when reshaping to vector
    x_frame = x_frame(:); % Vector reformatting
    %% Delta compression
    x_delta = delta_enc(x_frame);
    %% Huffman encoding
    switch setting.dictgen
        case 'local'
            [symbol, prob] = huff_dict(x_delta, 'sort'); % DdP
            dict{ind_frame} = huffmandict(symbol, prob, 2, setting.htreealg); % Tree generation
            x_huff{ind_frame} = huffmanenco(x_delta, dict{ind_frame});
            huff_len(ind_frame) = length(x_huff{ind_frame}); % Workaround to allow correct decoding of the last byte, needed because the huffman code is not necessarily a multiple of 8
            code_len(ind_frame) = huff_len(ind_frame);
            for ind_del = 1:size(dict{ind_frame}, 1) % Size of local dictionnary
                code_len(ind_frame) = code_len(ind_frame) + 2*(setting.quant) + length(dict{ind_frame}{ind_del, 2});
            end
        case 'global'
            if ind_frame == 1
                x_mel_all = x_mel_mat';
                x_mel_all = x_mel_all(:);
                x_delta_all = delta_enc(x_mel_all);
                [symbol, prob] = huff_dict(x_delta_all, 'unique', setting.quant); % DdP
                dict = huffmandict(symbol, prob, 2, setting.htreealg); % Tree generation
                clear x_mel_all x_delta_all;
            end
            x_huff{ind_frame} = huffmanenco(x_delta, dict);
            huff_len(ind_frame) = length(x_huff{ind_frame}); % Workaround to allow correct decoding of the last byte, needed because the huffman code is not necessarily a multiple of 8
            code_len(ind_frame) = huff_len(ind_frame);
    end
    x_huff{ind_frame} = bin2dec(reshape(num2str([x_huff{ind_frame}(1:end-mod(end, 8)); x_huff{ind_frame}(end-mod(end, 8)+1:end); zeros(8-mod(length(x_huff{ind_frame}), 8), 1)]), 8, [])');
end
bitrate = sum(code_len)/length(x_huff)/setting.textframe/60;

%% Outputs
% Store
store.x_huff = x_huff;
store.dict = dict;
store.huff_len = huff_len;
store.x_mel_max = data.x_mel_max;
store.n_frames = data.n_frames;
if setting.fps; store.n_frames_avg = data.n_frames_avg; end

% Observations
obs.code_len = code_len;
obs.bitrate = bitrate;
