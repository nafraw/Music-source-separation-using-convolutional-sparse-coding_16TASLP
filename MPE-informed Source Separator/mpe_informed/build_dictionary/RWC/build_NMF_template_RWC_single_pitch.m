function [D, D_subset_idx, pitch, optinf] = build_NMF_template_RWC_single_pitch(path_input_files, param)
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
        pitch0 = unique(train_pitch);
        pn = length(pitch0); % pitch number
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