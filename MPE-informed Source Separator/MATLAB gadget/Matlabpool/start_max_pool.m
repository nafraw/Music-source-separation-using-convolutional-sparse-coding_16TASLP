%  Author: Ping-Keng Jao
%  Release date: 2014/06/20
%  This function initiates the maximum avaliable number for parfor while no
%  argument specified. With a specified number, this function will initiate
%  specified number of parfor, but of course cannot exceed the maximum
%  avaliable number.
%  This function will NOT close current pool when current pool size is
%  equal to the desired size.
%
function start_max_pool(custom_max)
% The custom max is the maximum number specified by user.
% In other words, when it is set to 2, the pool size will be 2 while the
% maximum avaliable size is larger than 2.
if nargin < 1 custom_max = 9999999; end

max_pool_worker = min(custom_max, max_pool);
cur_pool_size = matlabpool('size');
if cur_pool_size == 0
    matlabpool('open', max_pool_worker);
elseif cur_pool_size ~= max_pool_worker
    matlabpool('close');
    matlabpool('open', max_pool_worker);
end

end
