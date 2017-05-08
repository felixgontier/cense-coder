function config = cecoReport(config)                        
% cecoReport REPORTING of the expLanes experiment censeCoder
%    config = cecoInitReport(config)                        
%       config : expLanes configuration state               
                                                            
% Copyright: felix                                          
% Date: 20-Apr-2017                                         
                                                            
if nargin==0, censeCoder('report', 'r'); return; end%censeCoder('report', 'rhv'); return; end      

%% KNN
% config = expExpose(config, 'p', 'mask', {0, 0, 6, 1, 2, 10, 2, 4}, 'obs', 'cv_acc', 'save', 1, 'step', 3, 'expand', 1, 'color', {'b', 'g', 'r', 'black'}); % KNN accuracy as f(mel,fps)
% config = expExpose(config, 't', 'mask', {7, 4, 1, 1, 2, 10, 2, 4}, 'obs', 'cv_acc', 'save', 1, 'step', 3); % Baseline KNN accuracy

%% CSII
config = expExpose(config, 'p', 'mask', {0, 0, 6, 1, 2, 10, 1, 4}, 'obs', 'csii', 'save', 1, 'step', 3, 'expand', 2, 'color', 'k'); % CSII indicator as f(mel,fps)
config = expExpose(config, 't', 'mask', {7, 4, 1, 1, 2, 10, 1, 4}, 'obs', 'csii', 'save', 1, 'step', 3); % Baseline CSII

%% Bitrate
% config = expExpose(config, 'p', 'mask', {0, 0, 6, 1, 2, 10, 2, 4}, 'obs', 'bitrate', 'save', 1, 'step', 2, 'expand', 1, 'color', 'k'); % Mean output bitrate as f(mel,fps)
