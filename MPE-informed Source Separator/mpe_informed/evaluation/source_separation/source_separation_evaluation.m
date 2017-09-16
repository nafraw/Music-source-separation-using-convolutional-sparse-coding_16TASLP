function [score] = source_separation_evaluation(se, path_original, fid)
%  INPUT:
%    se (R): a t by k matrix, estimated sources (k).
%    path_original: fid*k paths which contains separated sources.
%    fid: the for-loop index for determination of start index of
%    path_original.
%  OUTPUT:
%    score: a struct.

% number of source
k = size(se, 2); 
% read golden source
start_idx = (fid-1)*k;
for i=1:k
    s(:,i) = importdata(path_original{start_idx+i});
end
% calculate matching score
[SDR,SIR,SAR,perm]=bss_eval_sources(se',s');
% assign the result to score.
score.SDR = SDR;
score.SIR = SIR;
score.SAR = SAR;
score.perm = perm;
end