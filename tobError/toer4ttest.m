function [config, store, obs] = toer4ttest(config, setting, data)              
% toer4ttest TTEST step of the expLanes experiment tobError                    
%    [config, store, obs] = toer4ttest(config, setting, data)                  
%      - config : expLanes configuration state                                 
%      - setting   : set of factors to be evaluated                            
%      - data   : processing data stored during the previous step              
%      -- store  : processing data to be saved for the other steps             
%      -- obs    : observations to be saved for analysis                       
                                                                               
% Copyright: felix                                                             
% Date: 09-Aug-2017                                                            
                                                                               
% Set behavior for debug mode                                                  
if nargin==0, tobError('do', 4, 'mask', {}); return; else store=[]; obs=[]; end
                                                                               
if strcmp(setting.wintype, 'hanning') && setting.hopsize~=0.33
    l_frame = setting.framelen*32000;
    w = hann(l_frame, 'periodic');
end

data_cen = [];
data_ita = [];
data_cen_ita = expLoad(config, [], 1);
for ind_wav = 1:length(data_cen_ita(1).X_tob_cen)
    data_cen_ita(1).X_tob_cen{ind_wav} = 10*log10(data_cen_ita(1).X_tob_cen{ind_wav});
    if strcmp(setting.wintype, 'hanning') && setting.hopsize~=0.33
        data_cen_ita(2).X_tob_cen{ind_wav} = 10*log10(10.^(data_cen_ita(2).X_tob_cen{ind_wav}/10)/(l_frame/sum(w)).^2*l_frame/sum(w.^2));
    end
    ttest_wav(:, ind_wav) = ttest2(data_cen_ita(1).X_tob_cen{ind_wav}(:), data_cen_ita(2).X_tob_cen{ind_wav}(:));
    if size(data_cen_ita(1).X_tob_cen{ind_wav}, 2) == size(data_cen_ita(2).X_tob_cen{ind_wav}, 2) && isempty(find(isnan(data_cen_ita(1).X_tob_cen{ind_wav}), 1)) && isempty(find(isnan(data_cen_ita(2).X_tob_cen{ind_wav}), 1)) && isempty(find(isinf(data_cen_ita(1).X_tob_cen{ind_wav}), 1)) && isempty(find(isinf(data_cen_ita(2).X_tob_cen{ind_wav}), 1))
        data_cen = [data_cen data_cen_ita(1).X_tob_cen{ind_wav}];
        data_ita = [data_ita data_cen_ita(2).X_tob_cen{ind_wav}];
    end
end
for ind_band = 1:size(data_cen_ita(1).X_tob_cen{ind_wav}, 1)
    [ttest_band(ind_band), p(ind_band)] = ttest2(data_cen(ind_band, :), data_ita(ind_band, :));
end
ttest_wav(:, isnan(ttest_wav(1,:))) = [];

tob_f  = 10^3 * (2 .^ ([-17:11]/3));

figure, clf,
errorbar(tob_f(3:3:end), mean(data(1).err(3:3:end, :), 2), std(data(1).err(3:3:end, :), 0, 2)), hold on, 
errorbar(tob_f(3:3:end), mean(data(2).err(3:3:end, :), 2), std(data(2).err(3:3:end, :), 0, 2))
grid on, xlabel('Frequency (Hz)'), ylabel('Analysis error (dB)');
set(gca, 'xscale', 'log');
axis([1e1 2e4 -2 4]);
legend('Proposed implementation', 'Reference');


obs.ttest_band = ttest_band;
obs.ttest_band_p = p;
% obs.ttest_wav = ttest_wav;
obs.ttest_pass_rate = sum(ttest_wav==0, 2)/size(ttest_wav, 2);
disp('fin');
