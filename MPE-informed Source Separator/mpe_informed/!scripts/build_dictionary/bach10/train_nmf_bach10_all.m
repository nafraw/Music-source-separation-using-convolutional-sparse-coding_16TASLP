clear;

settings(1).parname = 'dict_root_path';
settings(1).type = 'char';
settings(1).value = 'Z:/CSC_screening/dict/';

settings(end+1).parname = 'dict_train.stft.wlen';
settings(end).type = 'numeric';
settings(end).value = 4410;

settings(end+1).parname = 'dict_train.stft.hop';
settings(end).type = 'numeric';
settings(end).value = 2205;

param = train_nmf_bach10_default_setup(settings);
framework_bach10(param, mfilename, mfilename('fullpath')); % mfilename is the name of script