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
fig = openfig('report/figures/csii_fps_mel_8.fig');
figure(fig);
xlabel('Mel bands'), ylabel('CSII indicator'), grid on;
%load('report/tables/csii_base.mat');
%hold on, plot(4, data.meanData, 'LineWidth', 2, 'color', 'black', 'marker', 'x')
%legend([fps_lgd {'baseline'}], 'Location', 'northwest');
%axis([0.5 4.5 0.3 0.65]);
% print(fig, '-dpdf', 'report/figures/processed/csii_fps_mel.pdf');
% close all;



