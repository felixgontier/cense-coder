function perc_int(act)

switch act
    case 'test'
        if exist('subj_notes.mat', 'file')
            load('subj_notes.mat');
            ind_test = size(subj_notes, 3)+1;
        else
            fps = [2 4 6 8 10 20 0];
            mel = [10 20 30 40];
            ind_test = 1;
        end
        subj_notes(:,:,ind_test) = zeros(length(fps), length(mel))-1;

        disp('----- Perceptive test on intelligibility -----');
        disp(['Test number ' num2str(ind_test) '.']);

        fps_mel = combvec(fps, mel);
        rp = randperm(length(fps)*length(mel));
        fps_mel = fps_mel(:, rp);

        for ind_setting = 1:size(fps_mel, 2)
            disp(['Setting ' num2str(ind_setting) ' of ' num2str(size(fps_mel, 2)) '.']);
            [y, Fs] = audioread(['..\..\decoded_samples\Sample_' num2str(fps_mel(1, ind_setting)) '_' num2str(fps_mel(2, ind_setting)) '_8.wav']);
            y = y(1:min(10*Fs, end));
            ind_fps = find(fps==fps_mel(1,ind_setting), 1);
            ind_mel = find(mel==fps_mel(2,ind_setting), 1);
            while ~isnumeric(subj_notes(ind_fps, ind_mel, ind_test)) || (subj_notes(ind_fps, ind_mel, ind_test)) < 0 || (subj_notes(ind_fps, ind_mel, ind_test)) > 5
                sound(y, Fs);
                subj_notes(ind_fps, ind_mel, ind_test) = input('Intelligibility note? (0-5)');
                clear sound;
            end
        end

        if isempty(find(subj_notes(:,:,ind_test) == -1, 1))
            disp('Test complete, results saved.');
            save('subj_notes.mat', 'fps', 'mel', 'subj_notes');
        else
            disp('Test failed, results discarded.');
        end
    case 'disp'
        if exist('subj_notes.mat', 'file')
            load('subj_notes.mat');
        else
            error('Test results not found.');
        end
        if ndims(subj_notes) > 2
            mean_sn = mean(subj_notes, 3);
            var_sn = squeeze(var(permute(subj_notes, [3 1 2])));
        else
            mean_sn = subj_notes;
            var_sn = zeros(size(subj_notes));
        end
        %% FPS on x axis, Mel on legend
%         real_fps = [2, 4.1, 6.1, 7.7, 9.5, 21, 85];
%         figure, clf;
%         errorbar(mean_sn, var_sn), legend({'mel: 10', 'mel: 20', 'mel: 30', 'mel: 40'}), grid on, axis([0.5 7.5 -0.5 5.5])
%         xlabel('Frames per second'), ylabel('Subjective intelligibility');
%         legend({'mel: 10', 'mel: 20', 'mel: 30', 'mel: 40'}, 'Location', 'southeast');
%         ax = gca;
%         ax.XTickLabels = real_fps;
%         print(gcf, '-dpdf', 'report/figures/processed/percint_fps_mel.pdf');
        
        %% Mel on x axis, FPS on legend
        real_fps = {'2', '4.1', '6.1', '7.7', '9.5', '21', '85'};
        fps_lgd = cell(1, length(real_fps));
        for ind_lgd = 1:length(real_fps)
            fps_lgd{ind_lgd} = ['fps: ' real_fps{ind_lgd}];
        end
        figure, clf;
        errorbar(mean_sn', var_sn', '-x'), grid on, axis([0.5 4.5 -0.5 5.5])
        xlabel('Number of Mel bands'), ylabel('Subjective intelligibility score');
        legend(fps_lgd, 'Location', 'bestoutside');
        ax = gca;
        ax.XTickLabels = mel;
        set(gca,'XTick',[1:4]);
        print(gcf, '-depsc', 'report/figures/processed/percint_fps_mel.eps');
end

end

