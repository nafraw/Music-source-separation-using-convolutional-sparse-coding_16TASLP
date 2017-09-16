instId = '271';
target_wav{1} = ['X:\RWC_(real_world_computing)\Source\Instrument\', instId, '\', instId, 'TSNOF.wav'];
target_wav{2} = ['X:\RWC_(real_world_computing)\Source\Instrument\', instId, '\', instId, 'TSNOM.wav'];
target_wav{3} = ['X:\RWC_(real_world_computing)\Source\Instrument\', instId, '\', instId, 'TSNOP.wav'];
inst = 'Saxophone'; % Violin or other 
for fid = 1:length(target_wav)    
    [~, file_target, ~] = fileparts(target_wav{fid});
    root_save  = ['Y:\RWC\Instrument\MPE-informed\Manual_segmentation\'];
    if ~exist(root_save, 'dir')
        mkdir(root_save);
    end
    trim_file = ['Z:\MPE-informed Source Separator\dataset_preprocess\RWC\OnsetOffset\Saxophone\', instId, '\', file_target, '.xlsx'];
    trim = importdata(trim_file);
    trim_set = trim.data;
    [wav, fs] = wavread(target_wav{fid});
    
    if strcmpi(inst, 'violin') % the case of violin
        pitch = [55:67 62:74 69:81 76:100]';
    else % non-viloin
        pr = trim.colheaders; % pitch range
        sp = midinumber(pr{1});
        ep = midinumber(pr{2});
        pitch = sp:ep;
    end
    corpus = cell(length(pitch), 2);
    assert(length(pitch) == size(trim_set, 1));
    for i =1:size(trim_set, 1)
        % trim wav
        corpus{i, 1} = trim_wave(wav, fs, trim_set(i,1), trim_set(i,2));
        corpus{i, 2} = pitch(i);
    end
    % save file
    path_save = [root_save, file_target, '.mat'];    
    save(path_save, 'corpus');
end