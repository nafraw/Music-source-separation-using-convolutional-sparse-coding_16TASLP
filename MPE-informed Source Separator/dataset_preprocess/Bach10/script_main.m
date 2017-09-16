%% trim length of each chorale
trim_length  = -1; % in terms of second, this value must > 0, otherwise, no trimming, but copying.
target_path = 'Y:/Bach10/Bach-4/separated/';
if trim_length > 0
    save_path = ['Z:/CSC_screening/dataset/Bach10/Bach-4_', ...
                  num2str(trim_length), 'sec/separated/'];
else
    save_path = 'Z:/CSC_screening/dataset/Bach10/Bach-4/separated/';
end
display('trimming source');
trim_wavefile(trim_length, target_path, save_path);
trim_midi(trim_length, target_path, save_path);
trim_txt(trim_length, target_path, save_path);

target_path = 'Y:/Bach10/Bach-4/mixed/';
if trim_length > 0
    save_path = ['Z:/CSC_screening/dataset/Bach10/Bach-4_', ...
                  num2str(trim_length), 'sec/mixed/'];
else
    save_path = 'Z:/CSC_screening/dataset/Bach10/Bach-4/mixed/';
end
display('trimming mixed audio');
trim_wavefile(trim_length, target_path, save_path);
trim_midi(trim_length, target_path, save_path);
trim_txt(trim_length, target_path, save_path);

%% calculate the presence of pitch
display('counting presence of pitches');
save_path_source   = 'pitch_presence_source';
save_path_mixed    = 'pitch_presence_mixed';
target_path_source = 'Y:/Bach10/Bach-1/source/';
target_path_mixed  = save_path;
count_pitch_presence_mixed(target_path_mixed, save_path_mixed);
count_pitch_presence(target_path_source, save_path_source);
%% find validation subset
display('finding validation subset');
n_fold = 1;
% if ~useful, the fold partition cannot cover all test cases
% a special case is n_fold = 1 (all are used as training)
[useful, fold, flag_trimmed] = find_validation_set(n_fold);

%% generate dictionary training data
target_path = 'Y:\Bach10\Bach-1\source\';
save_root = 'Z:/CSC_screening/dataset/Bach10/traindata_dict/';
if useful
    display('generating training data for dictionary');
    collect_single_notes_specify_duration(fold, target_path, save_root);
else
    display('no useful fold partition was found');
end