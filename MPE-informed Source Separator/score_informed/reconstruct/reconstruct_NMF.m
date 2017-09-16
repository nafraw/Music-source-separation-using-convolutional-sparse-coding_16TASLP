%% reconstruction
%  INPUT:
%    D: an m by n matrix, dictionary.
%    maskD: a cell with p-dim. Each cell is a vector for index of
%    extracting sub-dictionary for each partition.
%    S_input_path: a file that has an t by n by p tensor, coefficient map.
%    norm_ratio, a p-dimensional vector. The ratio used in normalizing.
%    original time signal.
%    partition_set: this is a 2 by k by p matrix such that the source will be
%    separated into k channels for each partition.
%  OUTPUT:
%    R: a t*k matrix.
function [R] = reconstruct_NMF(output_path, sampling_rate, stft, ...
                                       zero_pad, S_input_path, ...
                                       norm_ratio, param)
    %% read W, H, and inst_id
    stru = importdata(S_input_path);
    W = stru.W;
    H = stru.H;
    inst_id = stru.inst_id;
    clear stru;
    p = size(stft, 1);
    R = [];
    
    %% reconstruct method flag
    if ~isfield(param, 'post_wiener')
        wiener = 0;
    else
        wiener = param.post_wiener;
    end
    for pid = 1:p
        %% reconstruct from dictionary and coefficient        
        if pid ~= p
            nsample = param.dim_q;
        else
            nsample = param.dim_q - zero_pad;
        end
        if wiener
            rec = wiener_reconstruct_from_NMF(W{pid}, H{pid}, inst_id{pid}, nsample, ...
                squeeze(stft(pid,:,:)), norm_ratio(pid), param.hop);
        else
            rec = direct_reconstruct_from_NMF(W{pid}, H{pid}, inst_id{pid}, nsample, ...
                squeeze(stft(pid,:,:)), norm_ratio(pid), param.hop);
        end
        
        R = [R; rec];
        clear rec;
    end
    %% save as a file or files    
    [folder, file, ext] = fileparts(output_path);
    if ~exist(folder, 'dir')
        mkdir(folder);
    end
    wavwrite(sum(R,2), sampling_rate, output_path);
    k = size(R, 2);
    for kid = 1:k
        if k == 1
            wavwrite(R, sampling_rate, output_path);
        else
            output_path = [folder, '/', file, '_channel_', num2str(kid), ext];
            wavwrite(R(:,kid), sampling_rate, output_path);
        end
    end
end