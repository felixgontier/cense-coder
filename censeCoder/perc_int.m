function perc_int(act)

if ~nargin; act = 'disp'; end;

switch act
    case 'test'
        if exist('subj_notes.mat', 'file')
            load('subj_notes.mat');
            ind_test = length(subj_notes)+1;
        else
            q = 8;
            toblen = 1000*[0.02 0.06 0.125 0.25];
            ind_test = 1;
        end
        n_sen = 9;
        sen_sfx = {'_C_1', '_C_2', '_F_1', '_F_2', '_Q_1', '_Q_2', '_S_1', '_S_2', '_S_3'};
        subj_notes{ind_test} = zeros(2*n_sen, 1)-1;
        sentences_tr{ind_test} = cell(2*n_sen, 1);
        sp_cnt = zeros(6, 1); % Speaker test count
        
        
        
        % High fps
        sen = randperm(n_sen);
        set_cnt = round(rand(1, 1))+4;
        setting{ind_test}(:, 1:n_sen) = [sen; [ones(1, set_cnt) 2*ones(1, n_sen-set_cnt)]];
        
        % Low fps
        sen = randperm(n_sen);
        set_cnt = round(rand(1, 1))+4;
        setting{ind_test}(:, n_sen+1:2*n_sen) = [sen; [3*ones(1, set_cnt) 4*ones(1, n_sen-set_cnt)]];
        
        rp = randperm(size(setting{ind_test}, 2));
        setting{ind_test} = setting{ind_test}(:, rp);

        for ind_setting = 1:size(setting{ind_test}, 2)
            clc;
            disp('----- Perceptive test on intelligibility -----');
            disp(['Test number ' num2str(ind_test) '.']);
            disp(['Sample ' num2str(ind_setting) ' of ' num2str(size(setting{ind_test}, 2)) '.']);
            sp = round(6*rand(1, 1)+0.5);
            while sp_cnt(sp) > 3; sp = round(6*rand(1, 1)+0.5); end
            sp_cnt(sp) = sp_cnt(sp)+1;
            
            [y, Fs] = audioread(['../../decoded_samples/perc_int/' num2str(sp) sen_sfx{setting{ind_test}(1, ind_setting)} '_q8_l' num2str(toblen(setting{ind_test}(2, ind_setting))) '.wav']);
            
            while isempty(sentences_tr{ind_test}{ind_setting}) || ~isnumeric(subj_notes{ind_test}(ind_setting)) || (subj_notes{ind_test}(ind_setting)) < 1 || (subj_notes{ind_test}(ind_setting)) > 5
                sound(y, Fs);
                sentences_tr{ind_test}{ind_setting} = input('Sentence transcription: ', 's');
                subj_notes{ind_test}(ind_setting) = input('Overall intelligibility note (1-5): ');
                clear sound;
            end
        end

        if isempty(find(subj_notes{ind_test} == -1, 1))
            disp('Test complete, results saved.');
            save('subj_notes.mat', 'toblen', 'setting', 'subj_notes', 'sentences_tr');
        else
            disp('Test failed, results discarded.');
        end
    case 'tr'
        if exist('subj_notes.mat', 'file')
            load('subj_notes.mat');
        else
            error('Test results not found.');
        end
        
        for ind_test = 1:length(sentences_tr)
            for ind_setting = 1:length(sentences_tr{ind_test})
                disp(sentences_tr{ind_test}{ind_setting});
                tr_correct = input('Correct words: ');
                tr_nwords = input('Total words: ');
                tr_ratio{ind_test}(ind_setting) = tr_correct/tr_nwords;
            end
        end
        
        save('subj_notes_c.mat', 'toblen', 'setting', 'subj_notes', 'sentences_tr', 'tr_ratio');
    case 'disp'
        if exist('subj_notes_c.mat', 'file')
            load('subj_notes_c.mat');
        else
            error('No test results with transcription ratio found.');
        end
        
        notes = cell(length(toblen), 1);
        tr_r = cell(length(toblen), 1);
        
        for ind_test = 1:length(setting)
            for ind_setting = 1:size(setting{ind_test}, 2)
                notes{setting{ind_test}(2, ind_setting)}(end+1, 1) = subj_notes{ind_test}(ind_setting);
                tr_r{setting{ind_test}(2, ind_setting)}(end+1, 1) = tr_ratio{ind_test}(ind_setting);
            end
        end
        
        for ind_toblen = 1:length(toblen)
            m_notes(ind_toblen) = mean((notes{ind_toblen}-1)/4);
            s_notes(ind_toblen) = std((notes{ind_toblen}-1)/4);
            m_tr(ind_toblen) = mean(tr_r{ind_toblen});
            s_tr(ind_toblen) = std(tr_r{ind_toblen});
        end
        
        figure(1), clf, 
        errorbar([4 8 16 50], flip(m_notes), flip(s_notes)),
        hold on,
        errorbar([4.2 8.2 16.2 50.2], flip(m_tr), flip(s_tr)),
        axis([0 55 -0.1 1.1]), grid on, xlabel('Analysis frames per second'), ylabel('Intelligibility metric')
        legend('Subjective judgement', 'Transcription ratio', 'location', 'southeast')
        set(gca, 'xtick', [4 8 16 50]);

        % 23M-55F-17M-60M-22F-22M-24M-23M
        
end


end

