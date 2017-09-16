clear;

settings(1).parname = 'norm_audio';
settings(1).type = 'numeric';
settings(1).value = '0';

param = run_const_NMF_bach10_default_setup(settings);
framework_bach10(param, mfilename, mfilename('fullpath')); % mfilename is the name of script