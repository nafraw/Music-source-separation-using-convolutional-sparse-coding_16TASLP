%% Convolutional Sparse Coding based Score-informed Source Separation
%  This algorithm is based on the code of Brendt Wohlberg
%  You can find Brendt's CSC algotihm in
%    Brendt Wohlberg, Efficient Convolutional Sparse Coding, ICASSP, 2014.
%  INPUT:
%    out_path: The result will be saved at specified path and name.
%    X: a vector, the target signal to be approximated.
%    D: an m by n matrix, dictionary.
%    param: the parameter for CSC.
%  OUTPUT:
%    S: an n by t by p tensor, coefficient map.

function [S, optinf] = algorithm_CSC_SISS(X, D, param)
    %% reshape dictionary as original CSC was coded for 2-D image
    rD = reshape(D, [size(D,1), 1, size(D, 2)]);    
    %% run the algorithm
    if isfield(param, 'opt')        
        [s, optinf] = cbpdn_v2(rD, X, param.lambda, param.opt);
%         [s, optinf] = cbpdn_more_observation(rD, X, param.lambda, param.opt);
    else        
        [s, optinf] = cbpdn_v2(rD, X, param.lambda);
%         [s, optinf] = cbpdn_more_observation(rD, X, param.lambda);
    end
    S = reshape(s, length(X), size(D,2));
    S = sparse(S);
end