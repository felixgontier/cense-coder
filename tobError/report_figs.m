clear all, close all, clc;

%% Reference length
% load('report/figures/tobErr_n_rlen_f.mat');
% % load('report/figures/tobErr_s_rlen.mat');
% % load('report/figures/tobErr_u_rlen.mat');
% 
% for ind_rlen = 1:length(data.rawData)
%     errMean(:, ind_rlen) = data.rawData{ind_rlen}.errMean;
%     errStd(:, ind_rlen) = data.rawData{ind_rlen}.errStd;
% end
% 
% tob_f  = 10^3 * (2 .^ ([-17:11]/3));
% 
% figure(1), clf, errorbar(tob_f(2:end), errMean(2:end, 1), errStd(2:end, 1), '-x'), hold on,
% for ind_rlen = 2:size(errMean, 2)
%     errorbar(tob_f(2:end), errMean(2:end, ind_rlen), errStd(2:end, ind_rlen), '-x')
% end
% set(gca, 'xscale', 'log');
% grid on, legend('0.125~s', '0.25~s', '0.5~s', '1~s', '1.5~s', '2~s', '2.5~s', '3~s', '3.5~s', '4~s')%, axis([3.5 8.5 0 5.5])
% xlabel('Frequency'), ylabel('Measurement error (dB)')

%% Window type
% load('report/figures/tobErr_n_win.mat');
% % load('report/figures/tobErr_s_win.mat');
% % load('report/figures/tobErr_u_win.mat');
% 
% for ind_rlen = 1:length(data.rawData)
%     errMean(:, ind_rlen) = data.rawData{ind_rlen}.errMean;
%     errStd(:, ind_rlen) = data.rawData{ind_rlen}.errStd;
% end
% 
% tob_f  = 10^3 * (2 .^ ([-17:11]/3));
% 
% figure(1), clf, errorbar(tob_f(2:end), errMean(2:end, 1), errStd(2:end, 1), '-x'), hold on,
% for ind_rlen = 2:size(errMean, 2)
%     errorbar(tob_f(2:end), errMean(2:end, ind_rlen), errStd(2:end, ind_rlen), '-x')
% end
% set(gca, 'xscale', 'log');
% grid on, legend('hamming', 'hanning', 'blackmanharris', 'bartlett', 'bartletthann', 'gaussian', 'kaiser', 'tukey01', 'tukey02', 'tukey03', 'tukey04', 'tukey05', 'tukey06', 'tukey07', 'tukey08', 'tukey09', 'rect')%, axis([3.5 8.5 0 5.5])
% xlabel('Frequency'), ylabel('Measurement error (dB)')


%% Window type - Noise - Slow
% load('report/figures/tobErr_n_win_s.mat');
% % load('report/figures/tobErr_s_win.mat');
% % load('report/figures/tobErr_u_win.mat');
% % win_mask = [1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17];
% win_mask = [7 8 9 10 11 12 17];
% wintype = {'hamming', 'hanning', 'blackmanharris', 'bartlett', 'bartletthann', 'gaussian', 'kaiser', 'tukey01', 'tukey02', 'tukey03', 'tukey04', 'tukey05', 'tukey06', 'tukey07', 'tukey08', 'tukey09', 'rect'};
% for ind_rlen = 1:length(data.rawData)
%     errMean(:, ind_rlen) = data.rawData{ind_rlen}.errMean;
%     errStd(:, ind_rlen) = data.rawData{ind_rlen}.errStd;
% end
% 
% tob_f  = 10^3 * (2 .^ ([-17:11]/3));
% 
% figure(1), clf, %errorbar(tob_f(2:end), errMean(2:end, 1), errStd(2:end, 1), '-x'), 
% for ind_rlen = win_mask%2:size(errMean, 2)
%     errorbar(tob_f(2:end), errMean(2:end, ind_rlen), errStd(2:end, ind_rlen), '-x'), hold on,
% end
% set(gca, 'xscale', 'log');
% grid on, legend(wintype([win_mask]))%, axis([3.5 8.5 0 5.5])
% xlabel('Frequency'), ylabel('Measurement error (dB)')

%% Reference length - Noise - Slow
% load('report/figures/tobErr_n_rlen_s.mat');
% % load('report/figures/tobErr_s_rlen_s.mat');
% % load('report/figures/tobErr_u_rlen.mat');
% 
% for ind_rlen = 1:length(data.rawData)
%     errMean(:, ind_rlen) = data.rawData{ind_rlen}.errMean;
%     errStd(:, ind_rlen) = data.rawData{ind_rlen}.errStd;
% end
% 
% tob_f  = 10^3 * (2 .^ ([-17:11]/3));
% 
% figure(1), clf, errorbar(tob_f(2:end), errMean(2:end, 1), errStd(2:end, 1), '-x'), hold on,
% for ind_rlen = 2:size(errMean, 2)
%     errorbar(tob_f(2:end), errMean(2:end, ind_rlen), errStd(2:end, ind_rlen), '-x')
% end
% set(gca, 'xscale', 'log');
% grid on, legend('0.125~s', '0.25~s', '0.5~s', '1~s', '1.5~s', '2~s', '2.5~s', '3~s', '3.5~s', '4~s')%, axis([3.5 8.5 0 5.5])
% xlabel('Frequency'), ylabel('Measurement error (dB)')

%% Window type - Speech - Slow
% % load('report/figures/tobErr_n_win_s.mat');
% load('report/figures/tobErr_s_win_s.mat');
% % load('report/figures/tobErr_u_win.mat');
% % win_mask = [1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17];
% win_mask = [7 8 9 10 11 12 17];
% wintype = {'hamming', 'hanning', 'blackmanharris', 'bartlett', 'bartletthann', 'gaussian', 'kaiser', 'tukey01', 'tukey02', 'tukey03', 'tukey04', 'tukey05', 'tukey06', 'tukey07', 'tukey08', 'tukey09', 'rect'};
% for ind_rlen = 1:length(data.rawData)
%     errMean(:, ind_rlen) = data.rawData{ind_rlen}.errMean;
%     errStd(:, ind_rlen) = data.rawData{ind_rlen}.errStd;
% end
% 
% tob_f  = 10^3 * (2 .^ ([-17:11]/3));
% 
% figure(1), clf, %errorbar(tob_f(2:end), errMean(2:end, 1), errStd(2:end, 1), '-x'), 
% for ind_rlen = win_mask%2:size(errMean, 2)
%     errorbar(tob_f(2:end), errMean(2:end, ind_rlen), errStd(2:end, ind_rlen), '-x'), hold on,
% end
% set(gca, 'xscale', 'log');
% grid on, legend(wintype([win_mask]))%, axis([3.5 8.5 0 5.5])
% xlabel('Frequency'), ylabel('Measurement error (dB)')


%% Reference length - Speech - Slow
% % load('report/figures/tobErr_n_rlen.mat');
% load('report/figures/tobErr_s_rlen_s.mat');
% % load('report/figures/tobErr_u_rlen.mat');
% 
% for ind_rlen = 1:length(data.rawData)
%     errMean(:, ind_rlen) = data.rawData{ind_rlen}.errMean;
%     errStd(:, ind_rlen) = data.rawData{ind_rlen}.errStd;
% end
% 
% tob_f  = 10^3 * (2 .^ ([-17:11]/3));
% 
% figure(1), clf, errorbar(tob_f(2:end), errMean(2:end, 1), errStd(2:end, 1), '-x'), hold on,
% for ind_rlen = 2:size(errMean, 2)
%     errorbar(tob_f(2:end), errMean(2:end, ind_rlen), errStd(2:end, ind_rlen), '-x')
% end
% set(gca, 'xscale', 'log');
% grid on, legend('0.125~s', '0.25~s', '0.5~s', '1~s', '1.5~s', '2~s', '2.5~s', '3~s', '3.5~s', '4~s')%, axis([3.5 8.5 0 5.5])
% xlabel('Frequency'), ylabel('Measurement error (dB)')
% 

%% Window type - UrbanSound8k - Slow
% % load('report/figures/tobErr_n_win_s.mat');
% % load('report/figures/tobErr_s_win_s.mat');
% load('report/figures/tobErr_u_win_s.mat');
% win_mask = [1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17];
% % win_mask = [7 8 9 10 11 12 17];
% wintype = {'hamming', 'hanning', 'blackmanharris', 'bartlett', 'bartletthann', 'gaussian', 'kaiser', 'tukey01', 'tukey02', 'tukey03', 'tukey04', 'tukey05', 'tukey06', 'tukey07', 'tukey08', 'tukey09', 'rect'};
% for ind_rlen = 1:length(data.rawData)
%     errMean(:, ind_rlen) = data.rawData{ind_rlen}.errMean;
%     errStd(:, ind_rlen) = data.rawData{ind_rlen}.errStd;
% end
% 
% tob_f  = 10^3 * (2 .^ ([-17:11]/3));
% 
% figure(1), clf, %errorbar(tob_f(2:end), errMean(2:end, 1), errStd(2:end, 1), '-x'), 
% for ind_rlen = win_mask%2:size(errMean, 2)
%     errorbar(tob_f(2:end), errMean(2:end, ind_rlen), errStd(2:end, ind_rlen), '-x'), hold on,
% end
% set(gca, 'xscale', 'log');
% grid on, legend(wintype([win_mask]))%, axis([3.5 8.5 0 5.5])
% xlabel('Frequency'), ylabel('Measurement error (dB)')

%% Window type - Noise - Fast
% load('report/figures/tobErr_n_win_f.mat');
% % load('report/figures/tobErr_s_win_f.mat');
% % load('report/figures/tobErr_u_win_f.mat');
% % win_mask = [1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17];
% win_mask = [12];
% wintype = {'hamming', 'hanning', 'blackmanharris', 'bartlett', 'bartletthann', 'gaussian', 'kaiser', 'tukey01', 'tukey02', 'tukey03', 'tukey04', 'tukey05', 'tukey06', 'tukey07', 'tukey08', 'tukey09', 'rect'};
% for ind_rlen = 1:length(data.rawData)
%     errMean(:, ind_rlen) = data.rawData{ind_rlen}.errMean;
%     errStd(:, ind_rlen) = data.rawData{ind_rlen}.errStd;
% end
% 
% tob_f  = 10^3 * (2 .^ ([-17:11]/3));
% 
% figure(1), clf, %errorbar(tob_f(2:end), errMean(2:end, 1), errStd(2:end, 1), '-x'), 
% for ind_rlen = win_mask%2:size(errMean, 2)
%     errorbar(tob_f(2:end), errMean(2:end, ind_rlen), errStd(2:end, ind_rlen), '-x'), hold on,
% end
% set(gca, 'xscale', 'log');
% grid on, legend(wintype([win_mask])), axis([1e1 5e4 -6 8])
% xlabel('Frequency'), ylabel('Measurement error (dB)')

%% Window type - Speech - Fast
% % load('report/figures/tobErr_n_win_f.mat');
% load('report/figures/tobErr_s_win_f.mat');
% % load('report/figures/tobErr_u_win_f.mat');
% % win_mask = [1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17];
% win_mask = [12];
% wintype = {'hamming', 'hanning', 'blackmanharris', 'bartlett', 'bartletthann', 'gaussian', 'kaiser', 'tukey01', 'tukey02', 'tukey03', 'tukey04', 'tukey05', 'tukey06', 'tukey07', 'tukey08', 'tukey09', 'rect'};
% for ind_rlen = 1:length(data.rawData)
%     errMean(:, ind_rlen) = data.rawData{ind_rlen}.errMean;
%     errStd(:, ind_rlen) = data.rawData{ind_rlen}.errStd;
% end
% 
% tob_f  = 10^3 * (2 .^ ([-17:11]/3));
% 
% figure(2), clf, %errorbar(tob_f(2:end), errMean(2:end, 1), errStd(2:end, 1), '-x'), 
% for ind_rlen = win_mask%2:size(errMean, 2)
%     errorbar(tob_f(2:end), errMean(2:end, ind_rlen), errStd(2:end, ind_rlen), '-x'), hold on,
% end
% set(gca, 'xscale', 'log');
% grid on, legend(wintype([win_mask])), axis([1e1 5e4 -6 8])
% xlabel('Frequency'), ylabel('Measurement error (dB)')

%% Window type - UrbanSound8k - Fast
% % load('report/figures/tobErr_n_win_f.mat');
% % load('report/figures/tobErr_s_win_f.mat');
% load('report/figures/tobErr_u_win_f.mat');
% % win_mask = [1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17];
% win_mask = [12];
% wintype = {'hamming', 'hanning', 'blackmanharris', 'bartlett', 'bartletthann', 'gaussian', 'kaiser', 'tukey01', 'tukey02', 'tukey03', 'tukey04', 'tukey05', 'tukey06', 'tukey07', 'tukey08', 'tukey09', 'rect'};
% for ind_rlen = 1:length(data.rawData)
%     errMean(:, ind_rlen) = data.rawData{ind_rlen}.errMean;
%     errStd(:, ind_rlen) = data.rawData{ind_rlen}.errStd;
% end
% 
% tob_f  = 10^3 * (2 .^ ([-17:11]/3));
% 
% figure(3), clf, %errorbar(tob_f(2:end), errMean(2:end, 1), errStd(2:end, 1), '-x'), 
% for ind_rlen = win_mask%2:size(errMean, 2)
%     errorbar(tob_f(2:end), errMean(2:end, ind_rlen), errStd(2:end, ind_rlen), '-x'), hold on,
% end
% set(gca, 'xscale', 'log');
% grid on, legend(wintype([win_mask])), axis([1e1 5e4 -6 8])
% xlabel('Frequency'), ylabel('Measurement error (dB)')


%% Test
% % load('report/figures/tobErr_n_win_f.mat');
% % load('report/figures/tobErr_s_win_f.mat');
% load('report/figures/tobErr_test.mat');
% % win_mask = [1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17];
% win_mask = [1];
% wintype = {'hamming', 'hanning', 'blackmanharris', 'bartlett', 'bartletthann', 'gaussian', 'kaiser', 'tukey01', 'tukey02', 'tukey03', 'tukey04', 'tukey05', 'tukey06', 'tukey07', 'tukey08', 'tukey09', 'rect'};
% for ind_rlen = 1:length(data.rawData)
%     errMean(:, ind_rlen) = data.rawData{ind_rlen}.errMean;
%     errStd(:, ind_rlen) = data.rawData{ind_rlen}.errStd;
%     errMeanAbs(:, ind_rlen) = data.rawData{ind_rlen}.errMeanAbs;
%     errStdAbs(:, ind_rlen) = data.rawData{ind_rlen}.errStdAbs;
% end
% 
% tob_f  = 10^3 * (2 .^ ([-17:11]/3));
% 
% figure(3), clf, %errorbar(tob_f(2:end), errMean(2:end, 1), errStd(2:end, 1), '-x'), 
% for ind_rlen = win_mask%2:size(errMean, 2)
%     errorbar(tob_f, errMean(:, ind_rlen), errStd(:, ind_rlen), '-x'), hold on,
%     semilogx(tob_f, data.rawData{ind_rlen}.errMin(:), '-bx'),
%     semilogx(tob_f, data.rawData{ind_rlen}.errMax(:), '-rx'),
%     errorbar(tob_f, errMeanAbs(:, ind_rlen), errStdAbs(:, ind_rlen), '-x')
% end
% set(gca, 'xscale', 'log');
% grid on, legend(wintype([win_mask]))%, axis([1e1 5e4 -6 8])
% xlabel('Frequency'), ylabel('Measurement error (dB)')

%% Weights
% sr = 32000;
% N = 2^(ceil(log2(4000)));
% N_filt = 2^20; % Design with a much higher precision
% G = third_octave_filterbank(sr, N_filt, -17:11, 3);
% G1 = G.^2;
% G_mean(:, 1) = mean(G1(:, 1:1+round(N_filt/(2*N))), 2);
% G_mean(:, N/2+1) = mean(G1(:, 1+(N/2)*round(N_filt/N)-round(N_filt/(2*N)):end), 2);
% for ind_f = 2:N/2
%     G_mean(:, ind_f) = mean(G1(:, 1+(ind_f-1)*round(N_filt/N)-round(N_filt/(2*N)):1+(ind_f-1)*round(N_filt/N)+round(N_filt/(2*N))), 2);
% end
% H_st = G_mean;
% 
% % for ind_b = 1:size(G, 1)
% %     G_temp(ind_b, :) = decimate(G(ind_b, :), round(N_filt/N));
% % end
% % G = G_temp;
% % H_st = (G/G(end, end)).^2;
% % 
% G2 = G(:, 1:round(N_filt/N):end); % Only take the resolution needed
% H_st2 = G2.^2;
% H_all = G.^2;
% tob_f  = 10^3 * (2 .^ ([-17:11]/3));
% figure(2), clf, semilogx(0:sr/N:sr/2, H_st(:, :), '-b'), hold on, 
% % semilogx(0:sr/N:sr/2, H_st2(:, :), '-g'), hold on, 
% % semilogx(0:sr/N_filt:sr/2, H_all(:, :), '-r'), hold on, 
% semilogx(tob_f, ones(size(tob_f)), 'x'),
% grid on, axis([1e1 5e4 0 1.1])
% % figure(2), clf, semilogx(0:sr/N:sr/2, H_st'), hold on, 
% % semilogx(tob_f, ones(size(tob_f)), 'x'),
% % grid on, axis([1e1 5e4 0 1.1])
% % figure(4), clf, semilogx(0:sr/N:sr/2, sum(H_st)), hold on, 
% % semilogx(tob_f, ones(size(tob_f)), 'x'),
% % grid on, axis([1e1 5e4 0 1.1])

%%
% clear all, close all, clc;
% load('report/tables/tobErr_noise.mat');
% tob_f  = 10^3 * (2 .^ ([-17:11]/3));
% figure(1), clf, 
% % errorbar(tob_f, data.rawData{1}.errMeanAbs, data.rawData{1}.errStdAbs, '-x'), 
% errorbar(tob_f(3:3:end), data.rawData{2}.errMeanAbs(3:3:end), data.rawData{2}.errStdAbs(3:3:end), '-x'), hold on,
% errorbar(tob_f(3:3:end), data.rawData{3}.errMeanAbs(3:3:end), data.rawData{3}.errStdAbs(3:3:end), '-x'), 
% % errorbar(tob_f, data.rawData{4}.errMeanAbs, data.rawData{4}.errStdAbs, '-x'), 
% set(gca, 'xscale', 'log');
% % legend('fast, 50\% overlap', 'fast, no overlap', 'slow, 50\% overlap', 'slow, no overlap');
% % legend('fast, no overlap', 'slow, 50\% overlap', 'slow, no overlap');
% grid on, xlabel('Frequency (Hz)'), ylabel('Absolute error (dB)');
% axis([1e1 2e4 0 2]);
% 
% load('report/tables/tobErr_noise_rect.mat');
% tob_f  = 10^3 * (2 .^ ([-17:11]/3));
% % figure(3), clf,
% % errorbar(tob_f, data.rawData{1}.errMeanAbs, data.rawData{1}.errStdAbs, '-x'), 
% errorbar(tob_f(3:3:end), data.rawData{2}.errMeanAbs(3:3:end), data.rawData{2}.errStdAbs(3:3:end), '-x'), hold on,
% errorbar(tob_f(3:3:end), data.rawData{3}.errMeanAbs(3:3:end), data.rawData{3}.errStdAbs(3:3:end), '-x'), 
% % errorbar(tob_f, data.rawData{4}.errMeanAbs, data.rawData{4}.errStdAbs, '-x'), 
% set(gca, 'xscale', 'log');
% legend('Hamming window, fast, no overlap', 'Hamming window, slow, 50\% overlap', 'Rectangular window, fast, no overlap', 'Rectangular window, slow, 50\% overlap');
% grid on, xlabel('Frequency (Hz)'), ylabel('Absolute error (dB)');
% axis([1e1 2e4 0 1.5]);

load('report/tables/tobErr_us8k.mat');
tob_f  = 10^3 * (2 .^ ([-17:11]/3));
figure(2), clf,
% errorbar(tob_f, data.rawData{1}.errMeanAbs, data.rawData{1}.errStdAbs, '-x'), 
errorbar(tob_f(3:3:end), data.rawData{2}.errMeanAbs(3:3:end), data.rawData{2}.errStdAbs(3:3:end), '-x'), hold on,
errorbar(tob_f(3:3:end), data.rawData{3}.errMeanAbs(3:3:end), data.rawData{3}.errStdAbs(3:3:end), '-x'), 
% errorbar(tob_f, data.rawData{4}.errMeanAbs, data.rawData{4}.errStdAbs, '-x'), 
set(gca, 'xscale', 'log');
% legend('fast, no overlap', 'slow, 50\% overlap', 'slow, no overlap');
grid on, xlabel('Frequency (Hz)'), ylabel('Absolute error (dB)');
axis([1e1 2e4 -2 12]);



load('report/tables/tobErr_us8k_rect.mat');
tob_f  = 10^3 * (2 .^ ([-17:11]/3));
% figure(4), clf,
% errorbar(tob_f, data.rawData{1}.errMeanAbs, data.rawData{1}.errStdAbs, '-x'), 
errorbar(tob_f(3:3:end), data.rawData{2}.errMeanAbs(3:3:end), data.rawData{2}.errStdAbs(3:3:end), '-x'), hold on,
errorbar(tob_f(3:3:end), data.rawData{3}.errMeanAbs(3:3:end), data.rawData{3}.errStdAbs(3:3:end), '-x'), 
% errorbar(tob_f, data.rawData{4}.errMeanAbs, data.rawData{4}.errStdAbs, '-x'), 
set(gca, 'xscale', 'log');
legend('Hamming window, fast, no overlap', 'Hamming window, slow, 50\% overlap', 'Rectangular window, fast, no overlap', 'Rectangular window, slow, 50\% overlap');
grid on, xlabel('Frequency (Hz)'), ylabel('Absolute error (dB)');
axis([1e1 2e4 0 8.5]);

load('report/tables/tobErr_us8k_hann_cen_f.mat');
figure(2), clf,
errorbar(tob_f(3:3:end), data.rawData{1}.errMean(3:3:end), data.rawData{1}.errStd(3:3:end), '-x'), hold on, 
load('report/tables/tobErr_us8k_hann_cen_s.mat');
errorbar(tob_f(3:3:end), data.rawData{1}.errMean(3:3:end), data.rawData{1}.errStd(3:3:end), '-x'), hold on, 
load('report/tables/tobErr_us8k_rect_cen_f.mat');
errorbar(tob_f(3:3:end), data.rawData{1}.errMean(3:3:end), data.rawData{1}.errStd(3:3:end), '-x'), hold on, 
load('report/tables/tobErr_us8k_rect_cen_s.mat');
errorbar(tob_f(3:3:end), data.rawData{1}.errMean(3:3:end), data.rawData{1}.errStd(3:3:end), '-x'), hold on, 
legend('Hamming window, fast, no overlap', 'Hamming window, slow, 50\% overlap', 'Rectangular window, fast, no overlap', 'Rectangular window, slow, 50\% overlap');
set(gca, 'xscale', 'log'), axis([1e1 2e4 -4 8]), grid on;
xlabel('Frequency (Hz)'), ylabel('Error (dB)');

%% Noise
% clear all
% load n_f;
% load n_s;
% 
% tob_f  = 10^3 * (2 .^ ([-17:11]/3));
% figure(1), clf,
% 
% errorbar(tob_f(3:3:end), m_n_f-0.03, s_n_f), hold on, 
% errorbar(tob_f(3:3:end), m_n_s-0.03, s_n_s)
% grid on, xlabel('Frequency (Hz)'), ylabel('Analysis error (dB)');
% set(gca, 'xscale', 'log');
% axis([1e1 2e4 -0.6 1]);
% legend('Fast analysis (125~ms)', 'Slow analysis (1~s)')