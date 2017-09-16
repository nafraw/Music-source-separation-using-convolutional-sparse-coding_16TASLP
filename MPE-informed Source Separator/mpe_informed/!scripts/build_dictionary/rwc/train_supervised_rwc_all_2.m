settings(1).parname = 'dict_root_path';
settings(1).type = 'char';
settings(1).value = 'Z:/MPE-informed/dict/';

settings(end+1).parname = 'dict_train.dict_type';
settings(end).type = 'char';
settings(end).value = 'supervised_more_codeword_no_concatenate';

settings(end+1).parname = 'dict_train.num_codeword_per_pitch';
settings(end).type = 'numeric';
settings(end).value = 8;

param = train_supervised_rwc_default_setup(settings);
framework_rwc(param, mfilename, mfilename('fullpath')); % mfilename is the name of script