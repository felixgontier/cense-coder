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
                                                                               
data_cen = expLoad(config, [], 1);

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
                X_tob_cen(:, ind_ref) = mean(data_cen.X_tob_cen{ind_wav}(:, (ind_ref-1)*n_avg+1:min(ind_ref*n_avg, end))/4096, 2);
                X_tob_cen(X_tob_cen == 0) = eps;
            end
            err_cen_ref = [err_cen_ref 10*log10(X_tob_cen)-10*log10(data.X_tob_ref{ind_wav}(:, 1:n_ref))];
%             r_level = [r_level max(10*log10(data.X_tob_ref{ind_wav}(:, 1:n_ref)))-10*log10(data.X_tob_ref{ind_wav}(18, 1:n_ref))];
        end
    else
        X_tob_cen = [];
        if strcmp(setting.dataset, 'noise'); n_ref = 1; else n_ref = size(data.X_tob_ref{ind_wav}, 2)-1; end
        if n_ref > 0
            for ind_ref = 1:n_ref
                n_avg = round(setting.reflen*2-1);
                
                X_tob_cen(:, ind_ref) = mean(data_cen.X_tob_cen{ind_wav}(:, (ind_ref-1)*(n_avg+1)+1:min((ind_ref-1)*(n_avg+1)+n_avg, end))/32768, 2);
                X_tob_cen(X_tob_cen == 0) = eps;
            end
            err_cen_ref = [err_cen_ref 10*log10(X_tob_cen)-10*log10(data.X_tob_ref{ind_wav}(:, 1:n_ref))];
%             r_level = [r_level max(10*log10(data.X_tob_ref{ind_wav}(:, 1:n_ref)))-10*log10(data.X_tob_ref{ind_wav}(18, 1:n_ref))];
        end
    end
end

% figure, clf,
% [r_level, I] = sort(r_level);
% plot(r_level, abs(err_cen_ref(18,I)))

obs.errMean = mean(err_cen_ref, 2);
obs.errStd = std(err_cen_ref, 0, 2);
obs.errMax = max(err_cen_ref, [], 2);
obs.errMin = min(err_cen_ref, [], 2);
obs.errMeanAbs = mean(abs(err_cen_ref), 2);
obs.errStdAbs = std(abs(err_cen_ref), 0, 2);
