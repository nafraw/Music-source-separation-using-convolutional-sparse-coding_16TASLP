%  Author: Ping-Keng Jao
%  Release date: 2014/06/20
%  This function simply output the maximum avaliable pool number which is 
%  supported by your MATLAB. Different approaches were implemented for 
%  different MATLAB version.
function max_pool_worker = max_pool

v = version('-release');
v = str2num(v(1:4));
if v >= 2013
    defaultProfile = parallel.defaultClusterProfile;
    myCluster = parcluster(defaultProfile);
    numWorkers = myCluster.NumWorkers;
else
    schd = findResource('scheduler', 'configuration', 'local');
    numWorkers = schd.ClusterSize;
end

n_core = feature('numCores');
max_pool_worker = min(numWorkers, n_core);
end
