function [W, H, maskD, inst_id] = mpe_informed_dict_NMF_wo_time(D, D_pitch, dict_sid, freq, p_stft_music, param, fid)
%  OUTPUT:
%    The W and H in Non-negative matrix factorization.
%    W: a p-dim cell of f by k(i) matrix. k is a scalar dependent on the
%    partition.
%    H: a p-dim cell of k(i) by t matrix.
%    inst_id: a p-dim cell of k(i)-dim vector. The elements indicate the
%    corresponding instrument of each column in W.
%  INPUT:

display(['Running the core algorithm......']);
[p, f, t] = size(p_stft_music);
W = cell(p, 1);
H = cell(p, 1);
inst_id = cell(p, 1);
freq = freq(freq>=0);
%% read the score (text)
meta = read_mpe(param.path_mpe_result{fid});
%% for each partition, perform ...
s = 0;
nPitch = param.dict_train.num_codeword_per_pitch;
% fei = fsi + param.stft.wlen - 1;
for pid = 1:p
    %% calculate the start and end time of current partition
    s_sec = (s/param.pre_process.sampling_rate);
    e_sec = ((s+param.prob_partition.dim_q)/param.pre_process.sampling_rate);
    %% extract pitch information
    s_idx = ceil(s_sec * 100) + 1; % note: MPE output every 10 msec
    e_idx = min(floor(e_sec * 100) + 1, size(meta, 1));
    pitch = meta(s_idx: e_idx, 2:end);
    pitch = sort(pitch(isfinite(pitch)));
    if param.algorithm.mpe.percent >= 1 % use all mpe result
        pitch = unique(pitch); % the used pitch
    else % select mpe result based on statistics
        total_pitch = length(pitch);
        pitch = pitch_counter(pitch);
        remove_idx = find(pitch(2, :) < (total_pitch*param.algorithm.mpe.percent));
        pitch(:, remove_idx) = []; % remove error-prone pitch
        pitch(2,:) = []; % remove counting number
    end
    maskD{pid} = []; % used to select W0
    for inst = 1:param.npart
        idx = find(ismember(D_pitch{inst}, pitch));
        used_pitch{inst} = D_pitch{inst}(idx);
        used_pitch{inst} = unique(D_pitch{inst}(idx));
        inst_id{pid} = [inst_id{pid}; inst*ones(length(idx),1)];
        maskD{pid} = [maskD{pid}; find(ismember(D_pitch{inst}, pitch)) + dict_sid(inst) - 1];
    end
    
    %% run algorithm
    W0 = D(:, maskD{pid});
    [W{pid}, H{pid}, optinf] = constr_NMF(...
        squeeze(abs(p_stft_music(pid,:,:))), W0, used_pitch, [], freq, param.algorithm);
    % pad zero data if an instrument is not used
    % otherwise, reconstruction will fail.
    for inst = 1:param.npart
        if isempty(used_pitch{inst} )
            W{pid} = [W{pid}, zeros(f, 1)];
            H{pid} = [H{pid}; zeros(1, t)];
            inst_id{pid}(end+1) = inst;
        end
    end
    s = s + param.prob_partition.hop;
end


%% save result
display(['Saving the result of core algorithm......']);
check_path(param.path_separation{fid});
save(param.path_separation{fid}, 'W', 'H', 'maskD', 'inst_id', 'optinf', '-v7.3');
end

function newIdx = convertIdx(idx, oldSize, newSize)
newIdx = [];
ratio = newSize/oldSize;
for i = 1:length(idx)
    ii = idx(i);
    s = floor(ii*ratio);
    s = max(s, 1);
    e = ceil(ii*ratio);
    e = min(e, newSize);
    newIdx = [newIdx s:e];
end
newIdx = unique(newIdx);
end

function output = pitch_counter(pitch)
    output(1,:) = unique(pitch); % presented pitch
    for itP = 1:length(output)
        % count the presence times of each pitch
        output(2,itP) = length(find(pitch == output(1,itP)));
    end
end