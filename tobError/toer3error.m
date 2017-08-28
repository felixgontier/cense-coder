function [config, store, obs] = toer3error(config, setting, data)              
% toer3error ERROR step of the expLanes experiment tobError                    
%    [config, store, obs] = toer3error(config, setting, data)                  
%      - config : expLanes configuration state                                 
%      - setting   : set of factors to be evaluated                            
%      - data   : processing data stored during the previous step              
%      -- store  : processing data to be saved for the other steps             
%      -- obs    : observations to be saved for analysis                       
                                                                               
% Copyright: felix                                                             
% Date: 12-Jul-2017                                                            
                                                                               
% Set behavior for debug mode                                                  
if nargin==0, tobError('do', 3, 'mask', {}); return; else store=[]; obs=[]; end
                                                                               
if strcmp(setting.centype, 'ita')&& strcmp(setting.wintype, 'hanning')&& ~strcmp(setting.dataset, 'noise') && setting.hopsize~=0.33
        l_frame = setting.framelen*32000;
        w = hann(l_frame, 'periodic');
end

data_cen = expLoad(config, [], 1);

load names;
wav_names = [];
assert(setting.reflen>=setting.framelen);
err_cen_ref = [];
r_level = [];
for ind_wav = 1:length(data.X_tob_ref)
    if setting.framelen == 0.125
        X_tob_cen = [];
        if strcmp(setting.dataset, 'noise'); n_ref = 1; else n_ref = size(data.X_tob_ref{ind_wav}, 2)-1; end
        if n_ref > 0
            for ind_ref = 1:n_ref
                n_avg = round(setting.reflen/setting.framelen);
                if strcmp(setting.centype, 'cense'); X_tob_cen(:, ind_ref) = mean(data_cen.X_tob_cen{ind_wav}(:, (ind_ref-1)*n_avg+1:min(ind_ref*n_avg, end))/4000, 2); 
%                 else X_tob_cen(:, ind_ref) = mean(data_cen.X_tob_cen{ind_wav}(:, (ind_ref-1)*n_avg+1:min(ind_ref*n_avg, end)), 2); end;
                else X_tob_cen(:, ind_ref) = 10*log10(mean(10.^(data_cen.X_tob_cen{ind_wav}(:, (ind_ref-1)*(n_avg+1)+1:min((ind_ref-1)*(n_avg+1)+n_avg, end))/10)/4000, 2)); end;
                if strcmp(setting.centype, 'ita')&& strcmp(setting.wintype, 'hanning')&& ~strcmp(setting.dataset, 'noise') && setting.hopsize~=0.33
                    X_tob_cen(:, ind_ref) = 10*log10(10.^(X_tob_cen(:, ind_ref)/10)/(l_frame/sum(w)).^2*l_frame/sum(w.^2));
                end
                X_tob_cen(X_tob_cen == 0) = eps;
            end
%                                     figure(1), clf, semilogx(10*log10(X_tob_cen)), hold on, semilogx(10*log10(data.X_tob_ref{ind_wav}(:, 1:n_ref))), grid on

            if ~isempty(X_tob_cen)
                wav_names = [wav_names wav_name2(ind_wav)];

                if strcmp(setting.centype, 'cense')
                    err_cen_ref = [err_cen_ref 10*log10(X_tob_cen)-data.X_tob_ref{ind_wav}(:, 1:n_ref)];
                else
                    err_cen_ref = [err_cen_ref X_tob_cen-data.X_tob_ref{ind_wav}(:, 1:n_ref)];
                end
%                 err_cen_ref = [err_cen_ref 10*log10(X_tob_cen)-10*log10(data.X_tob_ref{ind_wav}(:, 1:n_ref))];
                r_level = [r_level max(10*log10(data.X_tob_ref{ind_wav}(:, 1:n_ref)))-10*log10(data.X_tob_ref{ind_wav}(1, 1:n_ref))];
            end
        end
    else
        X_tob_cen = [];
        if strcmp(setting.dataset, 'noise'); n_ref = 1; else n_ref = size(data.X_tob_ref{ind_wav}, 2)-1; end
        if n_ref > 0
            for ind_ref = 1:n_ref
                n_avg = round(setting.reflen*2-1);
%                 X_tob_cen(:, ind_ref) = mean(data_cen.X_tob_cen{ind_wav}(:, (ind_ref-1)*(n_avg+1)+1:min((ind_ref-1)*(n_avg+1)+n_avg, end))/32768, 2); 
                if strcmp(setting.centype, 'cense'); X_tob_cen(:, ind_ref) = 10*log10(mean(data_cen.X_tob_cen{ind_wav}(:, (ind_ref-1)*(n_avg+1)+1:min((ind_ref-1)*(n_avg+1)+n_avg, end))/32000, 2)); 
                else X_tob_cen(:, ind_ref) = 10*log10(mean(10.^(data_cen.X_tob_cen{ind_wav}(:, (ind_ref-1)*(n_avg+1)+1:min((ind_ref-1)*(n_avg+1)+n_avg, end))/10)/32000, 2)); end;
                if strcmp(setting.centype, 'ita')&& strcmp(setting.wintype, 'hanning')&& ~strcmp(setting.dataset, 'noise') && setting.hopsize~=0.33
                    X_tob_cen(:, ind_ref) = 10*log10(10.^(X_tob_cen(:, ind_ref)/10)/(l_frame/sum(w)).^2*l_frame/sum(w.^2));
                end
                X_tob_cen(X_tob_cen == 0) = eps;
            end

            if ~isempty(X_tob_cen)
%                 if any(abs(10*log10(X_tob_cen)-10*log10(data.X_tob_ref{ind_wav}(:, 1:n_ref)))>15)
%                     figure(1), clf, semilogx(10*log10(X_tob_cen)), hold on, semilogx(10*log10(data.X_tob_ref{ind_wav}(:, 1:n_ref))), gid on;
%                 end
                wav_names = [wav_names wav_name2(ind_wav)];

                if strcmp(setting.centype, 'cense')
                    err_cen_ref = [err_cen_ref X_tob_cen-data.X_tob_ref{ind_wav}(:, 1:n_ref)];
                else
                    err_cen_ref = [err_cen_ref X_tob_cen-data.X_tob_ref{ind_wav}(:, 1:n_ref)];
                end
                r_level = [r_level max(10*log10(data.X_tob_ref{ind_wav}(:, 1:n_ref)))-data.X_tob_ref{ind_wav}(1, 1:n_ref)];
            end
        end
    end
end
% figure(2), clf, hist(err_cen_ref(1, :), 1000)


% figure, clf,
% [r_level, I] = sort(r_level);
% plot(r_level, abs(err_cen_ref(1,I)))

err_sup20 = zeros(1, size(err_cen_ref, 2));
err_cen_ref(isnan(err_cen_ref)|isinf(err_cen_ref)) = 0;
% for ind_band = 1:size(err_cen_ref, 1)
% %     err_cen_ref(:, find(abs(err_cen_ref(ind_band, :))>20)) = [];
%     err_sup20(find(abs(err_cen_ref(ind_band, :))>20)) = 1;
% 
% end
% names_err_sup20 = wav_names(1, err_sup20==1);
% class_cnt_err_sup20 = zeros(10, 1);
% for ind_wav = 1:length(names_err_sup20)
%     class_err_sup20(ind_wav) = str2num(names_err_sup20{ind_wav}(find(names_err_sup20{ind_wav}=='-', 1)+1));
%     class_cnt_err_sup20(class_err_sup20(ind_wav)+1) = class_cnt_err_sup20(class_err_sup20(ind_wav)+1)+1;
% end
% 
% class_cnt = zeros(10, 1);
% for ind_wav = 1:size(err_cen_ref, 2)-1
%     class(ind_wav) = str2num(wav_names{ind_wav}(find(wav_names{ind_wav}=='-', 1)+1));
%     class_cnt(class(ind_wav)+1) = class_cnt(class(ind_wav)+1)+1;
% end
% 
% r_class_err = class_cnt_err_sup20./class_cnt;
% obs.err = {err_cen_ref};


% save('err_ita.mat', 'err_cen_ref');
store.err = err_cen_ref;
obs.errMean = mean(err_cen_ref, 2);
obs.errStd = std(err_cen_ref, 0, 2);
obs.errMax = max(err_cen_ref, [], 2);
obs.errMin = min(err_cen_ref, [], 2);
% obs.errMeanAbs = mean(abs(err_cen_ref-repmat(obs.errMean, 1, size(err_cen_ref, 2))), 2);
% obs.errStdAbs = std(abs(err_cen_ref-repmat(obs.errMean, 1, size(err_cen_ref, 2))), 0, 2);
obs.errMeanAbs = mean(abs(err_cen_ref), 2);
obs.errStdAbs = std(abs(err_cen_ref), 0, 2);
% obs.class_cnt = class_cnt;
% obs.r_class_err = r_class_err;
