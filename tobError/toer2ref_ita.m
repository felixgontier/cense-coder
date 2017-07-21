function [config, store, obs] = toer2ref_ita(config, setting, data)            
% toer2ref_ita REF_ITA step of the expLanes experiment tobError                
%    [config, store, obs] = toer2ref_ita(config, setting, data)                
%      - config : expLanes configuration state                                 
%      - setting   : set of factors to be evaluated                            
%      - data   : processing data stored during the previous step              
%      -- store  : processing data to be saved for the other steps             
%      -- obs    : observations to be saved for analysis                       
                                                                               
% Copyright: felix                                                             
% Date: 12-Jul-2017                                                            
                                                                               
% Set behavior for debug mode                                                  
if nargin==0, tobError('do', 2, 'mask', {}); return; else store=[]; obs=[]; end
                                                                               
sr = 32000;

l_frame = round(setting.reflen*sr);
l_hop = 1*l_frame;

switch setting.dataset
    case 'noise'
    case 'speech'
        datapath = [config.inputPath 'rush/'];
        rush_dir = dir(datapath);
        rush_names = {rush_dir.name};
        ind_wav = 0; % Real number of .wav files
        for ind_file = 1:numel(rush_names)
            if length(rush_names{ind_file}) > 4 && strcmp(rush_names{ind_file}(end-3:end), '.wav')
                ind_wav = ind_wav+1;
                file_path{ind_wav} = [datapath rush_names{ind_file}];
            end
        end
    case 'urbansound8k'
        ind_wav = 0; % Real number of .wav files
        for ind_fold = 1:5
            datapath = [config.inputPath 'UrbanSound8K/audio/fold' num2str(ind_fold) '/'];
            us8k_dir = dir(datapath);
            us8k_names = {us8k_dir.name};
            for ind_file = 1:numel(us8k_names)
                if length(us8k_names{ind_file}) > 4 && strcmp(us8k_names{ind_file}(end-3:end), '.wav')
                    ind_wav = ind_wav+1;
                    file_path{ind_wav} = [datapath us8k_names{ind_file}];
                    wav_name{ind_wav} = us8k_names{ind_file};
                end
            end
        end
end

switch setting.dataset
    case 'noise'
        if exist(['noise_' num2str(setting.reflen) '.mat'], 'file')
            load(['noise_' num2str(setting.reflen) '.mat']);
            for ind_wav = 1:100
                x = x_noise{ind_wav};
                if mod(size(x, 1)-l_frame, l_hop)
                    x = [x; zeros(l_hop-mod(size(x, 1)-l_frame, l_hop), 1)]; % Sup
                end
                n_x = floor(length(x)/l_frame);
                for ind_x = 1:n_x
                    a = itaAudio(x((ind_x-1)*l_frame+1:ind_x*l_frame), sr, 'time');
                    b = ita_mpb_filter(a, '3-oct');
                    X_tob_ref{ind_wav}(:, ind_x) = sum(b.time.^2/length(x((ind_x-1)*l_frame+1:ind_x*l_frame)), 1)';
                end
            end
        else
            error('No file found');
        end
    case 'speech'
        for ind_wav = 1:length(file_path)
            disp(['Processing file ' num2str(ind_wav) ' of ' num2str(length(file_path)) '...']);
            [x, sr2] = audioread(file_path{ind_wav});
            x = resample(x(:, 1), sr, sr2);
            % Analysis
            if mod(size(x, 1)-l_frame, l_hop)
                x = [x; zeros(l_hop-mod(size(x, 1)-l_frame, l_hop), 1)]; % Sup
            end
            n_x = floor(length(x)/l_frame);
            for ind_x = 1:n_x
                a = itaAudio(x((ind_x-1)*l_frame+1:ind_x*l_frame), sr, 'time');
                b = ita_mpb_filter(a, '3-oct');
                X_tob_ref{ind_wav}(:, ind_x) = sum(b.time.^2/length(x((ind_x-1)*l_frame+1:ind_x*l_frame)), 1)';
            end
        end
    case 'urbansound8k'
        ind_wav2 = 0;
        for ind_wav = 1:length(file_path)
            disp(['Processing file ' num2str(ind_wav) ' of ' num2str(length(file_path)) '...']);
            [x, sr2] = audioread(file_path{ind_wav});
            x = resample(x(:, 1), sr, sr2);
            if length(x) > l_frame
                ind_wav2 = ind_wav2+1;
                % Analysis
                if mod(size(x, 1)-l_frame, l_hop)
                    x = [x; zeros(l_hop-mod(size(x, 1)-l_frame, l_hop), 1)]; % Sup
                end
                n_x = floor(length(x)/l_frame);
                for ind_x = 1:n_x
                    a = itaAudio(x((ind_x-1)*l_frame+1:ind_x*l_frame), sr, 'time');
                    b = ita_mpb_filter(a, '3-oct');
                    X_tob_ref{ind_wav2}(:, ind_x) = sum(b.time.^2/length(x((ind_x-1)*l_frame+1:ind_x*l_frame)), 1)';
                end
            end
        end
end

store.X_tob_ref = X_tob_ref;

