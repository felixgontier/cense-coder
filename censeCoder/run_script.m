clear all, close all, clc;

%% 8 bit quant, varying fps/mel
% censeCoder('do', [1 2 4], 'mask', {0, 0, 6, 1, 2, 10, 2, 4, 2, 1, 2});
% censeCoder('do', [1 2 3 4], 'mask', {0, 0, 6, 1, 2, 10, 1, 4, 1, 1, 2});
%censeCoder('do', [3], 'mask', {0, 0, 6, 1, 2, 10, 1, 4, 1, 2, 1});
% %% Baseline
% censeCoder('do', [1 4], 'mask', {7, 3, 1, 1, 2, 10, 2, 1, 2, 1, 2});

%% Global run
%%% censeCoder('do', [step], 'mask', {fps, mel, quant, dictgen, htreealg, textframe, dataset, classmethod, phaserec, desc, intelind, tobhop});
% censeCoder('do', [1], 'mask', {-1, -1, 0, -1, -1, -1, 0, -1, -1, 2, -1, 2}); % Third-octave bands
% censeCoder('do', [2], 'mask', {-1, -1, 0, 1, 2, 10, 2, -1, -1, 2, -1, 2});
% censeCoder('do', [4], 'mask', {-1, -1, 0, -1, -1, -1, 2, 1, -1, 2, -1, 2});

% censeCoder('do', [1 4], 'mask', {7, 3, 1, -1, -1, -1, 2, 0, -1, 1, -1, -1});
% censeCoder('do', [1 2 4], 'mask', {0, 0, 6, 1, 2, 10, 2, 4, -1, 1, -1, -1});
% censeCoder('do', [1 2 3 4], 'mask', {0, 0, 6, 1, 2, 10, 1, -1, 1, 1, 0, -1});
% censeCoder('do', [4], 'mask', {0, 0, 6, 1, 2, 10, 2, 1:3, -1, 1, -1, -1});
censeCoder('do', [1 2 4], 'mask', {7, 3, 2:6, 1, 2, 10, 2, 0, -1, 1, -1, -1});
