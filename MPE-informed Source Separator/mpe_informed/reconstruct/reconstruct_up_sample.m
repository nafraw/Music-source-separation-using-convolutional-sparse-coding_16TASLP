%% reconstruction with up sample
%  INPUT:
%    D: an m by n matrix, dictionary.
%    S_input_path: a file that has an t by n by p tensor, coefficient map.
%    norm_ratio, a p-dimensional vector. The ratio used in normalizing
%    original time signal.
%    new_sampling_rate: sampling rate after up sample.
%    original_sampling_rate: sampling rate before up sample.
%    param: up sample parameter.
%    partition_set: this is a 2 by k matrix such that the source will be
%    separated into k channels.
%  OUTPUT:
%    R: a t*p vector.
function [R] = reconstruct_up_sample(output_path, D, S_input_path, norm_ratio, ...
                                     new_sampling_rate, original_sampling_rate,...
                                     param, partition_set)
    %% read S
    stru = importdata(S_input_path);    
    %% reconstruct from dictionary and coefficient
    [R] = reconstruct_signal(D, stru.S, stru.zero_pad, norm_ratio, partition_set);
    %% resample to new sampling rate
    % default : y = resample(x, p, q)
    % FIR     : y = resample(x, p, q, n)
    % Kaiser  : y = resample(x, p, q, n, beta)
    % hand    : y = resample(x, p, q, b), b is a vector
    switch lower(param.filter_type)
        case 'default'
            [R] = resample(R, new_sampling_rate, original_sampling_rate);
        case 'fir'
            [R] = resample(R, new_sampling_rate, original_sampling_rate, ...
                           param.filter_order);
        case 'kaiser'
            [R] = resample(R, new_sampling_rate, original_sampling_rate, ...
                           param.filter_order, param.filter_beta);
        case 'hand'
            [R] = resample(R, new_sampling_rate, original_sampling_rate, ...
                           param.reconstruct.filter_coefficient);
        otherwise
            error('Unknown resample type');
    end
    %% save result as a file
    [folder, file, ext] = fileparts(output_path);
    if ~exist(folder, 'dir')
        mkdir(folder);
    end
    wavwrite(sum(R,2), new_sampling_rate, output_path);
    k = size(partition_set, 2);
    for kid = 1:k
        if k == 1
            wavwrite(R, new_sampling_rate, output_path);
        else
            output_path = [folder, '/', file, '_channel_', num2str(kid), ext];
            wavwrite(R(:,kid), new_sampling_rate, output_path);
        end
    end
    
end