function count_pitch_presence(target_path, save_path)
% modify the path to Bach10 source of single instrument
% target_path = 'Y:\Bach10\Bach-1\source\';
load('./instrument_pitch_set.mat');

format{1} = '*-1.wav';
format{2} = '*-2.wav';
format{3} = '*-3.wav';
format{4} = '*-4.wav';

for target = 1:length(format)
    filelist = listfile_query_by_format(target_path, format{target}, false);
    
    for fid = 1:length(filelist)        
        % read meta data
        [p, f, e] = fileparts(filelist{fid});
        txt_file = [p, '\', f, '.txt'];
        meta = importdata(txt_file);
        meta = meta(:,3);
        for pid = 1:length(pitch{target})
            pitch_occurrence{target}(pid, fid) = length(find(meta==pitch{target}(pid)));
        end
    end
    all_pit_occ{target} = sum(pitch_occurrence{target}, 2);
end
save(save_path, 'all_pit_occ', 'pitch_occurrence');
