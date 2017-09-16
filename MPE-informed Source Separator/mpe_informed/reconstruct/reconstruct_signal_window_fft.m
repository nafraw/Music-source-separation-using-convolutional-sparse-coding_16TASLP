%% reconstruction of 1D signal
%  INPUT:
%    D: an m by n matrix, dictionary.
%    S: an t by n matrix, coefficient map.
%    zero_pad: number of element need to be discarded for the last
%    partition.
%    norm_ratio, a scalar. The ratio used in normalizing
%    original time signal.
%    partition_idx: this is a 2 by k matrix such that the source will be
%    separated into k channels.
%  OUTPUT:
%    R: a t by k matrix.
function [R] = reconstruct_signal_window_fft(D, S, zero_pad, norm_ratio, partition_set)
    [p] = length(S);
    [t, n] = size(S);
%     m = size(D,1);
    k = size(partition_set, 2);
    % the commented conv_length is the length of conv function, but in the
    % target application, we only need t dimension.
%     conv_length = max([m+t-1, m, t]);
    conv_length = t;
    R = zeros(t-zero_pad, k);    
    % for each codeword
    parfor j=1:n
%         C(:,j) = conv(D(:,j), full(S(:,j)));
        C(:,j) = ifft((fft(D(:,j), size(S(:,j), 1)) .* fft(full(S(:,j)))), 'symmetric');
    end
    start_id = 1;
    for kid = 1:k
        if partition_set(1,kid) == -1
            R(start_id: start_id+conv_length-1-zero_pad, kid) = zeros(conv_length-zero_pad,1);
            continue;
        end
        R(start_id: start_id+conv_length-1-zero_pad, kid) = ...
            sum(C(1:conv_length-zero_pad, partition_set(1, kid):partition_set(2, kid)), 2).*norm_ratio;
    end    
end