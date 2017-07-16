function config = cecoReport(config)                        
% cecoReport REPORTING of the expLanes experiment censeCoder
%    config = cecoInitReport(config)                        
%       config : expLanes configuration state               
                                                            
% Copyright: felix                                          
% Date: 20-Apr-2017                                         
                                                            
if nargin==0, censeCoder('report', 'r'); return; end%censeCoder('report', 'rhv'); return; end      

% {fps, mel, quant, dictgen, htreealg, textframe, dataset, classmethod, phaserec, desc, intelind, tobhop}

%%% censeCoder('do', [step], 'mask', {fps, mel, quant, dictgen, htreealg, textframe, dataset, classmethod, phaserec, desc, intelind, tobhop});
%%% Error - All quant
% censeCoder('do', [1], 'mask', {-1, -1, 0, -1, -1, -1, 0, -1, -1, 2, -1, 2}); % Third-octave bands
%%% Bitrate - All quant
% censeCoder('do', [2], 'mask', {-1, -1, 0, 1, 2, 10, 2, -1, -1, 2, -1, 2});
%%% Class - All quant
% censeCoder('do', [4], 'mask', {-1, -1, 0, -1, -1, -1, 2, 1, -1, 2, -1, 2});
% censeCoder('do', [4], 'mask', {-1, -1, 0, -1, -1, -1, 2, 2:4, -1, 2, -1, 2});
%%% Intel indicators - All quant
% censeCoder('do', [2 3 4], 'mask', {-1, -1, 2:6, 1, 2, 10, 1, -1, 1, 2, 0, 2});

%%% Error/Class - No averaging, 30 bands, no quant
% censeCoder('do', [1 4], 'mask', {7, 3, 1, -1, -1, -1, 2, 0, -1, 1, -1, -1});
%%% Error/Bitrate/Class - No averaging, 30 bands, all quant
% censeCoder('do', [1 2 4], 'mask', {7, 3, 2:6, 1, 2, 10, 2, 0, -1, 1, -1, -1});
%%% Error/Bitrate/Class - All mel settings, 8 bit
% censeCoder('do', [1 2 4], 'mask', {0, 0, 6, 1, 2, 10, 2, 0, -1, 1, -1, -1});
%%% Intel indicators - All mel settings, 8 bit
% censeCoder('do', [1 2 3 4], 'mask', {0, 0, 6, 1, 2, 10, 1, -1, 1, 1, 0, -1});





%%%% Third octave bands

%%% Error
% Fixed: -
% Varying: Quant - All
%config = expExpose(config, 'p', 'mask', {-1, -1, 2:6, -1, -1, -1, 2, -1, -1, 2, -1, 2}, 'obs', 'q_loss', 'save', 'tob_error', 'step', 1, 'expand', 'quant');

%%% Bitrate
% Fixed: -
% Varying: Quant - All
%config = expExpose(config, 'p', 'mask', {-1, -1, 2:6, 1, 2, 10, 2, -1, -1, 2, -1, 2}, 'obs', 'bitrate', 'save', 'tob_bitrate', 'step', 2, 'expand', 'quant');

%%% Class
% Fixed: -
% Varying: Quant - All
% config = expExpose(config, 'p', 'mask', {-1, -1, 0, -1, -1, -1, 2, 0, -1, 2, -1, 2}, 'obs', 'cv_acc', 'save', 'tob_class', 'step', 4, 'expand', 'quant');

%%% Intel
% Fixed: -
% Varying: Quant - All
%config = expExpose(config, 'p', 'mask', {-1, -1, 2:6, 1, 2, 10, 1, -1, 1, 2, 1, 2}, 'obs', 'csii', 'save', 'tob_csii', 'step', 4);
%config = expExpose(config, 'p', 'mask', {-1, -1, 2:6, 1, 2, 10, 1, -1, 1, 2, 2, 2}, 'obs', 'fwSNRseg', 'save', 'tob_fwSNRseg', 'step', 4);

%%%% Mel bands

%%% Error
% Fixed: Mel - 30, Avg - None
% Varying: Quant - All>0
%config = expExpose(config, 'p', 'mask', {7, 4, 2:6, 1, 2, 10, 2, 0, -1, 1, -1, -1}, 'obs', 'q_loss', 'save', 'mel_error_mel40_avg0_qall', 'step', 1, 'expand', 'quant');
% Fixed: Quant - 8
% Varying: Mel - All, Avg - All
%config = expExpose(config, 'p', 'mask', {0, 0, 6, 1, 2, 10, 2, 0, -1, 1, -1, -1}, 'obs', 'q_loss', 'save', 'mel_error_melall_avgall_q8', 'step', 1);

%%% Bitrate
% Fixed: Mel - 30, Avg - 8
% Varying: Quant - All>0
%config = expExpose(config, 'p', 'mask', {4, 3, 2:6, 1, 2, 10, 2, 0, -1, 1, -1, -1}, 'obs', 'bitrate', 'save', 'mel_bitrate_mel30_avg8_qall', 'step', 2, 'expand', 'quant');
%config = expExpose(config, 'p', 'mask', {4, 4, 2:6, 1, 2, 10, 2, 0, -1, 1, -1, -1}, 'obs', 'bitrate', 'save', 'mel_bitrate_mel40_avg8_qall', 'step', 2, 'expand', 'quant');
% Fixed: Quant - 8
% Varying: Mel - All, Avg - All
% config = expExpose(config, 'p', 'mask', {0, 0, 6, 1, 2, 10, 2, 0, -1, 1, -1, -1}, 'obs', 'bitrate', 'save', 'mel_bitrate_melall_avgall_q8', 'step', 2, 'expand', 'fps');

%%% Class
% Fixed: Mel - 30, Avg - None
% Varying: Quant - All>0
% config = expExpose(config, 'p', 'mask', {7, 4, 2:6, 1, 2, 10, 2, 0, -1, 1, -1, -1}, 'obs', 'cv_acc', 'save', 'mel_class_mel40_avg0_qall', 'step', 4, 'expand', 'quant');
% Fixed: Mel - 30, Avg - None, Quant - None
% Varying: -
% config = expExpose(config, 'p', 'mask', {7, 4, 1, -1, -1, -1, 2, 0, -1, 1, -1, -1}, 'obs', 'cv_acc', 'save', 'mel_class_mel40_avg0_q0', 'step', 4);
% Fixed: Quant - 8
% Varying: Mel - All, Avg - All
% config = expExpose(config, 't', 'mask', {0, 0, 6, 1, 2, 10, 2, 1, -1, 1, -1, -1}, 'obs', 'cv_acc', 'save', 'mel_class_melall_avgall_q8', 'step', 4);

%%% Intel
% Fixed: Quant - 8
% Varying: Mel - All, Avg - All
% config = expExpose(config, 'p', 'mask', {0, 0, 6, 1, 2, 10, 1, -1, 1, 1, 1, -1}, 'obs', 'csii', 'save', 'mel_csii_melall_avgall_q8', 'step', 4, 'expand', 'mel');
% config = expExpose(config, 'p', 'mask', {0, 0, 6, 1, 2, 10, 1, -1, 1, 1, 2, -1}, 'obs', 'fwSNRseg', 'save', 'mel_fwSNRseg_melall_avgall_q8', 'step', 4, 'expand', 'mel');
% config = expExpose(config, 'p', 'mask', {-1, -1, 6, 1, 2, 10, 1, -1, 1, 2, 1, 2, 1:4}, 'obs', 'csii', 'save', 'tob_csii_len', 'step', 4);
% config = expExpose(config, 'p', 'mask', {-1, -1, 6, 1, 2, 10, 1, -1, 1, 2, 2, 2, 1:4}, 'obs', 'fwSNRseg', 'save', 'tob_fwSNRseg_len', 'step', 4);

config = expExpose(config, 'p', 'mask', {-1, -1, 6, 1, 2, 10, 2, 0, -1, 2, -1, 1, 6}, 'obs', 'fwSNRseg', 'save', 'tob_fwSNRseg_len', 'step', 4);


