settings(1).parname = 'dict_root_path';
settings(1).type = 'char';
settings(1).value = 'Z:/MPE-informed/dict/';

settings(2).parname = 'dict_train.num_codeword_per_pitch';
settings(2).type = 'numeric';
settings(2).value = 4;

settings(3).parname = 'dict_train.norm_train';
settings(3).type = 'numeric';
settings(3).value = 1;

settings(4).parname = 'dict_train.lambda';
settings(4).type = 'numeric';
settings(4).value = 0.0001;

param = train_supervised_rwc_default_setup(settings);
framework_rwc(param, mfilename, mfilename('fullpath')); % mfilename is the name of script