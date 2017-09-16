%% Partition problem
%  INPUT:
%    input_path: mat-file. What will be imported is a vector.
%    param: specify how will the file be partitioned.
%  OUTPUT:
%    P: q by p matrix. q is specified by param.
%    zero_pad: number of zero padded for the last column in P.
function [P, zero_pad, dim_q] = partition_problem(input_path, param)
    data = importdata(input_path);    
    if ~isempty(param.dim_q)
        zero_pad = mod(length(data), param.dim_q);
        if zero_pad ~= 0
            zero_pad = param.dim_q - zero_pad;
        end
        P = reshape([data; zeros(zero_pad, 1)], param.dim_q, []);
        dim_q = param.dim_q;
    else
        zero_pad = 0;
        P = data;
        dim_q = length(P);
    end
end
