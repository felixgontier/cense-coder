function [config, store, obs] = ceco4metrics(config, setting, data)              
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
if nargin==0, censeCoder('do', 4, 'mask', {}); return; else store=[]; obs=[]; end
                                                                                 
addpath(genpath('C:\Program Files\MATLAB\R2015b\toolbox\libsvm-3.22'));
addpath(genpath('C:\Program Files\MATLAB\R2015b\toolbox\rastamat'));
addpath(genpath('util'));

switch setting.dataset
    case 'speech' % Intelligibility I3 metric
        sr = 44100;
        l_frame = 1024;
        l_hop = 0.5*l_frame;

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
                x = [x; zeros(l_hop-mod(size(x, 1)-l_frame, l_hop), 1)];
                %% Magnitude spectrogram via STFT
                x_spec{ind_file} = specgram(x, l_frame, sr, l_frame, l_frame-l_hop);
            end
            save([datapath 'rush_clean_spec_' num2str(l_frame) '.mat'], 'x_spec'); % Save for future use
        end
        
        f = (0:sr/2/(l_frame/2):sr/2)'/1000; % fft frequency vector in kHz
        % Rounded-exponential (ro-ex) filter
        w = sroexfilter(f); % filter amplitude coefficients
        for ind_file = 1:length(data.x_rec{1})
            disp(['Processing file ' num2str(ind_file) ' of ' num2str(length(data.x_rec{1})) '...']);
            % Prep the data for CSII computation
            y_spec = specgram(data.x_rec{1}{ind_file}, l_frame, sr, l_frame, l_frame-l_hop);
            if size(y_spec, 2) > size(x_spec{ind_file}, 2) y_spec = y_spec(:, 1:size(x_spec{ind_file}, 2)); elseif size(y_spec, 2) < size(x_spec{ind_file}, 2) x_spec{ind_file} = x_spec{ind_file}(:, 1:size(y_spec, 2)); end

            if strcmp(setting.intelind, 'CSII')
                msc{ind_file} = ((abs(sum(x_spec{ind_file}.*conj(y_spec), 2))).^2)./(sum((abs(x_spec{ind_file})).^2, 2).*sum((abs(y_spec)).^2, 2));
                msc_mat(ind_file) = mean(msc{ind_file});
                for ind_frame = 1:size(y_spec, 2)
                    snr_csii(ind_frame, :) = 10*log10((sum(w.*repmat(msc{ind_file}, 1, size(w, 2)).*repmat(abs(y_spec(:, ind_frame)).^2, 1, size(w, 2))))./...
                        (sum(w.*(1-repmat(msc{ind_file}, 1, size(w, 2))).*repmat(abs(y_spec(:, ind_frame)).^2, 1, size(w, 2)))));
                end
                t_csii = (snr_csii+15)/30; % normalisation
                csii(ind_file) = mean(mean(t_csii, 2));

%                 P = sum(msc{ind_file}.*(abs(y_spec)).^2, 2);
%                 N = sum((1-msc{ind_file}).*(abs(y_spec)).^2, 2);
%                 snr_csii = 10*log10((sum(w.*repmat(P, [1 size(w, 2)])))./(sum(w.*repmat(N, [1 size(w, 2)]))));
%                 t_csii = (snr_csii+15)/30; % normalisation
%                 csii{ind_file} = mean(t_csii);
            elseif strcmp(setting.intelind, 'fwSNRseg')
                X = [];
                Y = [];
                for ind_band = 1:size(w, 2)
                    X(ind_band, :) = sum(repmat(w(:, ind_band), 1, size(x_spec{ind_file}, 2)).*abs(x_spec{ind_file}), 1);
                    Y(ind_band, :) = sum(repmat(w(:, ind_band), 1, size(y_spec, 2)).*abs(y_spec), 1);
                end
                fwSNRseg(ind_file) = (10/size(y_spec, 2))*sum(sum(log10((X.^2)./((X-Y).^2)), 1)/size(w, 2), 2);
            end            
        end
        if strcmp(setting.intelind, 'CSII')
            obs.msc_mat = msc_mat;
            obs.msc = msc;
            obs.csii = csii;
        elseif strcmp(setting.intelind, 'fwSNRseg')
            obs.fwSNRseg = fwSNRseg;
        end
        %obs.csii = csii{1};
    case 'urbansound8k' % Classification
        %% Feature extraction
        if ispc; load('util\labels.mat'); else load('util/labels.mat'); end
        load_data = expLoad(config, [], 1);
        x_desc = cell(length(load_data.X_desc), 1);
        for ind_fold = 1:length(load_data.X_desc)
            disp(['Processing fold ' num2str(ind_fold) ' of ' num2str(length(load_data.X_desc)) '...']);
%             x_desc{ind_fold} = zeros(275, 1);
            for ind_file = 1:length(load_data.X_desc{ind_fold})
                if strcmp(setting.desc, 'mel')
                    if setting.quant ~= 0
                        X_mel{ind_fold}{ind_file} = double(load_data.X_desc{ind_fold}{ind_file}).*load_data.x_mel_max{ind_fold}{ind_file}./(2^(setting.quant-1)-1); % Datatype size minus 1 for the delta-comp
                    else
                        X_mel{ind_fold}{ind_file} = load_data.X_desc{ind_fold}{ind_file};
                    end
                    X_mel{ind_fold}{ind_file}(X_mel{ind_fold}{ind_file} == 0) = eps;
                    X_cep = spec2cep(exp(X_mel{ind_fold}{ind_file}), 25, 2);
                    if size(X_cep, 2)>1
                        x_desc{ind_fold}(:, ind_file) = [min(X_cep')'; max(X_cep')'; median(X_cep, 2); mean(X_cep, 2); var(X_cep, 0, 2); skewness(X_cep, 1, 2); kurtosis(X_cep, 1, 2); mean(diff(X_cep, 1, 2), 2); var(diff(X_cep, 1, 2), 0, 2); mean(diff(X_cep, 2, 2), 2); var(diff(X_cep, 2, 2), 0, 2)];
                    else
                        x_desc{ind_fold}(:, ind_file) = [X_cep; X_cep; median(X_cep, 2); mean(X_cep, 2); var(X_cep, 0, 2); skewness(X_cep, 1, 2); kurtosis(X_cep, 1, 2); mean(diff(X_cep, 1, 2), 2); var(diff(X_cep, 1, 2), 0, 2); mean(diff(X_cep, 2, 2), 2); var(diff(X_cep, 2, 2), 0, 2)];
                    end
                elseif strcmp(setting.desc, 'tob')
                    if setting.quant ~= 0
                        X_tob = (double(load_data.X_desc{ind_fold}{ind_file}).*load_data.q_norm{ind_fold}{ind_file}(2)./(2^(setting.quant-1)-1))+load_data.q_norm{ind_fold}{ind_file}(1);
                    else
                        X_tob = load_data.X_desc{ind_fold}{ind_file};
                    end
                    X_cep = spec2cep((10.^(X_tob./10))*8192, 25, 2);
                    if size(X_cep, 2)>1
                        x_desc{ind_fold}(:, ind_file) = [min(X_cep')'; max(X_cep')'; median(X_cep, 2); mean(X_cep, 2); var(X_cep, 0, 2); skewness(X_cep, 1, 2); kurtosis(X_cep, 1, 2); mean(diff(X_cep, 1, 2), 2); var(diff(X_cep, 1, 2), 0, 2); mean(diff(X_cep, 2, 2), 2); var(diff(X_cep, 2, 2), 0, 2)];
                    else
                        x_desc{ind_fold}(:, ind_file) = [X_cep; X_cep; median(X_cep, 2); mean(X_cep, 2); var(X_cep, 0, 2); skewness(X_cep, 1, 2); kurtosis(X_cep, 1, 2); mean(diff(X_cep, 1, 2), 2); var(diff(X_cep, 1, 2), 0, 2); mean(diff(X_cep, 2, 2), 2); var(diff(X_cep, 2, 2), 0, 2)];
                    end
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

