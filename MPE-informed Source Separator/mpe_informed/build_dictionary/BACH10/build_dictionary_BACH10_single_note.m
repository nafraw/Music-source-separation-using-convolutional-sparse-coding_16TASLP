function [D, D_subset_idx, pitch, optinf] = build_dictionary_BACH10_single_note(path_input_files, param)

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
D0 = reshape(oriD0, [size(oriD0,1), 1 size(oriD0,2)]);
%% start training dictionary
tic
switch lower(param.dict_type)    
    %% Make all data as exemplar
    case 'exemplar' % no dictionary learning
        %% for each pitch, extract corresponding training data and make all data as exemplar
        idx_codeword = 1;
        signal_length = max(cellfun(@length, note_wav));
        signal_length = max(signal_length, size(D0, 1));
        if length(param.max_length) ~= 0
            signal_length = max(signal_length, round(param.max_length));
        end
        for i = 1:length(pitch0)
            target_pitch = pitch0(i);
            idx_training_data = find(note_pitch == target_pitch);
            % no training data
            if length(idx_training_data) == 0
                tempD{idx_codeword} = oriD0(1:signal_length,i);
                pitch(idx_codeword, 1) = target_pitch;
                idx_codeword = idx_codeword + 1;
                continue;
            end
            %% extract and arrange corresponding data            
            for j = 1:length(idx_training_data)
                tempD{idx_codeword} = note_wav{idx_training_data(j)};
                pitch(idx_codeword, 1) = target_pitch;
                idx_codeword = idx_codeword + 1;
            end            
        end
        %% made the dictionary as a matrix
        D = zeros(signal_length, length(tempD));
        for i = 1:length(tempD)
            if length(param.max_length) ~= 0
                sig_len = min(signal_length, length(tempD{i}));
            else
                sig_len = length(tempD{i});
            end
            D(1:sig_len, i) = tempD{i};
        end
        optinf = []; % dummy variable, but required as this is output
    %% For each pitch, train a codeword in supervised fashion
    case 'supervised'
        %% for each pitch, extract corresponding training data
        for i = 1:length(pitch0)
            %% set signal length
            if length(param.max_length) ~= 0
                signal_length = round(param.max_length);
            else
                signal_length = size(D0,1);
            end
            %% find training data
            target_pitch = pitch0(i);
            idx_training_data = find(note_pitch == target_pitch);
            % no training data
            if length(idx_training_data) == 0
                D(1:signal_length,1,i) = oriD0(1:signal_length,i);
                continue;
            end
            %% extract and arrange corresponding data
            for j = 1:length(idx_training_data)
                train_data{j,1} = note_wav{idx_training_data(j)};
            end
            train_data = cell2mat(train_data);
            train_data = reshape(train_data, [size(train_data,1), 1, size(train_data,2)]);
            %% training
            if length(train_data) < signal_length
                tt = train_data;
                train_data = zeros(signal_length, 1);
                train_data(1:length(tt)) = train_data(1:length(tt)) + tt;
            end
            [D(1:signal_length,1,i), ~, optinf{i}] = ...
                cbpdndliu(D0(1:signal_length,1,i), train_data, param.lambda, param.opt);
            clear train_data;
        end
        pitch = pitch0;
        D = reshape(D, [size(D,1), size(D,3)]);
    %% for each pitch, train multiple codewords in supervised fashion
    case 'supervised_more_codeword'
        cid = 1; % idx of current codeword
        np = param.num_codeword_per_pitch;
        %% for each pitch, extract corresponding training data
        for i = 1:length(pitch0)
            %% set signal length
            if length(param.max_length) ~= 0
                signal_length = round(param.max_length);
            else
                signal_length = size(D0,1);
            end
            %% find training data
            target_pitch = pitch0(i);
            idx_training_data = find(note_pitch == target_pitch);
            % no training data
            if length(idx_training_data) == 0
%                 D(1:signal_length,1,cid) = oriD0(1:signal_length,i);
%                 pitch(cid,1) = target_pitch;
%                 cid = cid + 1;
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
            %% set initial dictionary codewords
            DD = rand(signal_length, 1, np);
%             % repeat from initial dictioanry
%             DD = repmat(D0(1:signal_length, 1, i), [1, 1, np]);
%             % add noise
%             for i=1:np % awgn does not support more than 3 dim
%                 DD(:,:,i) = awgn(DD(:,:,i), param.awgn_snr); 
%             end
            %% training
            if length(train_data) < signal_length
                tt = train_data;
                train_data = zeros(signal_length, 1);
                train_data(1:length(tt)) = train_data(1:length(tt)) + tt;
            end
            [D(1:signal_length,1,cid:cid+np-1), ~, optinf{i}] = ...
                cbpdndliu(DD, train_data, param.lambda, param.opt);
            pitch(cid:cid+np-1,1) = target_pitch;
            cid = cid + np;
            clear train_data;
            clear DD;
        end        
        D = reshape(D, [size(D,1), size(D,3)]);
    case 'supervised_more_codeword_no_concatenate'
        cid = 1; % idx of current codeword
        np = param.num_codeword_per_pitch;
        %% for each pitch, extract corresponding training data
        for i = 1:length(pitch0)
            %% set signal length
            if length(param.max_length) ~= 0
                signal_length = round(param.max_length);
            else
                signal_length = size(D0,1);
            end
            %% find training data
            target_pitch = pitch0(i);
            idx_training_data = find(note_pitch == target_pitch);
            % no training data
            if length(idx_training_data) == 0
%                 D(1:signal_length,1,cid) = oriD0(1:signal_length,i);
%                 pitch(cid,1) = target_pitch;
%                 cid = cid + 1;
                continue;
            end
            %% extract and arrange corresponding data
            sl = cellfun(@length, note_wav); % signal length
            ml = max(sl(idx_training_data)); % maximum length
            train_data = zeros(ml, length(idx_training_data));
            for j = 1:length(idx_training_data)
                idx = idx_training_data(j);
                if param.norm_train
                    note_wav{idx} = l2norm(note_wav{idx}')';
                end
                train_data(1:sl(idx),j) = note_wav{idx};
            end            
            train_data = reshape(train_data, [size(train_data,1), 1, size(train_data,2)]);            
            %% set initial dictionary codewords
            DD = rand(signal_length, 1, np);
%             % repeat from initial dictioanry
%             DD = repmat(D0(1:signal_length, 1, i), [1, 1, np]);
%             % add noise
%             for i=1:np % awgn does not support more than 3 dim
%                 DD(:,:,i) = awgn(DD(:,:,i), param.awgn_snr); 
%             end
            %% training
            if length(train_data) < signal_length
                tt = train_data;
                train_data = zeros(signal_length, 1);
                train_data(1:length(tt)) = train_data(1:length(tt)) + tt;
            end
            [D(1:signal_length,1,cid:cid+np-1), ~, optinf{i}] = ...
                cbpdndliu(DD, train_data, param.lambda, param.opt);
            pitch(cid:cid+np-1,1) = target_pitch;
            cid = cid + np;
            clear train_data;
            clear DD;
        end        
        D = reshape(D, [size(D,1), size(D,3)]);    
    %% Extract a (set of) period only for each codeword for building an exemplar dictionary
    case 'exemplar_fundamental'
        %% for each pitch, extract corresponding training data and make all data as exemplar
        idx_codeword = 1;
%         signal_length = max(cellfun(@length, note_wav));
%         signal_length = max(signal_length, size(D0, 1));
        
        for i = 1:length(pitch0)
            target_pitch = pitch0(i);
            idx_training_data = find(note_pitch == target_pitch);
            % no training data
            if length(idx_training_data) == 0
%                 tempD{idx_codeword} = oriD0(1:signal_length,i);
%                 pitch(idx_codeword, 1) = target_pitch;
%                 idx_codeword = idx_codeword + 1;
                continue;
            end
            %% extract and arrange corresponding data            
            for j = 1:length(idx_training_data)
                %  extract the fundamental periodic signal
                %  no normalization was perfomed on the signal.
                wave = note_wav{idx_training_data(j)};
                if length(wave) == 0
                    % this happens because the meta-data (txt-file) of
                    % bach10 is incorrect for some cases.
                    continue;
                end
                f = (2.^((target_pitch-69)/12))*440;
                [tempD{idx_codeword}, mode_p] = extract_periodic_signal(wave, f, param.sampling_rate);
                pitch(idx_codeword, 1) = target_pitch;
                idx_codeword = idx_codeword + 1;
            end            
        end
        %% made the dictionary as a matrix
        signal_length = max(cellfun(@length, tempD));
        if length(param.max_length) ~= 0
            signal_length = min(signal_length, round(param.max_length));
        end
        D = zeros(signal_length, length(tempD));
        for i = 1:length(tempD)
            if length(param.max_length) ~= 0
                sig_len = min(signal_length, length(tempD{i}));
            else
                sig_len = length(tempD{i});
            end
            D(1:sig_len, i) = tempD{i};
        end
        optinf = []; % dummy variable, but required as this is output
end
training_time = toc;

D_subset_idx(1,1) = 1;
D_subset_idx(2,1) = size(D, 2);
display(['dictionary training takes: ', num2str(training_time), ' seconds.']);
end