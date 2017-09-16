function count_pitch_presence_mixed(target_path, save_path)
% modify the path to mixed waves of Bach10
% target_path = 'Y:\Bach10\Bach-4_5sec\mixed\';
load('./instrument_pitch_set.mat');

insid = 1:4;
for target = 1:length(insid)      
    filelist = listfile_query_by_format(target_path, '*.txt', false);
        
    for fid = 1:length(filelist)        
        % read meta data
        [p, f, e] = fileparts(filelist{fid});
        txt_file = [p, '\', f, '.txt'];
        meta = importdata(txt_file);
        idx_ins = find(meta(:,4) == insid(target));
        meta = meta(idx_ins,3);        
        for pid = 1:length(pitch{target})
            pitch_occurrence{target}(pid, fid) = length(find(meta==pitch{target}(pid)));
        end
    end
    all_pit_occ{target} = sum(pitch_occurrence{target}, 2);
end
save(save_path, 'all_pit_occ', 'pitch_occurrence');
