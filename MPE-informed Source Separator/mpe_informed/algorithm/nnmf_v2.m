function [W, H, err] = nnmf_v2(V, W0, H0, r, iterations, errcrit, fixW)
%NNMF - non-negative matrix factorization
%
% [W, H] = nnmf(V, r, iterations)
%
% Input:
%   V   - the matrix to factorize
%   W0  - initial value of W;
%   H0  - initial value of H;
%   r   - number of basis vectors to generate
%   iterations - number of EM iterations to perform
%
% Results:
%   W   - a set of r basis vectors
%   H   - represenations of the columns of V in 
%         the basis given by W
%
%   Revised by: Ping-Keng Jao from the version below:
%   https://sites.google.com/site/chengbinp/misc/matlabcodeformultiplicativenmfalgorithm
%   Revised by: Chengbin Peng
%   Follows: D.D. Lee & H.S. Seung, "Algorithms for Non-negative 
%               Matrix Factorization", NIPS, 2000
%   Description: This is a modification of David Ross's work by   
%               following a different paper. Within the same iteration
%               number, current algorithm can typically converge with
%               a much smaller error. Frobenius norm instead of 2 norm is
%               used for faster error evaluation.



%---------------------------------------
% check the input
%---------------------------------------
% error(nargchk(3,3,nargin));
error(nargchk(7,7,nargin));

if ndims(V) ~= 2
    error('V must have exactly 2 dimensions');
end

if prod(size(r)) ~= 1 | r < 1
    error('r must be a positive scalar');
end

if prod(size(iterations)) ~= 1 | iterations < 1 
    error('number of iterations must be a positive scalar');
end

%---------------------------------------
% Initialization
%---------------------------------------

N = size(V,1); % dimensionality of examples (# rows)
C = size(V,2); % number of examples (columns)

% W = 2 * rand(N,r);
W = W0;
% H = 2 * rand(r,C);
% H = 2 * ones(r,C);
H = H0;

err = zeros(iterations,1);

%---------------------------------------
% EM
%---------------------------------------

for it_number = 1:iterations
%     disp(num2str(it_number));
    
    %% E-Step
    if ~fixW
        W = W .* (V * H')./(W*H*H' + eps);
        W = W ./ repmat(sum(W,1), [N 1]);
    end
    
    %% M-Step
    H = H .* (W' * V)./(W'*W*H + eps);
    if strcmpi(errcrit, 'KL')
        err(it_number) = sum(KLDiv(V, W*H));
    elseif strcmpi(errcrit, 'Fro')
        err(it_number) = norm(V - W*H, 'fro');
    else
        error('Unknown criterion for NMF');
    end
    
end

% plot(err);
% disp(num2str(err(end)));