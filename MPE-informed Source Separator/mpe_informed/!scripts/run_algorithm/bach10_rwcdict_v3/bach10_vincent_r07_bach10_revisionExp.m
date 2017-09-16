clear;

settings(1).parname = 'algorithm.lambda';
settings(1).type = 'numeric';
settings(1).value = '0.0001';

settings(end+1).parname = 'prob_partition.dim_q';
settings(end).type = 'numeric';
settings(end).value = '11025';

settings(end+1).parname = 'algorithm.opt.MaxMainIter';
settings(end).type = 'numeric';
settings(end).value = '250';

settings(end+1).parname = 'path_mpe_result';
settings(end).type = 'char';
settings(end).value = 'Z:/MPE-informed Source Separator/dataset/Bach10/Bach-4/MPE_result/Vincent_21/';

param = run_alg_bach10_default_setup(settings);
framework_bach10(param, mfilename, mfilename('fullpath')); % mfilename is the name of script