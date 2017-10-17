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

% tobError('do', [3], 'mask', {1, [1 3], 0, 6, 2});
% tobError('do', [1 3], 'mask', {17, [1 3], 0, 6, 2, 0});
% tobError('do', [1 3], 'mask', {[1 17], [1], 0, 6, 2, 0});
% tobError('do', [3], 'mask', {[1], [3], 2, 6, 2, 3, 2});
% tobError('do', [3], 'mask', {[17], [3], 2, 6, 2, 3, 2});
% tobError('do', [3], 'mask', {[17], [3], 2, 6, 2, 3, 2});
%% DONE
%% Not used
% 125ms - 66% overlap - Rect
% tobError('do', [4], 'mask', {17, 3, 1, 6, 2, 4, 0});
% 1s - 66% overlap - Rect
% tobError('do', [4], 'mask', {17, 3, 2, 6, 2, 4, 0});
% 125ms - No overlap - Hann
% tobError('do', [4], 'mask', {2, 3, 1, 6, 2, 3, 0});
% 1s - 50% overlap - Hann
% tobError('do', [4], 'mask', {2, 3, 2, 6, 2, 2, 0});

%% Used
% 125ms - No overlap - Rect
% tobError('do', [1], 'mask', {17, 3, 1, 6, 2, 3, 1});
% tobError('do', [4], 'mask', {17, 3, 1, 6, 2, 3, 0});
% 1s - 50% overlap - Rect
% tobError('do', [1], 'mask', {17, 3, 2, 6, 2, 2, 1});
% tobError('do', [4], 'mask', {17, 3, 2, 6, 2, 2, 0});
% 1s - 66% overlap - Hann
% tobError('do', [1], 'mask', {2, 3, 2, 6, 2, 4, 1});
% tobError('do', [4], 'mask', {2, 3, 2, 6, 2, 4, 0});
% 125ms - 66% overlap - Hann
tobError('do', [1], 'mask', {2, 3, 1, 6, 2, 4, 1});
tobError('do', [4], 'mask', {2, 3, 1, 6, 2, 4, 0});
