%clear all, close all, clc;

%% Noise
% tobError('do', 1:3, 'mask', {0, 1, 1, 4});
% tobError('do', 1:3, 'mask', {12, 1, 1, 0});

%% Speech
% tobError('do', 1:3, 'mask', {0, 2, 1, 4, 2});
% tobError('do', 1:3, 'mask', {12, 2, 1, 0, 2});

%% US8k
% tobError('do', 1:3, 'mask', {0, 3, 1, 4});
% tobError('do', 1:3, 'mask', {12, 3, 1, 0});

%% Noise
% tobError('do', 1:3, 'mask', {0, 1, 2, 4});
% tobError('do', 1:3, 'mask', {12, 1, 2, 4:10});

%% Speech
% tobError('do', 1:3, 'mask', {0, 2, 2, 4});
% tobError('do', 1:3, 'mask', {12, 2, 2, 4:10});

%% US8k
% tobError('do', 1:3, 'mask', {0, 3, 2, 4});
% tobError('do', 1:3, 'mask', {12, 3, 2, 4:10});

%% Noise
% tobError('do', [1 2 3], 'mask', {12, 1, 1, 4, 2});
% tobError('do', [3], 'mask', {12, 1, 1, 4, 2});
% [1 6 12 17]
% tobError('do', [1 3], 'mask', {12, 1, 2, 6, 2});
tobError('do', [3], 'mask', {17, 3, 0, 6, 2});

