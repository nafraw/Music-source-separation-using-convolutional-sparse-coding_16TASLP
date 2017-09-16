function [maskD, partition_set] = mpe_informed_CSC_v3(param, fid, P, D, dict_sid, dict_pitch)
%  OUTPUT:
%    maskD: a cell with p-dim. Each cell is a vector for index of
%    extracting sub-dictionary for each partition.

display('Running the core algorithm......');
pnum = size(P, 2);
l = size(D, 1);
zp = zeros(l, 1); % zero padding
S = cell(pnum, 1);
%% read the mpe result (text)
meta = read_mpe(param.path_mpe_result{fid});
%% read pre-trained instrument recognition model
if param.algorithm.use_inst
    load(param.algorithm.inst_rec.dictionary);
    load(param.algorithm.inst_rec.svm_model);
    addpath(param.algorithm.ODLpath);
end
%% for each partition, perform ...
dnum = param.npart;
s = 0;
partition_set = zeros(2, dnum, pnum);
for pid = 1:pnum
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
    %% use instrument recognition
    if param.algorithm.use_inst
        %% Synthesis pseudo sound with NMF
        % spectrogram of each pitch = NMF(pitch, H0, param);
        [~, freq, p_stft] = cal_stft(P(:,pid), param.algorithm.stft);
        freq = freq(freq>=0);
        p_stft = squeeze(p_stft);
        % initialize the time activation matrix, H0, by either random or
        % MPE result
        if param.algorithm.NMF.randH0 % random
            H0 = rand(length(pitch), size(p_stft,2));
        else % use the MPE            
            MOI = meta(s_idx:e_idx,2:end); % Meta of Interest
            H0 = zeros(length(pitch), size(p_stft,2));
            for pitid = 1:length(pitch)
                [ind, ~] = ind2sub(size(MOI), find(MOI == pitch(pitid)));
                % index conversion (because the STFT setting may be
                % diffferent from the MPE setting)
                ind = convertIdx(ind, size(MOI,1), size(p_stft, 2));
                H0(pitid, ind) = rand(1,length(ind));
            end
        end
%         [W, H, ~] = algorithm_pitch_time_constr_NMF(abs(p_stft), pitch, H0, freq, param.algorithm.NMF);
        %% Apply prior knowledge of chorale with a voting mechanism
        A = sum(logical(H0));
        pitch_vote = zeros(length(pitch), param.npart);
        ind = find(A==param.npart);
        for idI = 1:length(ind)
            ind2 = find(H0(:,ind(idI)));
            for idP = 1:param.npart
                ins = param.npart - idP + 1;
                pitch_vote(ind2(idP), ins) = pitch_vote(ind2(idP), ins) + 1;
            end
        end
        %% Apply instrument recognition
%         % inst vector for each pitch = INST_REC(spectrogram of each pitch,
%         % pre_trained dictionary, param);
%         pseudo_spec = zeros(size(p_stft,1), size(p_stft,2), size(W, 2));
%         if param.algorithm.NMF.wiener
%             denom = W*H; % denominator
%             denom(denom==0) = inf;
%             for idPit = 1:size(W,2) % for each pitch
%                 pseudo_spec(:,:,idPit) = (W(:,idPit)*H(idPit,:)./denom).*abs(p_stft);
%             end
%         else % directly use W*H
%             for idPit = 1:size(W,2) % for each pitch
%                 pseudo_spec(:,:,idPit) = W(:,idPit)*H(idPit,:);
%             end
%         end
%         % instrument recognition
%         pitch_inst = zeros(size(W,2), 1);
%         % inst_decV = zeros(size(W,2), param.npart);
%         inst_decV = zeros(size(H,2), param.npart, size(W,2));
%         for idPit = 1:size(W,2) % for each pitch
% %             [pitch_inst(idPit), inst_decV(idPit,:)] = ...
% %                 Inst_Rec(pseudo_spec(:,:,idPit), D_inst, svm_model, param.algorithm.inst_rec);
%             [~, inst_decV(:,:,idPit)] = ...
%                 Inst_Rec(pseudo_spec(:,:,idPit), D_inst, svm_model, param.algorithm.inst_rec);
%         end
%         pitch_vote = pitch_vote + squeeze(sum(inst_decV, 1))';
% %         pitch_vote = pitch_vote + tmp;
%         %% Apply post processing for the result of recognition
%         % pitch_inst = INST_POST(decision value, param)
% %         pitch_inst = INST_POST(inst_decV);
        %% Thresholding
        pitch_vote = pitch_vote > param.algorithm.inst_rec.threshold;
    end
    %% extract sub dictionary
    idx_sub_D = [];
    idx_for_D = cell(dnum, 1);
    partition_set(1,1, pid) = 1;
    for did = 1:dnum % did = dictionary id (instrument)
        % used to determine how to seperate the sound
        if did~=1
            partition_set(1,did,pid) = partition_set(2,did-1,pid)+1;
        end
        % select atoms according to the pitch and/or instrument
        if ~isempty(pitch)
            if param.algorithm.use_inst % incorporate the information of instrument
%                 c = ismember(dict_pitch{did}, pitch(pitch_inst == did));
                c = ismember(dict_pitch{did}, pitch(pitch_vote(:,did)));
            else
                c = ismember(dict_pitch{did}, pitch);
            end
            idx_for_D{did} = find(c);
            clear c;
        else
            idx_for_D{did} = [];
        end
        idx_sub_D = [idx_sub_D; idx_for_D{did}+dict_sid(did)-1];
        % used to determine how to seperate the sound
        partition_set(2,did,pid) = partition_set(1,did,pid) + length(idx_for_D{did})-1;
        %if length(idx_for_D{did}) == 0
        if isempty(idx_for_D{did})
            partition_set(1,did,pid) = -1;
        end
    end
    clear idx_for_D;
    subD = D(:, idx_sub_D);
    maskD{pid} = idx_sub_D;
    %% run algorithm
    S{pid} = sparse(size(P,1), size(subD,2));
    hop = param.prob_partition.hop;
    len = param.prob_partition.dim_q;
%    if pid -1 > 0
%        pp = P(max(1, hop-l):hop-1,pid-1);
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
%    if pid + 1 <= pnum
%        lp = P(len-hop+1:max(l,len-hop+l),pid+1);
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
save(param.path_separation{fid}, 'S', 'optinf', 'maskD', '-v7.3');

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

function pitch_inst = INST_POST(decValue)
[m, n] = size(decValue);
k = floor(m/n); % at least how many pitch for an instrument should be assigned.
l = ceil(m/n);
r = mod(m, n);  % how many additional pitch to k can be assigned.
counter = ones(n, 1) * l;
pitch_inst = zeros(m, 1);
limit = 0;
for idP = 1:m
    M = max(max(decValue));
    [p, inst] = ind2sub(size(decValue), find(decValue == M));
    pitch_inst(p) = inst;
    decValue(p, :) = -Inf;
    counter(inst) = counter(inst) - 1;
    if counter(inst) == limit
        decValue(:, inst) = -Inf;
        r = r - 1;
        if r == 0 % when all additional quota used, set lower bound to 1
            limit = 1;
            % find the set that already reaches the limit
            set = find(counter == limit);
            decValue(:, set) = -Inf;
        end
    end
end
end