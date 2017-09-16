function collect_single_notes_specify_duration(valid_set, target_path, save_root)
hop_size = 0.01; % in second
frame_size = 0.046; % in second
cut_ratio = 0; % cut first and last part with cut-ratio
% target_path = 'Y:\Bach10\Bach-1\source\';
% save_root = 'Y:\Bach10\Single_notes\';
% valid_set = {[1 2 3 6 10], [4 5 7 8 9]};
format{1} = '*-1.wav';
format{2} = '*-2.wav';
format{3} = '*-3.wav';
format{4} = '*-4.wav';
% for vs = 1:10
for vs = 1:length(valid_set)
%     valid_set{vs} = 1:10;
%     valid_set{vs}(vs) = [];
    save_paths{1} = [save_root, 'Violin_use_aux_', num2str(valid_set{vs}), '.mat'];
    save_paths{2} = [save_root, 'Clarinet_use_aux_', num2str(valid_set{vs}), '.mat'];
    save_paths{3} = [save_root, 'Saxophone_use_aux_', num2str(valid_set{vs}), '.mat'];
    save_paths{4} = [save_root, 'Bassoon_use_aux_', num2str(valid_set{vs}), '.mat'];
    for target = 1:length(save_paths)
        clear note_wav;
        clear note_pitch;
        save_path = save_paths{target};
        filelist = listfile_query_by_format(target_path, format{target}, false);
        
        note_idx = 1;
        %         for fid = 1:length(filelist)
        qq = valid_set{vs};
        for qid = 1:length(qq)
            fid = qq(qid);
            [wav, fs] = wavread(filelist{fid});
            % read meta data
            [p, f, e] = fileparts(filelist{fid});
            txt_file = [p, '\', f, '.txt'];
            meta = importdata(txt_file);
            % convert from msec to sec
            meta(:,1:2) = meta(:,1:2)./1000;
            % auxilary data
            aux_file = [p, '\', f, '-GTNotes.mat'];
            aux = importdata(aux_file);
            aux = aux{1};
            % extract each note
            for note = 1:size(meta,1)
                if note ~= size(meta,1)
                    duration = meta(note+1,1) - meta(note,1);
                    if duration < 0
                        error('offset is before onset!');
                    end
                    % cut 10% duration each in the beginning and end
                    note_wav{note_idx, 1} = trim_wave(wav, fs, meta(note,1)+cut_ratio*duration, meta(note+1,1)-cut_ratio*duration);
                else
                    duration = meta(note,2) - meta(note,1);
                    if duration < 0
                        frame_start = aux{note}(1,1);
                        frame_end   = aux{note}(1,end);
                        sec_start   = (frame_start-1)* hop_size;
                        sec_end     = (frame_end-1)  * hop_size + frame_size;
                        duration = sec_end - sec_start;
                        note_wav{note_idx, 1} = trim_wave(wav, fs, meta(note,1)+cut_ratio*duration, meta(note,1)+duration-cut_ratio*duration);
                    else
                        note_wav{note_idx, 1} = trim_wave(wav, fs, meta(note,1)+cut_ratio*duration, meta(note,2)-cut_ratio*duration);
                    end
                    
                end
                note_pitch(note_idx, 1) = meta(note, 3);
                note_idx = note_idx + 1;
            end
        end
        [p,~,~] = fileparts(save_path);
        if ~exist(p, 'dir')
            mkdir(p);
        end
        save(save_path, 'note_wav', 'note_pitch', 'cut_ratio', 'frame_size', 'hop_size');
    end
end