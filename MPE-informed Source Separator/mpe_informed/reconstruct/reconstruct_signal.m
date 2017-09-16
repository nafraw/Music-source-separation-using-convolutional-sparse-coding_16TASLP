%% reconstruction of 1D signal
%  INPUT:
%    D: an m by n matrix, dictionary.
%    S: an t by n by p tensor (for some reason, a cell with p t by n 
%    matrices, coefficient map.
%    zero_pad: number of element need to be discarded for the last
%    partition.
%    norm_ratio, a p-dimensional vector. The ratio used in normalizing
%    original time signal.
%    partition_idx: this is a 2 by k matrix such that the source will be
%    separated into k channels.
%  OUTPUT:
%    R: a t by k matrix.
function [R] = reconstruct_signal(D, S, zero_pad, norm_ratio, partition_set)
    [p] = length(S);
    [t, n] = size(S{1});
%     m = size(D,1);
    k = size(partition_set, 2);
    % the commented conv_length is the length of conv function, but in the
    % target application, we only need t dimension.
%     conv_length = max([m+t-1, m, t]);
    conv_length = t;
    R = zeros(conv_length*p-zero_pad, k);
    % for each partition
    for i=1:p
        % for each codeword
        parfor j=1:n
            C(:,j) = conv(D(:,j), full(S{i}(:,j)));
        end
        start_id = 1+conv_length*(i-1);
        for kid = 1:k
            if partition_set(1,kid) == -1
                R(start_id: start_id+conv_length-1, kid) = zeros(conv_length,1);
                continue;
            end
            if i~=p
                R(start_id: start_id+conv_length-1, kid) = ...
                    sum(C(1:conv_length, partition_set(1, kid):partition_set(2, kid)), 2).*norm_ratio(i);
            else
                R(start_id: start_id+conv_length-1-zero_pad, kid) = ...
                    sum(C(1:conv_length-zero_pad, partition_set(1, kid):partition_set(2, kid)), 2).*norm_ratio(i);
            end
        end
    end
end