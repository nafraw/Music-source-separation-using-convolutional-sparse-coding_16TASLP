function trim_txt(target_time, target_path, outDir)
%% settings
% target_time = 5; % in second, when it is 5, it will cut off notes after 5 second.
% target_path = 'Z:\Bach10\Bach-2\mixed\';
% outDir = ['Z:\Bach10\Bach-2_', num2str(target_time), 'sec\mixed\'];
%% main loop
txtlist = listfile(target_path, '.txt', false);
fnum = length(txtlist);
for fid = 1:fnum
    nm = importdata(txtlist{fid});
    % trim length
    if target_time > 0
        cut_idx = find(nm(:,1) > target_time*1000, 1, 'first');    
        nm = nm(1:cut_idx-1, :);
    end
    % save result
    [p, f, e] = fileparts(txtlist{fid});
    p = [outDir, p(length(target_path)+1:end), '\'];    
    if ~exist(p, 'dir')
        mkdir(p);
    end    
    outpath = [p, f, e];    
    fid = fopen(outpath, 'wt');
    fprintf(fid, '%d\t%d\t%d\t%d\n', nm');
    fclose(fid);
end
end
