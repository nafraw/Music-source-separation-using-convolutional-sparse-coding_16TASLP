clear
hop_size = 0.01; % in second
frame_size = 0.046; % in second
cut_ratio = 0; % cut first and last part with cut-ratio
target_path = 'Y:\Bach10\Bach-1\source\';
save_root = 'Y:\Bach10\Single_notes\';
valid_set = {[1 2 3 6 10], [4 5 7 8 9]};
format{1} = '*-1.wav';
format{2} = '*-2.wav';
format{3} = '*-3.wav';
format{4} = '*-4.wav';
for vs = 1:10
% for vs = 1:length(valid_set)
%     valid_set{vs} = 1:10;
%     valid_set{vs}(vs) = [];
    save_paths{1} = [save_root, 'Violin_use_mat_', num2str(valid_set{vs}), '.mat'];
    save_paths{2} = [save_root, 'Clarinet_use_mat', num2str(valid_set{vs}), '.mat'];
    save_paths{3} = [save_root, 'Saxophone_use_mat_', num2str(valid_set{vs}), '.mat'];
    save_paths{4} = [save_root, 'Bassoon_use_mat_', num2str(valid_set{vs}), '.mat'];
    for target = 1:length(save_paths)
        clear note_wav;
        clear note_pitch;
        save_path = save_paths{target};
        filelist = listfile_query_by_format(target_path, format{target}, false);
        
        note_idx = 1;
        qq = valid_set{vs};
        for qid = 1:length(qq)
            fid = qq(qid);
            [wav, fs] = wavread(filelist{fid});
            % read meta data
            [p, f, e] = fileparts(filelist{fid});
            meta_file = [p, '\', f, '-GTNotes.mat'];
            meta = importdata(meta_file);
            meta = meta{1};
            %         txt_file = [p, '\', f, '.txt'];
            %         txt = importdata(txt_file);
            %         txt = txt(:,3);
            % extract each note
            for note = 1:size(meta,1)
                frame_start = meta{note}(1,1);
                frame_end   = meta{note}(1,end);
                sec_start   = (frame_start-1)* hop_size;
                sec_end     = (frame_end-1)  * hop_size + frame_size;
                duration = sec_end - sec_start;
                note_wav{note_idx, 1} = trim_wave(wav, fs, sec_start+cut_ratio*duration, sec_end-cut_ratio*duration);
                note_pitch(note_idx, 1) = round(mean(meta{note}(2,:)));
                %             note_pitch(note_idx, 1) = txt(note);
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