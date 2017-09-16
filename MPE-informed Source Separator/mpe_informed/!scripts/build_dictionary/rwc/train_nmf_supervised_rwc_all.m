clear;

settings(1).parname = 'dict_root_path';
settings(1).type = 'char';
settings(1).value = 'Z:/MPE-informed Source Separator/nmf_dict/';

settings(end+1).parname = 'dict_train.num_codeword_per_pitch';
settings(end).type = 'numeric';
% settings(end).value = 4;
% settings(end).value = 8;
settings(end).value = 12;

settings(end+1).parname = 'dict_train.stft.wlen';
settings(end).type = 'numeric';
settings(end).value = 4410;

settings(end+1).parname = 'dict_train.stft.hop';
settings(end).type = 'numeric';
settings(end).value = 2205;

param = train_nmf_supervised_rwc_default_setup(settings);
framework_rwc(param, mfilename, mfilename('fullpath')); % mfilename is the name of script