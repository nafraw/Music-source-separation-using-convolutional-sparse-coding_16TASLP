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
function [R] = reconstruct_window_wise(output_path, sampling_rate, D, maskD, ...
                                       S_input_path, norm_ratio, partition_set, ...
                                       param)
    %% read S
    stru = importdata(S_input_path);
    if isempty(maskD)
        maskD = stru.maskD;
    end
    p = size(partition_set, 3);
    R = [];
    for pid = 1:p
        %% reconstruct from dictionary and coefficient
        subD = D(:, maskD{pid});
        if pid ~= p
            zp = 0;
        else
            zp = stru.zero_pad;
        end        
        if ~isfield(param, 'fft')
            [rec] = reconstruct_signal_window(subD, stru.S{pid}, zp, ...
                                 norm_ratio(pid), partition_set(:,:,pid));
        else
            if param.fft == 0
                [rec] = reconstruct_signal_window(subD, stru.S{pid}, zp, ...
                    norm_ratio(pid), partition_set(:,:,pid));
            else
                [rec] = reconstruct_signal_window_fft(subD, stru.S{pid}, zp, ...
                    norm_ratio(pid), partition_set(:,:,pid));
            end
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
    k = size(partition_set, 2);
    for kid = 1:k
        if k == 1
            wavwrite(R, sampling_rate, output_path);
        else
            output_path = [folder, '/', file, '_channel_', num2str(kid), ext];
            wavwrite(R(:,kid), sampling_rate, output_path);
        end
    end
end