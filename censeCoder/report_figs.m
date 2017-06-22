clear all, close all, clc;

real_fps = {'2', '4.1', '6.1', '7.7', '9.5', '21', '85'};
fps_lgd = cell(1, length(real_fps));
for ind_lgd = 1:length(real_fps)
    fps_lgd{ind_lgd} = ['fps: ' real_fps{ind_lgd}];
end

%% Bitrate
% fig = openfig('report/figures/bitrate_fps_mel_8.fig');
% figure(fig);
% ax = gca;
% ax.XTickLabels = real_fps;
% xlabel('Frames per second'), ylabel('Output bitrate (kbit/s)'), grid on;
% for ind_ylbl = 1:length(ax.YTickLabels)
%     ax.YTickLabels{ind_ylbl} = num2str(str2double(ax.YTickLabels{ind_ylbl})/1000);
% end
% legend('Location', 'northwest');
% print(fig, '-dpdf', 'report/figures/processed/bitrate_fps_mel.pdf');
% close all;

%% KNN accuracy
% fig = openfig('report/figures/knn_fps_mel_8.fig');
% figure(fig);
% ax = gca;
% ax.XTickLabels = real_fps;
% xlabel('Frames per second'), ylabel('KNN-5 accuracy'), grid on;
% load('report/tables/knn_base.mat');
% hold on, errorbar(7.15, data.meanData, data.stdData, 'LineWidth', 2, 'color', 'black', 'marker', 'x')
% legend({'mel: 10', 'mel: 20', 'mel: 30', 'mel: 40', 'baseline'}, 'Location', 'southeast');
% print(fig, '-dpdf', 'report/figures/processed/knn_fps_mel.pdf');
% close all;

%% CSII
% fig = openfig('report/figures/csii_fps_mel_8.fig');
% figure(fig);
% xlabel('Mel bands'), ylabel('CSII indicator'), grid on;
%load('report/tables/csii_base.mat');
%hold on, plot(4, data.meanData, 'LineWidth', 2, 'color', 'black', 'marker', 'x')
%legend([fps_lgd {'baseline'}], 'Location', 'northwest');
%axis([0.5 4.5 0.3 0.65]);
% print(fig, '-dpdf', 'report/figures/processed/csii_fps_mel.pdf');
% close all;

%% Error
% load('report/figures/tob_error.mat');
% data_tob = data;
% load('report/figures/mel_error_mel40_avg0_qall.mat');
% data_mel = data;
% clear data;
% 
% figure(1), clf, errorbar(3.98:7.98, data_tob.meanData, data_tob.stdData, '-x')
% hold on,
% errorbar(4.02:8.02, data_mel.meanData, data_mel.stdData, '-x')
% grid on, legend('Third-octave bands', 'Mel bands'), axis([3.5 8.5 0 5.5])
% xlabel('Word size (bits)'), ylabel('Measurement error (dB)')

%% Bitrate_q
% load('report/figures/tob_bitrate.mat');
% data_tob = data;
% load('report/figures/mel_bitrate_mel40_avg8_qall.mat');
% data_mel40 = data;
% load('report/figures/mel_bitrate_mel30_avg8_qall.mat');
% data_mel30 = data;
% 
% clear data;
% 
% figure(1), clf, errorbar(3.96:7.96, data_tob.meanData, data_tob.stdData, '-x')
% hold on,
% errorbar(4:8, data_mel30.meanData, data_mel30.stdData, '-x'),
% errorbar(4.04:8.04, data_mel40.meanData, data_mel40.stdData, '-x'),
% grid on, legend('Third-octave bands', 'Mel bands (30)', 'Mel bands (40)', 'Location', 'Northwest')
% xlabel('Word size (bits)'), ylabel('Output bitrate (bits/s)')

%% Bitrate_mel_avg
% load('report/figures/mel_bitrate_melall_avgall_q8.mat');
% 
% fps_axis = [2, 4.1, 6.1, 7.7, 9.5, 21, 85];
% data.meanData = data.meanData;
% figure(1), clf, 
% errorbar(fps_axis(1:5), data.meanData(1, 1:5), data.stdData(1, 1:5))
% hold on,
% errorbar(fps_axis(1:5), data.meanData(2, 1:5), data.stdData(2, 1:5))
% errorbar(fps_axis(1:5), data.meanData(3, 1:5), data.stdData(3, 1:5))
% errorbar(fps_axis(1:5), data.meanData(4, 1:5), data.stdData(4, 1:5))
% % errorbar(fps_axis, data.meanData(1, :), data.stdData(1, :))
% % hold on,
% % errorbar(fps_axis, data.meanData(2, :), data.stdData(2, :))
% % errorbar(fps_axis, data.meanData(3, :), data.stdData(3, :))
% % errorbar(fps_axis, data.meanData(4, :), data.stdData(4, :))
% grid on, legend('Mel bands (10)', 'Mel bands (20)', 'Mel bands (30)', 'Mel bands (40)', 'Location', 'Northwest')
% xlabel('Transmitted frame rate (frames/s)'), ylabel('Output bitrate (bits/s)')
% 

%% Intel
% load('report/figures/mel_csii_melall_avgall_q8.mat');
% data_csii = data;
% load('report/figures/mel_fwSNRseg_melall_avgall_q8.mat');
% data_fwSNRseg = data;
% clear data;
% 
% figure(1), clf
% errorbar(7:10:37, data_csii.meanData(1, :), data_csii.stdData(1, :))
% hold on,
% errorbar(8:10:38, data_csii.meanData(2, :), data_csii.stdData(2, :))
% errorbar(9:10:39, data_csii.meanData(3, :), data_csii.stdData(3, :))
% errorbar(10:10:40, data_csii.meanData(4, :), data_csii.stdData(4, :))
% errorbar(11:10:41, data_csii.meanData(5, :), data_csii.stdData(5, :))
% errorbar(12:10:42, data_csii.meanData(6, :), data_csii.stdData(6, :))
% errorbar(13:10:43, data_csii.meanData(7, :), data_csii.stdData(7, :))
% axis([-10 45 -0.7 -0.1]), grid on, legend(fps_lgd, 'location', 'northwest'), xlabel('Mel bands'); ylabel('CSII')

% load('report/figures/mel_fwSNRseg_melall_avgall_q8.mat');
% data_fwSNRseg = data;
% clear data;
% figure(1), clf
% 
% errorbar(10:10:40, data_fwSNRseg.meanData(1, :), data_fwSNRseg.stdData(1, :))
% hold on,
% errorbar(10:10:40, data_fwSNRseg.meanData(2, :), data_fwSNRseg.stdData(2, :))
% errorbar(10:10:40, data_fwSNRseg.meanData(3, :), data_fwSNRseg.stdData(3, :))
% errorbar(10:10:40, data_fwSNRseg.meanData(4, :), data_fwSNRseg.stdData(4, :))
% errorbar(10:10:40, data_fwSNRseg.meanData(5, :), data_fwSNRseg.stdData(5, :))
% errorbar(10:10:40, data_fwSNRseg.meanData(6, :), data_fwSNRseg.stdData(6, :))
% errorbar(10:10:40, data_fwSNRseg.meanData(7, :), data_fwSNRseg.stdData(7, :))
% axis([-10 45 -15 5]), grid on, legend(fps_lgd, 'location', 'northwest'), xlabel('Mel bands'); ylabel('fwSNRseg (dB)')

%% Mel_class_q
load('report/figures/mel_class_mel40_avg0_qall.mat');
data_qall = data;
load('report/figures/mel_class_mel40_avg0_q0.mat');
figure(1), clf

errorbar([3.94:7.94], [data_qall.meanData(1, :)], [data_qall.stdData(1, :)], '-x', 'Color', [0 0.4470 0.7410])
hold on,
errorbar([3.98:7.98], [data_qall.meanData(2, :)], [data_qall.stdData(2, :)], '-x', 'Color', [0.8500 0.3250 0.0980])
errorbar([4.02:8.02], [data_qall.meanData(3, :)], [data_qall.stdData(3, :)], '-x', 'Color', [0.9290 0.6940 0.1250])
errorbar([4.06:8.06], [data_qall.meanData(4, :)], [data_qall.stdData(4, :)], '-x', 'Color', [0.4940 0.1840 0.5560])
errorbar([8.44 8.94], [NaN data.meanData(1)], [NaN data.stdData(1)], 'x', 'Linewidth', 1.5, 'Color', [0 0.4470 0.7410])
errorbar([8.44 8.98], [NaN data.meanData(2)], [NaN data.stdData(2)], 'x', 'Linewidth', 1.5, 'Color', [0.8500 0.3250 0.0980])
errorbar([8.48 9.02], [NaN data.meanData(3)], [NaN data.stdData(3)], 'x', 'Linewidth', 1.5, 'Color', [0.9290 0.6940 0.1250])
errorbar([8.52 9.06], [NaN data.meanData(4)], [NaN data.stdData(4)], 'x', 'Linewidth', 1.5, 'Color', [0.4940 0.1840 0.5560])
axis([3 9.5 0.4 0.8]), grid on, xlabel('Word size (bits)'); ylabel('Classification accuracy'); legend('SVM', 'RF', 'DT', 'KNN', 'location', 'northwest', 'orientation', 'horizontal');
set(gca, 'xticklabels', {'3','4','5','6','7','8','No quant.'})
%% Tob_class_q
% load('report/figures/tob_class.mat');
% data_tob = data;
% 
% hold on,
% errorbar([3.94:7.94], data_tob.meanData(1, 1:end-1) , data_tob.stdData(1, 1:end-1))
% errorbar([3.98:7.98], data_tob.meanData(2, 1:end-1) , data_tob.stdData(2, 1:end-1))
% errorbar([4.02:8.02], data_tob.meanData(3, 1:end-1) , data_tob.stdData(3, 1:end-1))
% errorbar([4.06:8.06], data_tob.meanData(4, 1:end-1) , data_tob.stdData(4, 1:end-1))
% axis([3.5 8.5 0.35 0.75]), grid on, xlabel('Word size (bits)'); ylabel('Classification accuracy'); legend('SVM', 'RF', 'DT', 'KNN', 'location', 'northwest', 'orientation', 'horizontal');


