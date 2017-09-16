function [D, D_subset_idx, pitch, optinf] = build_NMF_template_BACH10_single_pitch(path_input_files, param)

%% read training data (a file contains all single notes)
training_data = load(path_input_files);
note_wav = training_data.note_wav;
note_pitch = training_data.note_pitch;
clear training_data;

%% initial for dictionary learning algorithm
idata = load(param.D0_path{param.cur_fold, param.cur_inst});
oriD0 = idata.D;
pitch0 = idata.pitch;
pitch0 = unique(pitch0);
clear idata;
% pitch0 = param.pitch_D0{param.cur_fold, param.cur_inst};
%% start training dictionary
tic
switch lower(param.dict_type)
    %% for each pitch, train multiple codewords in supervised fashion
    case 'supervised_more_codeword'
        cid = 1; % idx of current codeword
        np = param.num_codeword_per_pitch;
        npfreq = floor(param.stft.wlen/2) + 1;
        D = zeros(npfreq, np);
        %% for each pitch, extract corresponding training data
        for i = 1:length(pitch0)            
            %% find training data
            target_pitch = pitch0(i);
            idx_training_data = find(note_pitch == target_pitch);
            % no training data
            if length(idx_training_data) == 0
                continue;
            end
            %% extract and arrange corresponding data
            for j = 1:length(idx_training_data)
                idx = idx_training_data(j);
                if param.norm_train
                    note_wav{idx} = l2norm(note_wav{idx}')';
                end
                train_data{j,1} = note_wav{idx};
            end
            train_data = cell2mat(train_data);
            train_data = reshape(train_data, [size(train_data,1), 1, size(train_data,2)]);            
            [~, freq, train_data] = stft_jpk(train_data, param.stft);
            freq = freq(freq>=0);
            %% training
            [D(:,cid:cid+np-1), tmpH, optinf{i}] = template_learn_NMF(...
                abs(train_data), mat2cell(target_pitch), [], freq, param.nmf);
            
            pitch(cid:cid+np-1,1) = target_pitch;
            cid = cid + np;
            clear train_data;
            clear DD;
        end
end
training_time = toc;

D_subset_idx(1,1) = 1;
D_subset_idx(2,1) = size(D, 2);
display(['dictionary training takes: ', num2str(training_time), ' seconds.']);
end