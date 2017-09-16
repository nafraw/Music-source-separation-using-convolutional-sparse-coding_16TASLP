%% Normalize function
%  This function normalize input according to their length
%  L2-norm is used by default
%  INPUT:
%    X: an m by n matrix.
%  OUTPUT:
%    Y: an m by n matrix.
%    ratio: a vector with length n where each element indicates the
%    normalized factor of corresponding vector in X
function [Y, ratio] = normalization(X)
    n = size(X, 2);
    Y = zeros(size(X));
    parfor i=1:n
        ratio(i,1) = sqrt(X(:,i)'*X(:,i));
        if ratio(i,1) ~= 0 % otherwise, set to all zero by default
            Y(:,i) = X(:,i)./ratio(i,1);
        end
    end    
end