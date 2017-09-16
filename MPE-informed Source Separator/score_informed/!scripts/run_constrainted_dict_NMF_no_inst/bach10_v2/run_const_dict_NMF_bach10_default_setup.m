function param = param_setup(settings)
if ~exist('settings', 'var')
    settings = [];
end
%% fold setting
param.test_fold{1} = 1:10;
%% instrument setting
param.part_name = {'Violin', 'Clarinet', 'Saxophone', 'Bassoon'};
param.npart = length(param.part_name);

%% target setting
if isunix
%     root_path ='~/NAS/NAS_home/Bach10/Bach-1/source/';
% 	dict_root_path = '~/NAS/NAS_home/Bach10/dictionary/';
% 	mount_path = '~/NAS/NAS_home';
else
    root_path = 'Y:/Bach10/Bach-1/source/';
    dict_root_path = 'Z:/MPE-informed Source Separator/nmf_dict/';
    mount_path = 'Z:/';
end
param.rootpath_train_corpus = '/MPE-informed Source Separator/dataset/Bach10/traindata_dict/';

% note: must specify to pre-processed files (so the format could be the
% same).
param.path_target_corpus = [mount_path, 'MPE-informed Source Separator/dataset/Bach10/Bach-4/pre_process/mixed/'];
param.path_target_separated_corpus = [mount_path, ...
     'MPE-informed Source Separator/dataset/Bach10/Bach-4/pre_process/separated/'];
param.target_ext = '*.mat';
param.path_score = [mount_path, 'MPE-informed Source Separator/dataset/Bach10/Bach-4/mixed/'];
%% paths for output
% the path for saving screening and CSC result
param.path_separation = [mount_path, 'expResult/MPE-informed Source Separator/score_informed_no_inst_dict_NMF_v2/algorithm/'];
% the path for saving performance
param.path_perf = [mount_path, 'expResult/MPE-informed Source Separator/score_informed_no_inst_dict_NMF_v2/perf/'];
% the path for saving reconstruction result
param.path_recon = [mount_path, 'expResult/MPE-informed Source Separator/score_informed_no_inst_dict_NMF_v2/reconstruction/'];
% the path for saving the data to be sent via email
param.path_sendData = [mount_path, 'expResult/MPE-informed Source Separator/score_informed_no_inst_dict_NMF_v2/sendData/'];

%% dictionary training (building) process, used for automatic generation of dictionary naming
param.dict_train.dict_type =  'supervised_more_codeword';
param.dict_train.num_codeword_per_pitch = 4; % number of codeword to represent a pitch

%% Pre-process setting
param.pre_process.sampling_rate = 44100;
%% Algorithm settings
param.dict_name = 'Bach10'; % BACH10 or RWC
param.norm_dict = 1;
param.norm_audio = 0;
param.prob_partition.dim_q = param.pre_process.sampling_rate; % use [] when not intended to partition.
                                 % it is suggested to specify the length
                                 % based on sampling rate (for time-domain
                                 % feature).
param.prob_partition.hop = floor(param.pre_process.sampling_rate*0.5);
    %% Spectrogram
    param.stft.fs = param.pre_process.sampling_rate;
    param.stft.wlen = 4097;
    param.stft.hop  = 2048;
    %% NMF
    param.run_algorithm = 1;
    param.algorithm.fixW = 1;
    param.algorithm.initW = 0;
    param.algorithm.initH = 0;
    param.algorithm.iteration = 500;
    param.algorithm.error_criterion = 'KL'; % KL, default is Frobenius norm
	
    param.offset_define = 'next_onset';
    % option: 'next_onset', 'txt'
%% reconstruction parameter
param.reconstruct.hop = param.prob_partition.hop;
param.reconstruct.post_wiener = 0;
param.reconstruct.stft.wlen = param.stft.wlen;
param.reconstruct.stft.hop = param.stft.hop;
%% assign value according to input
for i = 1:length(settings)
    if iscell(settings(i).value)        
        eval(['temp' '=', '''', settings(i).value, ''';']);
        % assume cell is one-dimension only
        v = '';
        for i=1:length(temp)
            v = strcat(v, temp{i}); 
        end
        eval(['param.' settings(i).parname, '=', '''', v, ''';']);
        clear temp v;
    elseif ischar(settings(i).value)
        if strcmp(settings(i).type, 'char')
            eval(['param.' settings(i).parname, '=', '''', settings(i).value, ''';']);
        elseif strcmp(settings(i).type, 'numeric')
            eval(['param.' settings(i).parname, '=', '', settings(i).value, ';']);
        else
            error('unknown settings(i).type');
        end
    else % not char, it should be a numeric value, and ASSUME AT MOST A ONE-DIM VECTOR
        eval(['param.' settings(i).parname, '=[', num2str(settings(i).value), '];']);
    end
end
if isempty(param.algorithm.error_criterion)
    param.algorithm.error_criterion = 'Fro';
end
%% Auto naming and some auto settings
param.npart = length(param.part_name);
param.reconstruct.stft.hop = param.stft.hop;
param.prob_partition.hop = floor(param.prob_partition.dim_q*0.5);
param.algorithm.nPitch = param.dict_train.num_codeword_per_pitch;
param.reconstruct.npart = param.npart;
param.reconstruct.hop = param.prob_partition.hop;
param.reconstruct.stft.wlen = param.stft.wlen;


for fold = 1:length(param.test_fold)
    for inst = 1:length(param.part_name)     
        %% naming
        param.path_dict{fold, inst} = [dict_root_path, param.dict_train.dict_type, '_', ...
            num2str(param.dict_train.num_codeword_per_pitch), 'NMF_', param.dict_name, ...
            '_', param.part_name{inst}, '_wlen_', num2str(param.stft.wlen),...
            '_hop_', num2str(param.stft.hop), '_fold', num2str(fold), '.mat'];
    end
end

%% Auto naming and some auto settings
param.npart = length(param.part_name);
if ~isfield(param, 'exp_name')
    if isempty(param.prob_partition.dim_q)
        param.exp_name = ['no_parti'];
    else
        param.exp_name = [...
            'partiSize_', num2str(param.prob_partition.dim_q)];
    end
    param.exp_name = [param.exp_name, '_', param.dict_name];
    param.exp_name = [param.exp_name, '_wlen_', num2str(param.stft.wlen)];
    param.exp_name = [param.exp_name, '_hop_', num2str(param.stft.hop)];
	param.exp_name = [param.exp_name, '_offsetDef_', param.offset_define];
    param.exp_name = [param.exp_name, '_normD_', num2str(param.norm_dict)];
    param.exp_name = [param.exp_name, '_normAud_', num2str(param.norm_audio)];
    param.exp_name = [param.exp_name, '_NMFcrit_', param.algorithm.error_criterion];
    param.exp_name = [param.exp_name, '_NMFiter_', num2str(param.algorithm.iteration)];
    param.exp_name = [param.exp_name, '_WF_', num2str(param.reconstruct.post_wiener)];
end
if isfield(param, 'exp_name_prefix')
    param.exp_name = [param.exp_name_prefix, param.exp_name];
end
if isfield(param, 'exp_name_postfix')
    param.exp_name = [param.exp_name, param.exp_name_postfix];
end

param.path_separation = [param.path_separation, param.exp_name, '/'];
param.path_perf       = [param.path_perf, param.exp_name, '/'];
param.path_recon      = [param.path_recon, param.exp_name, '/'];
param.path_sendData   = [param.path_sendData, param.exp_name, '/'];

end % end of function