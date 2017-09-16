settings(1).parname = 'dict_root_path';
settings(1).type = 'char';
settings(1).value = 'Z:/CSC_screening/dict/';

% settings(end+1).parname = 'dict_train.dict_type';
% settings(end).type = 'char';
% settings(end).value = 'supervised_more_codeword_no_concatenate';

param = train_bach10_default_setup(settings);
framework_bach10(param, mfilename, mfilename('fullpath')); % mfilename is the name of script