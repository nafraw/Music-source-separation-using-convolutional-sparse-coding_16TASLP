function trim_midi(target_time, target_path, outDir)
%% some libraries for MIDI files
javaaddpath('./KaraokeMidiJava.jar');
addpath('./miditoolbox');
addpath('./midi_lib');
%% settings
% target_time = 5; % in second, when it is 5, it will cut off notes after 5 second.
% target_path = 'Z:\Bach10\Bach-4\separated\';
% outDir = ['Z:\Bach10\Bach-4_', num2str(target_time), 'sec\mixed\'];

%% main loop
midilist = listfile(target_path, '.mid', false);
fnum = length(midilist);
for fid = 1:fnum
    [nm] = readmidi_java(midilist{fid});
    % trim length
    if target_time > 0
        cut_idx = find(nm(:,6) > target_time, 1, 'first');
        nm = nm(1:cut_idx-1, :);
    end
    % save result
    [p, f, e] = fileparts(midilist{fid});
    p = [outDir, p(length(target_path)+1:end), '\'];    
    if ~exist(p, 'dir')
        mkdir(p);
    end
    outpath = [p, f, e];
    writemidi_java(nm, outpath);
end
%% remove path
rmpath('./miditoolbox');
rmpath('./midi_lib');
end