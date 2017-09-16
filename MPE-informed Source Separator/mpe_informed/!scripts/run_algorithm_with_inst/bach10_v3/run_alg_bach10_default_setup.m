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
    dict_root_path = 'Z:/MPE-informed Source Separator/dict/no_fold/';
    mount_path = 'Z:/';
end
param.rootpath_train_corpus = '/MPE-informed Source Separator/dataset/Bach10/traindata_dict/';

% note: must specify to pre-processed files (so the format could be the
% same).
param.path_target_corpus = [mount_path, 'MPE-informed Source Separator/dataset/Bach10/Bach-4/pre_process/mixed/'];
param.path_target_separated_corpus = [mount_path, ...
     'MPE-informed Source Separator/dataset/Bach10/Bach-4/pre_process/separated/'];
param.target_ext = '*.mat';
param.path_mpe_result = [mount_path, 'MPE-informed Source Separator/dataset/Bach10/Bach-4/MPE_result/LiSu/'];
%% paths for output
% the path for saving screening and CSC result
param.path_separation = [mount_path, 'expResult/MPE-informed Source Separator/mpe_instr_informed_v3/algorithm/'];
% the path for saving performance
param.path_perf = [mount_path, 'expResult/MPE-informed Source Separator/mpe_instr_informed_v3/perf/'];
% the path for saving reconstruction result
param.path_recon = [mount_path, 'expResult/MPE-informed Source Separator/mpe_instr_informed_v3/reconstruction/'];
% the path for saving the data to be sent via email
param.path_sendData = [mount_path, 'expResult/MPE-informed Source Separator/mpe_instr_informed_v3/sendData/'];

%% dictionary training (building) process, used for automatic generation of dictionary naming
param.dict_train.dict_type =  'supervised_more_codeword_no_concatenate';
param.dict_train.num_codeword_per_pitch = 4; % number of codeword to represent a pitch
% convolutional dictionary learning parameters.
param.dict_train.lambda = 0.05;

%% Pre-process setting
param.pre_process.sampling_rate = 44100;

%% Algorithm settings
param.norm_dict = 1;
param.norm_audio = 0;
param.prob_partition.dim_q = param.pre_process.sampling_rate; % use [] when not intended to partition.
                                 % it is suggested to specify the length
                                 % based on sampling rate (for time-domain
                                 % feature).
param.prob_partition.hop = floor(param.pre_process.sampling_rate*0.5);                                 
    %% MPE
%     param.algorithm.mpe.use_all = 0;
    param.algorithm.mpe.percent = 1;
    %% Instrument recognition
    param.algorithm.use_inst = 1; % set as 1 for using instrument recognition
    param.algorithm.inst_rec.threshold = 0;
    param.algorithm.ODLpath = 'Z:\MPE-informed Source Separator\SPAMS\PC\SPAMS_v2.3\';
    param.algorithm.inst_rec.model = 'bach10'; % 'bach10' or 'rwc'
    param.algorithm.inst_rec.dictionary = [mount_path, filesep, 'MPE-informed Source Separator', ...
        filesep, 'mpe_informed', filesep, 'Inst_Rec', filesep, 'trained_model', filesep, ...
        param.algorithm.inst_rec.model, filesep, 'dict', filesep, 'NMF_D_inst.mat'];
    param.algorithm.inst_rec.svm_model = [mount_path, filesep, 'MPE-informed Source Separator', ...
        filesep, 'mpe_informed', filesep, 'Inst_Rec', filesep, 'trained_model', filesep, ...
        param.algorithm.inst_rec.model, filesep, 'classifier', filesep, 'NMF_svm_model.mat'];
    param.algorithm.inst_rec.input = 'spectrum'; % wav is also supported, but will not be used.    
        %% Spectrogram
        param.algorithm.stft.fs = param.pre_process.sampling_rate;
        param.algorithm.stft.wlen = 2049;
        param.algorithm.stft.hop  = 1024;
        %% NMF        
        param.algorithm.NMF.iteration = 1000;
        param.algorithm.NMF.error_criterion = 'KL'; % KL, default is Frobenius norm
        param.algorithm.NMF.randH0 = 0; % 0 or 1: use MPE
        param.algorithm.NMF.wiener = 1; % 0 or 1
    %% CSC    
    param.run_algorithm = 1;
    param.algorithm.lambda = 0.001; % the lambda in convolutional sparse coding.
    param.algorithm.opt.Verbose = 1;
    param.algorithm.opt.MaxMainIter = 500;
    param.algorithm.opt.AutoScaleGamma = 1;
    param.algorithm.opt.AutoScalePeriod = 10;
    param.algorithm.opt.gamma = 50;
    param.algorithm.opt.RelaxParam = 1.5;
    param.algorithm.opt.NoBndryCross = 0;
    param.algorithm.opt.UseAuxVar = 1;
    param.algorithm.opt.L1Weight = 30;    
	
    param.offset_define = 'next_onset';
    % option: 'next_onset', 'txt'
%% reconstruction parameter
param.reconstruct.fft = 1;
param.reconstruct.hop = param.prob_partition.hop;
param.reconstruct.post_weiner = 0;
param.reconstruct.stft.wlen = 2049;
param.reconstruct.stft.hop = 1024;
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
%% Auto naming and some auto settings
param.npart = length(param.part_name);
for fold = 1:length(param.test_fold)
    for inst = 1:length(param.part_name)     
        %% naming
        param.path_dict{fold, inst} = [dict_root_path, param.dict_train.dict_type, '_', ...
            num2str(param.dict_train.num_codeword_per_pitch), 'AW_Bach10_', ...
            param.part_name{inst}, '_lambda_', num2str(param.dict_train.lambda), ...
            '_fold', num2str(fold), '.mat'];
    end
end

%% Auto naming and some auto settings
param.npart = length(param.part_name);
param.prob_partition.hop = floor(param.prob_partition.dim_q*0.5);
param.reconstruct.hop = param.prob_partition.hop;
if ~isfield(param, 'exp_name')
    param.exp_name = ['lambda_', num2str(param.algorithm.lambda), ...
        '_partiSize_', num2str(param.prob_partition.dim_q)];
	param.exp_name = [param.exp_name, '_offsetDef_', param.offset_define];
    param.exp_name = [param.exp_name, '_normD_', num2str(param.norm_dict)];
    param.exp_name = [param.exp_name, '_normAud_', num2str(param.norm_audio)];
    param.exp_name = [param.exp_name, '_iter_', num2str(param.algorithm.opt.MaxMainIter)];
    % MPE name
    dirChange = strfind(param.path_mpe_result, '/');    
    dirChange = [dirChange, strfind(param.path_mpe_result, '\')];
    dirChange = sort(dirChange);
    if dirChange(end) == length(param.path_mpe_result)
        dirChange = dirChange(end-1);
        MPE_name = param.path_mpe_result(dirChange+1:end-1);
    else
        dirChange = dirChange(end);
        MPE_name = param.path_mpe_result(dirChange+1:end);
    end
    
    param.exp_name = [param.exp_name, '_MPE_', MPE_name];
    param.exp_name = [param.exp_name, 'INST_R_', param.algorithm.inst_rec.model];
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