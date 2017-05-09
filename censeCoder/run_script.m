clear all, close all, clc;

%% 8 bit quant, varying fps/mel
censeCoder('do', [1 2 4], 'mask', {0, 0, 6, 1, 2, 10, 0, 4, 2});
censeCoder('do', 3, 'mask', {0, 0, 6, 1, 2, 10, 1, 4, 2});
%% Baseline
%censeCoder('do', [1 4], 'mask', {7, 4, 1, 1, 2, 10, 0, 4, 2});
censeCoder('do', [4], 'mask', {7, 4, 1, 1, 2, 10, 0, 4, 2});
