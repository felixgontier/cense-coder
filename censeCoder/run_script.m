clear all, close all, clc;

%% Global run
%%% censeCoder('do', [step], 'mask', {fps, mel, quant, dictgen, htreealg, textframe, dataset, classmethod, phaserec, desc, intelind, tobhop, toblen});
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
%%% Error/Bitrate/Class - 8 fps, 40 bands, all quant
% censeCoder('do', [1 2], 'mask', {4, 4, 2:6, 1, 2, 10, 2, -1, -1, 1, -1, -1});
% censeCoder('do', [4], 'mask', {7, 4, 2:6, 1, 2, 10, 2, 0, -1, 1, -1, -1});
% censeCoder('do', [1 4], 'mask', {7, 4, 1, 1, 2, 10, 2, 0, -1, 1, -1, -1});

% censeCoder('do', [1 2 4], 'mask', {7, 4, 2:6, 1, 2, 10, 2, 0, -1, 1, -1, -1});
%%% Error/Bitrate/Class - All mel settings, 8 bit
% censeCoder('do', [2], 'mask', {1:5, 0, 6, 1, 2, 10, 2, 0, -1, 1, -1, -1});
% censeCoder('do', [1 2 4], 'mask', {0, 0, 6, 1, 2, 10, 2, 0, -1, 1, -1, -1});
%%% Intel indicators - All mel settings, 8 bit
% censeCoder('do', [1 2 3 4], 'mask', {0, 0, 6, 1, 2, 10, 1, -1, 1, 1, 0, -1});
% censeCoder('do', [4], 'mask', {4, 4, 6, 1, 2, 10, 2, 1, -1, 0, -1, 2});
 
% censeCoder('do', [1 2 3], 'mask', {0, 0, 6, 1, 2, 10, 1, -1, 1, 1, -1, -1});
% censeCoder('do', [3], 'mask', {0, 0, 6, 1, 2, 10, 1, -1, 1, 1, -1, -1});
% censeCoder('do', [1 2 3], 'mask', {-1, -1, 0, 1, 2, 10, 1, -1, 1, 2, -1, 1});
% censeCoder('do', [1 2 3], 'mask', {-1, -1, 0, 1, 2, 10, 1, -1, 1, 2, -1, 2});
censeCoder('do', [1 2 3 4], 'mask', {-1, -1, 6, 1, 2, 10, 1, -1, 1, 2, 0, 2, 1:4});
