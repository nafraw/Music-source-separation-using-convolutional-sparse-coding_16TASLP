function [maskD, partition_set] = score_informed_CSC_v3(param, fid, P, D, dict_sid, pitch)
%  OUTPUT:
%    maskD: a cell with p-dim. Each cell is a vector for index of
%    extracting sub-dictionary for each partition.

display('Running the core algorithm......');
pnum = size(P, 2);
l = size(D, 1);
zp = zeros(l, 1); % zero padding
S = cell(pnum, 1);
%% read the score (text)
meta = importdata(param.path_score{fid});
%% set onset/offset from the meta
if strcmpi(param.offset_define, 'txt')
%     ind = find(meta_smsec > meta_emsec);
    ind = find(meta(:,1) > meta(:,2));
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

% if ~isfield(param, 'fold') % if this is one fold only
%     dnum = length(param.path_dict);
% else % more than one fold
%     dnum = size(param.path_dict, 2);
% end
dnum = param.npart;
%% for each partition, perform ...
s = 0;
for pid = 1:pnum
    s_msec = (s/param.pre_process.sampling_rate) * 1000;
    e_msec = ((s+param.prob_partition.dim_q)/param.pre_process.sampling_rate) * 1000;
    %% extract sub dictionary
    idx_sub_D = [];
    partition_set(1,1, pid) = 1;
    for did = 1:dnum
        % used to determine how to seperate the sound
        if did~=1
            partition_set(1,did,pid) = partition_set(2,did-1,pid)+1;
        end
        % find the used pitch and corresponding dictionary index in D
        idx_ins = find(meta(:,4) == did);
        meta_smsec = meta(idx_ins, 1);
        meta_emsec = meta(idx_ins, 2);
%         meta_smsec = meta(idx_ins, 1); % onset (in msec) of meta data
%         meta_emsec = meta_smsec(2:end);
%         meta_emsec(end+1) = inf;
        % check which pitch overlaps between the region [s_msec, e_msec].
        [overlap] = check_overlap(s_msec, e_msec, meta_smsec, meta_emsec);
        
        used_pitch = unique(sort(meta(idx_ins(overlap), 3)));
        if ~isempty(used_pitch)
            c = ismember(pitch{did}, used_pitch);
            idx_for_D{did} = find(c);
            clear c;
        else
            idx_for_D{did} = [];
        end
        idx_sub_D = [idx_sub_D; idx_for_D{did}+dict_sid(did)-1];
        % used to determine how to seperate the sound
        partition_set(2,did,pid) = partition_set(1,did,pid) + length(idx_for_D{did})-1;
        if length(idx_for_D{did}) == 0
            partition_set(1,did,pid) = -1;
        end
    end
    clear idx_for_D;
    subD = D(:, idx_sub_D);
    maskD{pid} = idx_sub_D;
    %% run algorithm
    S{pid} = sparse(size(P+2*l,1), size(subD,2));
    hop = param.prob_partition.hop;
    len = param.prob_partition.dim_q;
    if pid -1 > 0
        %pp = P(max(1, hop-l):hop-1,pid-1);		
		needSample = l;
		curP = 1;
		pp = [];
		while needSample ~= 0
			startIdx = max(1, hop-needSample);
			if pid - curP > 0
				pp = [pp; P(startIdx: hop-1,pid-curP)];
			else
				pp = [pp; zeros(needSample, 1)];
			end
			curP = curP + 1;
			needSample = l - length(pp);
		end		
    else
        pp = zp;
    end
    if pid + 1 <= pnum
	% lp = P(len-hop+1:max(l,len-hop+l),pid+1);
		needSample = l;
		curP = 1;
		lp = [];
		while needSample ~= 0
			endIdx = min(len, needSample-hop+l);
			if pid + curP <= pnum
				lp = [lp; P(len-hop+1: endIdx,pid+curP)];
			else
				lp = [lp; zeros(needSample, 1)];
			end
			curP = curP + 1;
			needSample = l - length(lp);
		end
    else
        lp = zp;
    end
    [S{pid}, optinf] = algorithm_CSC_SISS([pp; P(:,pid); lp], subD, param.algorithm);
    s = s + param.prob_partition.hop;
end
%% save result
display(['Saving the result of core algorithm......']);
check_path(param.path_separation{fid});
save(param.path_separation{fid}, 'S', 'optinf', 'maskD', 'partition_set', '-v7.3');

end

function [overlap] = check_overlap(start_ref, end_ref, start_point, end_point)
    overlap = (end_ref >= start_point) & (end_point >= start_ref);
end