%% Partition problem
%  INPUT:
%    input_path: mat-file. What will be imported is a vector.
%    param: specify how will the file be partitioned.
%  OUTPUT:
%    P: q by p matrix. q is specified by param.
%    n: length of the audio.
%    k: length of zero-padded data.
%    w: mixture waveform.
function [P, n, k, w] = partition_problem_v2(input_path, param)
    w = importdata(input_path);
    n = length(w);
    if ~isempty(param.dim_q)       
        zero_pad = param.dim_q - mod(n, param.hop);
        data = [w; zeros(zero_pad,1)];
        p = 1;        
        s = 1;
        while s <= n            
            e = s + param.dim_q - 1;            
            P(1:param.dim_q, p) = data(s:e);
            p = p + 1;
            s = (p-1)*param.hop+1;
        end
        k = length(data); % length of data after zero padding
    else        
        P = w;
        k = n;
        dim_q = length(P);
    end
end
