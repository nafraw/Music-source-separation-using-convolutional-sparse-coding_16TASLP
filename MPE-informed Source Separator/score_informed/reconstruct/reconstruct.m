%% reconstruction
%  INPUT:
%    D: an m by n matrix, dictionary.
%    S_input_path: a file that has an t by n by p tensor, coefficient map.
%    norm_ratio, a p-dimensional vector. The ratio used in normalizing.
%    original time signal.
%    partition_set: this is a 2 by k matrix such that the source will be
%    separated into k channels.
%  OUTPUT:
%    R: a t*k matrix.
function [R] = reconstruct(output_path, sampling_rate, D, S_input_path, norm_ratio, partition_set)
    %% read S
    stru = importdata(S_input_path);
    %% reconstruct from dictionary and coefficient    
    [R] = reconstruct_signal(D, stru.S, stru.zero_pad, norm_ratio, partition_set);
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