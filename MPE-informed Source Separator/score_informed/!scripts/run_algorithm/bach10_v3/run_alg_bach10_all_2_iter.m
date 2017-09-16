clear;

settings(1).parname = 'algorithm.lambda';
settings(1).type = 'numeric';
settings(1).value = '0.001';

settings(end+1).parname = 'algorithm.opt.MaxMainIter';
settings(end).type = 'numeric';
settings(end).value = '1';

settings(end+1).parname = 'prob_partition.dim_q';
settings(end).type = 'numeric';
settings(end).value = '11025';

param = run_alg_bach10_default_setup(settings);
framework_bach10(param, mfilename, mfilename('fullpath')); % mfilename is the name of script