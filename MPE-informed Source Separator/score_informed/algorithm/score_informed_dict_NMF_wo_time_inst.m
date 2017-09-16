function [W, H, maskD, inst_id] = score_informed_dict_NMF_wo_time_inst(D, pitch, dict_sid, freq, p_stft_music, param, fid)
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
meta = importdata(param.path_score{fid});
%% set onset/offset from the meta
if strcmpi(param.offset_define, 'txt')
    ind = find(meta_smsec > meta_emsec);    
    meta(ind, 2) = inf; % fix the offset < onset problem in the text file
    meta_smsec = meta(:, 1); % onset (in msec) of meta data
    meta_emsec = meta(:, 2);
elseif strcmpi(param.offset_define, 'next_onset')
    meta_smsec = [];
    meta_emsec = [];
    old_meta = meta;
    meta = [];
    for ins = 1:param.npart
        ind = find(old_meta(:, 4) == ins);
        meta_smsec = [meta_smsec; old_meta(ind, 1)]; % onset (in msec) of meta data
        meta_emsec = [meta_emsec; old_meta(ind(2:end), 1)];        
        meta_emsec(end+1) = inf;
        meta = [meta; old_meta(ind,:)];
    end
    meta(:,1:2) = [meta_smsec, meta_emsec];
else
    error('unknown offset definition');
end
%% extract instrument-wise annotation
for inst = 1:param.npart
    idx_ins{inst} = find(meta(:,4) == inst);
    meta_ins_smsec{inst} = meta(idx_ins{inst}, 1); % onset (in msec) of meta data
    meta_ins_emsec{inst} = meta_ins_smsec{inst}(2:end);
    meta_ins_emsec{inst}(end+1) = inf;
end
%% for each partition, perform ...
s = 0;
nPitch = param.dict_train.num_codeword_per_pitch;
% fei = fsi + param.stft.wlen - 1;
for pid = 1:p
    nseg = param.prob_partition.dim_q; % number of samples in a segment
    % start time of the parition
    s_msec = (s/param.pre_process.sampling_rate) * 1000;
    % end time of the partition
    e_msec = ((s+nseg)/param.pre_process.sampling_rate) * 1000;    
    %% extract annotation for putting constraints    
    maskD{pid} = []; % used to select W0
    used_pitch = [];
    for inst = 1:param.npart
        % check which   pitch overlaps between the region [s_msec, e_msec].
        [overlap] = check_overlap(s_msec, e_msec, meta_ins_smsec{inst}, meta_ins_emsec{inst});
        used_pitch = [used_pitch; unique(sort(meta(idx_ins{inst}(overlap), 3)))];
    end
    
    for inst = 1:param.npart                
        idx = find(ismember(pitch{inst}, used_pitch));
        redundant_pitch{inst} = unique(pitch{inst}(idx));
        inst_id{pid} = [inst_id{pid}; inst*ones(length(idx),1)];
        maskD{pid} = [maskD{pid}; idx + dict_sid(inst) - 1];
    end
    
    %% run algorithm
    W0 = D(:, maskD{pid});
    [W{pid}, H{pid}, optinf] = constr_NMF(...
        squeeze(abs(p_stft_music(pid,:,:))), W0, redundant_pitch, [], freq, param.algorithm);
    s = s + param.prob_partition.hop;
end
%% save result
display(['Saving the result of core algorithm......']);
check_path(param.path_separation{fid});
save(param.path_separation{fid}, 'W', 'H', 'maskD', 'inst_id', 'optinf', '-v7.3');
end

function [overlap] = check_overlap(start_ref, end_ref, start_point, end_point)
    overlap = (end_ref >= start_point) & (end_point >= start_ref);
end

function y = find_frame(x, fsi)
    n = size(x, 1);
    for i = 1:n % for each pitch, find  the boundary frame
        fidx = find(fsi <= x(i,1));
        if isempty(fidx)
            y(i,1) = 1;
        else
            y(i,1) = fidx(end);
        end
        fidx = find(fsi <= x(i,2));        
        y(i,2) = fidx(end);
    end
end