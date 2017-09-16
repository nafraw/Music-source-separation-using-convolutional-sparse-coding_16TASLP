function trim_wave(trim_length, target_path, root_save)
%% settings
% trim_length = 5; % in second
% target_path = 'Z:\Bach10\Bach-2\';
% root_save  = ['Z:\Bach10\Bach-2_', num2str(trim_length), 'sec\'];

%% main loop
filelist = listfile(target_path, '.wav', false);
for fid = 1:length(filelist)
    [wav, fs] = wavread(filelist{fid});
    if trim_length <= 0
        new_wav = wav;
    else
        new_wav = trim_wave(wav, fs, 0, trim_length);
    end
    [p, f, e] = fileparts(filelist{fid});
    p = [root_save, p(length(target_path)+1:end), '\'];
    path_save = [p, f, '.wav'];
    if ~exist(p, 'dir')
        mkdir(p);
    end
    wavwrite(new_wav, fs, path_save);
end
end