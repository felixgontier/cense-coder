function [config, store, obs] = ceco3metrics(config, setting, data)              
% ceco3metrics METRICS step of the expLanes experiment censeCoder                
%    [config, store, obs] = ceco3metrics(config, setting, data)                  
%      - config : expLanes configuration state                                   
%      - setting   : set of factors to be evaluated                              
%      - data   : processing data stored during the previous step                
%      -- store  : processing data to be saved for the other steps               
%      -- obs    : observations to be saved for analysis                         
                                                                                 
% Copyright: felix                                                               
% Date: 20-Apr-2017                                                              
                                                                                 
% Set behavior for debug mode                                                    
if nargin==0, censeCoder('do', 3, 'mask', {}); return; else store=[]; obs=[]; end
                                                                                 
addpath(genpath('C:\Program Files\MATLAB\R2015b\toolbox\libsvm-3.22'));
addpath(genpath('C:\Program Files\MATLAB\R2015b\toolbox\rastamat'));
addpath(genpath('util'));

%% TODO: Update classification part with stft averaging support ?
% 25/04/17: merged 'metric' and 'dataset' factors
switch setting.dataset
    case 'speech' % Intelligibility I3 metric
        % Load step 1 results data
        load_data = expLoad(config, [], 1);
        sr = 44100;
        l_frame = 1024;
        l_hop = 0.5*l_frame;
        if setting.fps % 0 means none
            n_fps = (sr+l_hop-l_frame)/l_hop; % Number of frames per second with base settings
            n_avg = round(n_fps/setting.fps); % Number of consecutive frames to average into one
        end

        if ispc; datapath = [config.inputPath 'rush\rush_clean_spec_' num2str(l_frame) '.mat']; else datapath = [config.inputPath 'rush/rush_clean_spec_' num2str(l_frame) '.mat']; end
        if exist(datapath)
            load(datapath);
        else
            if ispc; datapath = [config.inputPath 'rush\']; else datapath = [config.inputPath 'rush/']; end
            rush_dir = dir(datapath);
            rush_names = {rush_dir.name};
            ind_wav = 0; % Real number of .wav files
            for ind_file = 1:numel(rush_names)
                if length(rush_names{ind_file}) > 4 && strcmp(rush_names{ind_file}(end-3:end), '.wav')
                    ind_wav = ind_wav+1;
                    file_path{1}{ind_wav} = [datapath rush_names{ind_file}];
                end
            end
            for ind_file = 1:length(file_path{1})
                [x, Fs_temp] = audioread(file_path{1}{ind_file});
                x = resample(x(:, 1), sr, Fs_temp);
                x = x./max(abs(x));
                x(x==0) = eps;
                if length(x)<l_frame; x=[x;zeros(l_frame-length(x),1)]; end
                %x = x(1:end-mod(end, l_frame*l_hop),1); % Rounding of x size
                x = [x; zeros(l_hop-mod(size(x, 1)-l_frame, l_hop), 1)];
                %% Magnitude spectrogram via STFT
                x_spec{ind_file} = powspec(x, sr, l_frame/sr, l_hop/sr, 0);
            end
            save([datapath 'rush_clean_spec_' num2str(l_frame) '.mat'], 'x_spec'); % Save for future use
        end
        
        for ind_file = 1:length(load_data.x_mel{1})
            disp(['Processing file ' num2str(ind_file) ' of ' num2str(length(load_data.x_mel{1})) '...']);
            % Prep the data for I3 computation
            if setting.quant ~= 0
                y_mel{ind_file} = exp(double(load_data.x_mel{1}{ind_file}).*load_data.x_mel_max{1}{ind_file}./(2^(setting.quant-1)-1)); % Datatype size minus 1 for the delta-comp
            else
                y_mel{ind_file} = exp(load_data.x_mel{1}{ind_file});
            end
            %y_mel{ind_file}(y_mel{ind_file} == 0) = eps;
            y_spec{ind_file} = invaudspec(y_mel{ind_file}, sr, l_frame, 'mel', 0, sr/2, 1, 1);
            if setting.fps
                y_spec{ind_file} = reshape(repmat(y_spec{ind_file}, n_avg, 1), size(y_spec{ind_file}, 1), []); % Replicate STFT
                y_spec{ind_file} = y_spec{ind_file}(:, 1:load_data.n_frames{1}{ind_file}); % Truncate to obtain same size as before averaging
            end
            y_spec{ind_file}(y_spec{ind_file} == 0) = eps;
            
            msc{ind_file} = ((abs(sum(sqrt(x_spec{ind_file}).*sqrt(y_spec{ind_file}), 2))).^2)./(sum(x_spec{ind_file}, 2).*sum(y_spec{ind_file}, 2));
            msc_mat(ind_file) = mean(msc{ind_file});
            
            % Rounded-exponential (ro-ex) filter
            f = (0:sr/2/(l_frame/2):sr/2)'/1000; % fft frequency vector in kHz
            w = sroexfilter(f); % filter amplitude coefficients
            
            for ind_frame = 1:size(y_spec{ind_file}, 2)
                snr_csii(ind_frame, :) = 10*log10((sum(w.*repmat(msc{ind_file}, 1, size(w, 2)).*repmat(y_spec{ind_file}(:, ind_frame), 1, size(w, 2))))./...
                    (sum(w.*(1-repmat(msc{ind_file}, 1, size(w, 2))).*repmat(y_spec{ind_file}(:, ind_frame), 1, size(w, 2)))));
            end
            t_csii = (snr_csii+15)/30; % normalisation
            csii{ind_file} = mean(mean(t_csii, 2));
            
        end
        obs.msc_mat = msc_mat;
        obs.msc = msc;
        
        obs.csii = csii{1};
    case 'urbansound8k' % Classification
        %% Feature extraction
        if ispc; load('util\labels.mat'); else load('util/labels.mat'); end
        load_data = expLoad(config, [], 1);        
        x_desc = cell(length(load_data.x_mel), 1);
        for ind_fold = 1:length(load_data.x_mel)
            disp(['Processing fold ' num2str(ind_fold) ' of ' num2str(length(load_data.x_mel)) '...']);
            x_desc{ind_fold} = zeros(275, 1);
            for ind_file = 1:length(load_data.x_mel{ind_fold})
                if setting.quant ~= 0
                    x_mel{ind_fold}{ind_file} = double(load_data.x_mel{ind_fold}{ind_file}).*load_data.x_mel_max{ind_fold}{ind_file}./(2^(setting.quant-1)-1); % Datatype size minus 1 for the delta-comp
                else
                    x_mel{ind_fold}{ind_file} = load_data.x_mel{ind_fold}{ind_file};
                end
                x_mel{ind_fold}{ind_file}(x_mel{ind_fold}{ind_file} == 0) = eps;
                x_cep = spec2cep(exp(x_mel{ind_fold}{ind_file}), 25, 2);
                if size(x_cep, 2)>1
                    x_desc{ind_fold}(:, ind_file) = [min(x_cep')'; max(x_cep')'; median(x_cep, 2); mean(x_cep, 2); var(x_cep, 0, 2); skewness(x_cep, 1, 2); kurtosis(x_cep, 1, 2); mean(diff(x_cep, 1, 2), 2); var(diff(x_cep, 1, 2), 0, 2); mean(diff(x_cep, 2, 2), 2); var(diff(x_cep, 2, 2), 0, 2)];
                else
                    x_desc{ind_fold}(:, ind_file) = [x_cep; x_cep; median(x_cep, 2); mean(x_cep, 2); var(x_cep, 0, 2); skewness(x_cep, 1, 2); kurtosis(x_cep, 1, 2); mean(diff(x_cep, 1, 2), 2); var(diff(x_cep, 1, 2), 0, 2); mean(diff(x_cep, 2, 2), 2); var(diff(x_cep, 2, 2), 0, 2)];
                end
                
                x_class{ind_fold}(ind_file, 1) = file_class(find(strcmp(file_name, load_data.wav_name{ind_fold}{ind_file}), 1));
            end
            x_desc{ind_fold} = x_desc{ind_fold}'; % Lines: Examples, Columns: features
        end
        clear x_mel x_cep;
        %% Classification
        class_acc = zeros(length(x_desc), 1);
        for ind_cv = 1:length(x_desc) % Cross-validation
            disp(['Fold configuration ' num2str(ind_cv) ' of '  num2str(length(x_desc)) '.']);
            % Data separation
            x_train = [];
            y_train = [];
            for ind_fold = 1:length(x_desc)
                if ind_fold ~= ind_cv
                    x_train = [x_train; x_desc{ind_fold}];
                    y_train = [y_train; x_class{ind_fold}];
                end
            end
            x_test = x_desc{ind_cv};
            y_test = x_class{ind_cv};
            
            % minmax mapping to 0-1
            x_test = (x_test-repmat(min(x_train), size(x_test, 1), 1))./(repmat(max(x_train), size(x_test, 1), 1)-repmat(min(x_train), size(x_test, 1), 1));
            x_train = (x_train-repmat(min(x_train), size(x_train, 1), 1))./(repmat(max(x_train), size(x_train, 1), 1)-repmat(min(x_train), size(x_train, 1), 1));

            % Classification
            switch setting.classmethod
                case 'SVM'
                    mdl = svmtrain(y_train, x_train, '-q -g 0.1333 -c 250');
                    pre = svmpredict(y_test, x_test, mdl, '-q');
                    class_acc(ind_cv) = sum(pre == y_test)/length(y_test);
                case 'RF'
                    mdl = TreeBagger(500, x_train, y_train);
                    pre = predict(mdl, x_test);
                    class_acc(ind_cv) = sum(str2num(cell2mat(pre)) == y_test)/length(y_test);
                case 'DT'
                    mdl = fitctree(x_train, y_train);
                    pre = predict(mdl, x_test);
                    class_acc(ind_cv) = sum(pre == y_test)/length(y_test);
                case 'KNN'
                    mdl = fitcknn(x_train, y_train);
                    mdl.NumNeighbors = 5;
                    pre = predict(mdl, x_test);
                    class_acc(ind_cv) = sum(pre == y_test)/length(y_test);
            end
        end
        obs.cv_acc = class_acc;
end

