function [D, D_subset_idx, pitch, optinf] = build_dictionary_RWC_single_pitch(path_input_files, param)

%% read training data (a file contains all single notes)
train_wav = [];
train_pitch = [];
path_input_files = listfile(path_input_files);
for ifile = 1:length(path_input_files)
    training_data = load(path_input_files{ifile});
    train_wav = [train_wav; training_data.corpus(:,1)];
    train_pitch = [train_pitch; cell2mat(training_data.corpus(:,2))];
    clear training_data;
end

%% initial for dictionary learning algorithm
% idata = load(param.D0_path{param.cur_fold, param.cur_inst});
% oriD0 = idata.D;
% pitch0 = idata.pitch;
% clear idata;
% % pitch0 = param.pitch_D0{param.cur_fold, param.cur_inst};
% D0 = reshape(oriD0, [size(oriD0,1), 1 size(oriD0,2)]);
%% start training dictionary
tic
switch lower(param.dict_type)    
    %% for each pitch, train multiple codewords in supervised fashion
    case 'supervised_more_codeword'
        cid = 1; % idx of current codeword
        np = param.num_codeword_per_pitch;
        %% for each pitch, extract corresponding training data
        pitch0 = unique(train_pitch);
        pn = length(pitch0); % pitch number
        signal_length = round(param.max_length);
        D = zeros(signal_length, 1, pn * np);
        for i = 1:length(pitch0)            
            %% find training data
            target_pitch = pitch0(i);
            idx_training_data = find(train_pitch == target_pitch);
            % no training data
            if length(idx_training_data) == 0
                error('Training data should exist');
            end
            %% extract and arrange corresponding data            
            % old method: concatenate all training data as a single vector
            for j = 1:length(idx_training_data)
                idx = idx_training_data(j);
                if param.norm_train
                    train_wav{idx} = l2norm(train_wav{idx}')';
                end
                train_data{j,1} = train_wav{idx};                
            end
            train_data = cell2mat(train_data);
            train_data = reshape(train_data, [size(train_data,1), 1, size(train_data,2)]);
            %% set initial dictionary codewords
            % repeat from initial dictioanry            
%             DD = repmat(D0(1:signal_length, 1, i), [1, 1, np]);
%             % add noise
%             for i=1:np % awgn does not support more than 3 dim
%                 DD(:,:,i) = awgn(DD(:,:,i), param.awgn_snr); 
%             end
            DD = rand(signal_length, 1, np);
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
        pitch0 = unique(train_pitch);
        pn = length(pitch0); % pitch number
        signal_length = round(param.max_length);
        D = zeros(signal_length, 1, pn * np);
        for i = 1:length(pitch0)            
            %% find training data
            target_pitch = pitch0(i);
            idx_training_data = find(train_pitch == target_pitch);
            % no training data
            if length(idx_training_data) == 0
                error('Training data should exist');
            end
            %% extract and arrange corresponding data
            % new method
            sl = cellfun(@length, train_wav); % signal length
            ml = max(sl(idx_training_data)); % maximum length
            train_data = zeros(ml, length(idx_training_data));
            for j = 1:length(idx_training_data)
                idx = idx_training_data(j);
                if param.norm_train
                    train_wav{idx} = l2norm(train_wav{idx}')';
                end
                train_data(1:sl(idx),j) = train_wav{idx};
            end            
            train_data = reshape(train_data, [size(train_data,1), 1, size(train_data,2)]);
            %% set initial dictionary codewords            
            DD = rand(signal_length, 1, np);
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
end
training_time = toc;

D_subset_idx(1,1) = 1;
D_subset_idx(2,1) = size(D, 2);
display(['dictionary training takes: ', num2str(training_time), ' seconds.']);
end