clear;

settings(1).parname = 'algorithm.initH';
settings(1).type = 'value';
settings(1).value = 0;

settings(end+1).parname = 'dict_name';
settings(end).type = 'char';
settings(end).value = 'RWC';

settings(end+1).parname = 'stft.wlen';
settings(end).type = 'numeric';
settings(end).value = 4410;

settings(end+1).parname = 'stft.hop';
settings(end).type = 'numeric';
settings(end).value = 2205;

settings(end+1).parname = 'reconstruct.post_wiener';
settings(end).type = 'numeric';
settings(end).value = 1;

settings(end+1).parname = 'prob_partition.dim_q';
settings(end).type = 'numeric';
settings(end).value = 11025;

settings(end+1).parname = 'dict_train.num_codeword_per_pitch'; 
settings(end).type = 'numeric'; 
% settings(end).value = 4;
% settings(end).value = 8;
settings(end).value = 12;

param = run_const_dict_NMF_bach10_default_setup(settings);
[SDR, SIR, SAR, SSperf] = ...
    framework_bach10(param, mfilename, mfilename('fullpath')); % mfilename is the name of script

