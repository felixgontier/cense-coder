function config = cecoReport(config)                        
% cecoReport REPORTING of the expLanes experiment censeCoder
%    config = cecoInitReport(config)                        
%       config : expLanes configuration state               
                                                            
% Copyright: felix                                          
% Date: 20-Apr-2017                                         
                                                            
if nargin==0, censeCoder('report', 'r'); return; end%censeCoder('report', 'rhv'); return; end      

% {fps, mel, quant, dictgen, htreealg, textframe, dataset, classmethod, phaserec, desc, intelind, tobhop}

%% KNN
% config = expExpose(config, 'p', 'mask', {0, 0, 6, 1, 2, 10, 2, 4, 2}, 'obs', 'cv_acc', 'save', 'knn_fps_mel_8', 'step', 4, 'expand', 1, 'color', {'b', 'g', 'r', 'black'}); % KNN accuracy as f(mel,fps)
% config = expExpose(config, 't', 'mask', {7, 4, 1, 1, 2, 10, 2, 4, 2}, 'obs', 'cv_acc', 'save', 'knn_base', 'step', 4); % Baseline KNN accuracy

%% CSII
% config = expExpose(config, 'p', 'mask', {0, 0, 6, 1, 2, 10, 1, 4, 2}, 'obs', 'csii', 'save', 'csii_fps_mel_8', 'step', 4, 'expand', 2, 'color', 'k'); % CSII indicator as f(mel,fps)
config = expExpose(config, 'p', 'mask', {0, 0, 6, 1, 2, 10, 1, 4, 2}, 'obs', 'fwsnrseg', 'save', 'csii_fps_mel_8', 'step', 4, 'expand', 2, 'color', 'k'); % CSII indicator as f(mel,fps)

% config = expExpose(config, 't', 'mask', {7, 4, 1, 1, 2, 10, 1, 4, 2}, 'obs', 'csii', 'save', 'csii_base', 'step', 4); % Baseline CSII
%config = expExpose(config, 'p', 'mask', {0, 0, 6, 1, 2, 10, 1, 4, 2}, 'obs', 'msc_mat', 'step', 4); % Baseline CSII

%% Bitrate
% config = expExpose(config, 'p', 'mask', {0, 0, 6, 1, 2, 10, 2, 4, 2}, 'obs', 'bitrate', 'save', 'bitrate_fps_mel_8', 'step', 2, 'expand', 1, 'color', 'k'); % Mean output bitrate as f(mel,fps)

%% Quantization noise
% config = expExpose(config, 'p', 'mask', {7, 4, 6, 1, 2, 10, 2, 4, 2}, 'obs', 'q_loss', 'save', 'qloss_fps_mel_8', 'step', 1, 'expand', 2, 'color', 'k'); % CSII indicator as f(mel,fps)
% config = expExpose(config, 't', 'mask', {7, 4, 1, 1, 2, 10, 1, 4, 2}, 'obs', 'csii', 'save', 'csii_base', 'step', 4); % Baseline CSII
%config = expExpose(config, 'p', 'mask', {0, 0, 6, 1, 2, 10, 1, 4, 2}, 'obs', 'msc_mat', 'step', 4); % Baseline CSII
