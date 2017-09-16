function [path, file, ext] = check_path(path_to_check)
% check whether the path exists, if not, create the directory
[path, file, ext] = fileparts(path_to_check);
if ~exist(path, 'dir')
    mkdir(path);
end
end