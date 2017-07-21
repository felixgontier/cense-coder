function config = toerReport(config)                      
% toerReport REPORTING of the expLanes experiment tobError
%    config = toerInitReport(config)                      
%       config : expLanes configuration state             
                                                          
% Copyright: felix                                        
% Date: 12-Jul-2017                                       
                                                          
if nargin==0, tobError('report', 'r'); return; end      
                                                          
% %% Noise
% config = expExpose(config, 't', 'mask', {12, 1, 1, 0}, 'obs', 0, 'save', 'tobErr_n_rlen_f', 'step', 3);
% config = expExpose(config, 't', 'mask', {0, 1, 1, 4}, 'obs', 0, 'save', 'tobErr_n_win_f', 'step', 3);
% 
% %% Speech
% config = expExpose(config, 't', 'mask', {12, 2, 1, 0}, 'obs', 0, 'save', 'tobErr_s_rlen_f', 'step', 3);
% config = expExpose(config, 't', 'mask', {0, 2, 1, 4}, 'obs', 0, 'save', 'tobErr_s_win_f', 'step', 3);
% 
% %% US8k
% config = expExpose(config, 't', 'mask', {12, 3, 1, 0}, 'obs', 0, 'save', 'tobErr_u_rlen_f', 'step', 3);
% config = expExpose(config, 't', 'mask', {0, 3, 1, 4}, 'obs', 0, 'save', 'tobErr_u_win_f', 'step', 3);

% %% Noise
% config = expExpose(config, 't', 'mask', {12, 1, 2, 4:10}, 'obs', 0, 'save', 'tobErr_n_rlen_s', 'step', 3);
% config = expExpose(config, 't', 'mask', {0, 1, 2, 4}, 'obs', 0, 'save', 'tobErr_n_win_s', 'step', 3);
% 
% %% Speech
% config = expExpose(config, 't', 'mask', {12, 2, 2, 4:10}, 'obs', 0, 'save', 'tobErr_s_rlen_s', 'step', 3);
% config = expExpose(config, 't', 'mask', {0, 2, 2, 4}, 'obs', 0, 'save', 'tobErr_s_win_s', 'step', 3);
% 
% %% US8k
% config = expExpose(config, 't', 'mask', {12, 3, 2, 4:10}, 'obs', 0, 'save', 'tobErr_u_rlen_s', 'step', 3);
% config = expExpose(config, 't', 'mask', {0, 3, 2, 4}, 'obs', 0, 'save', 'tobErr_u_win_s', 'step', 3);

% config = expExpose(config, 't', 'mask', {12, 1, 1, 4, 2}, 'obs', 0, 'save', 'tobErr_test', 'step', 3);
config = expExpose(config, 't', 'mask', {[1 6 12 17], 1, 0, 6, 2}, 'obs', 0, 'save', 'tobErr_noise', 'step', 3);
config = expExpose(config, 't', 'mask', {[1 6 12 17], 3, 0, 6, 2}, 'obs', 0, 'save', 'tobErr_us8k', 'step', 3);
