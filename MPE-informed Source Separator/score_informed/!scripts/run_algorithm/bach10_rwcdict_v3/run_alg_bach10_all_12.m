settings(1).parname = 'algorithm.lambda';
settings(1).type = 'numeric';
settings(1).value = '0.00001';

settings(end+1).parname = 'dict_train.num_codeword_per_pitch';
settings(end).type = 'numeric';
settings(end).value = '9';

% settings(end+1).parname = 'algorithm.opt.MaxMainIter';
% settings(end).type = 'numeric';
% settings(end).value = '10';

param = run_alg_bach10_default_setup(settings);
framework_bach10(param, mfilename, mfilename('fullpath')); % mfilename is the name of script