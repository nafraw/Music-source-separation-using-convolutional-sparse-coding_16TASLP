function param = train_supervised_rwc_default_setup(settings)
if ~exist('settings', 'var')
    settings = [];
end
%% instrument setting
param.part_name = {'Violin', 'Clarinet', 'Saxophone', 'Bassoon'};
% param.part_name = {'Bassoon'};
param.npart = length(param.part_name);

%% path setting
if isunix
%     root_path ='~/NAS/NAS_home/Bach10/Bach-1/source/';
% 	dict_root_path = '~/NAS/NAS_home/Bach10/dictionary/';
% 	mount_path = '~/NAS/NAS_home';
else
    root_path = 'Y:/Bach10/Bach-1/source/';
    dict_root_path = 'Z:/MPE-informed Source Separator/dict/';
    mount_path = 'Z:';
end
param.rootpath_train_corpus = 'Z:\MPE-informed Source Separator\dataset_preprocess\RWC\SegmentedData\';

%% dictionary training (building) process
param.dict_train.sampling_rate = 44100;
param.dict_train.target_dataset = 'RWC_single_pitch';
param.dict_train.dict_type =  'supervised_more_codeword_no_concatenate';
param.dict_train.max_length = 0.1 * param.dict_train.sampling_rate; % 0.1 second by default
param.dict_train.num_codeword_per_pitch = 4; % number of codeword to represent a pitch
param.dict_train.awgn_snr = 15;              % SNR of additive white Gaussian noise
% convolutional dictionary learning parameters.
param.dict_train.norm_train = 0;
param.dict_train.lambda = 0.05;
param.dict_train.opt = [];
param.dict_train.opt.Verbose = 1;
param.dict_train.opt.MaxMainIter = 250;
param.dict_train.opt.NoBndryCross = 0;
param.dict_train.opt.gamma = 50;
param.dict_train.opt.delta = 50;
param.dict_train.opt.AutoScaleGamma = 1;
param.dict_train.opt.AutoScaleGammaPeriod = 10;
param.dict_train.opt.AutoScaleDelta = 1;
param.dict_train.opt.AutoScaleDeltaPeriod = 10;
param.dict_train.opt.L1Weight = 1;
param.dict_train.opt.ZeroMean = 1;

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
for inst = 1:length(param.part_name)
    %% setting training data path
    param.path_pre_process_external_corpus{inst} = ...
        [param.rootpath_train_corpus, filesep, param.part_name{inst}, ...
        ];
    %% setting dictionary initial file
%     param.dict_train.D0_path{fold, inst} = [mount_path, ...
%         '/MPE-informed Source Separator/dataset/RWC/init_data/dict_exemplar_time_RWC_',...
%         param.part_name{inst},'_NOF_no_downsample.mat'];
    %         idata = load(param.dict_train.D0_path{fold, inst});
    %         param.dict_train.pitch_D0{fold, inst} = idata.pitch;
    %         param.dict_train.D0{fold, inst} = idata.D;
    %         clear idata;
    %% naming
    param.path_dict{inst} = [dict_root_path, param.dict_train.dict_type, '_', ...
        num2str(param.dict_train.num_codeword_per_pitch), 'AW_RWC_', ...
        param.part_name{inst}, '_lambda_', num2str(param.dict_train.lambda), ...
        '.mat'];
end

end % end of function