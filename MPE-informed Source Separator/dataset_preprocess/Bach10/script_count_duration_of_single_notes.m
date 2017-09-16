clear
hop_size = 0.01; % in second
frame_size = 0.046; % in second
cut_ratio = 0.25;

format{1} = '*-1.wav';
format{2} = '*-2.wav';
format{3} = '*-3.wav';
format{4} = '*-4.wav';

dur = [];
for target = 1:length(format)    
    target_path = 'Z:\Bach10\Bach-1\source\';    
    filelist = listfile_query_by_format(target_path, format{target}, false);
    
    note_idx = 1;
    for fid = 1:length(filelist)
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
                dur(end+1) = duration;
            else
                duration = meta(note,2) - meta(note,1);
                if duration < 0
                    frame_start = aux{note}(1,1);
                    frame_end   = aux{note}(1,end);
                    sec_start   = (frame_start-1)* hop_size;
                    sec_end     = (frame_end-1)  * hop_size + frame_size;
                    duration = sec_end - sec_start;
                end
                dur(end+1) = duration;
            end
        end
    end    
end