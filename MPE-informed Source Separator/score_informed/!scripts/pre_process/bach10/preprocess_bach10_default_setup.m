function param = param_setup(settings)
if ~exist('settings', 'var')
    settings = [];
end

%% target setting
if isunix
%     root_path ='~/NAS/NAS_home/Bach10/Bach-1/source/';
% 	dict_root_path = '~/NAS/NAS_home/Bach10/dictionary/';
% 	mount_path = '~/NAS/NAS_home';
else
    % root_path = 'Y:/Bach10/Bach-1/source/';
    dict_root_path = 'Z:/MPE-informed Source Separator/dict/';
    mount_path = 'Z:/';
end
% paths for pre-processing
param.path_target_corpus = [mount_path, ...
    'MPE-informed Source Separator/dataset/Bach10/Bach-4/mixed/'];
param.path_target_separated_corpus = [mount_path, ...
    'MPE-informed Source Separator/dataset/Bach10/Bach-4/separated/'];
param.target_ext = '*.wav';
% paths for saving pre-processed files
param.path_pre_process_target_corpus = [mount_path, ...
    'MPE-informed Source Separator/dataset/Bach10/Bach-4/pre_process/mixed/'];
param.path_pre_process_target_separated_corpus = [mount_path, ...
    'MPE-informed Source Separator/dataset/Bach10/Bach-4/pre_process/separated/'];
param.target_separated_ext = '*.wav';

%% Pre-process settings
mirwaitbar(0); % tell MIRtoolbox to shutup
param.pre_process.mir_shutup = 1;
param.pre_process.sampling_rate = 44100;
% calculate spectrum
param.pre_process.spectrum = 0; % true or false

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
end % end of function