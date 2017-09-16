% Modified listfile v 1.3 (original from Yi-Hsuan Yang)
% The last author: Chin-Chia Yeh 2013/8/29
%
% file_list = listfile(path, ext, verbose)
% ext = '.m' for all .m files
% ext = false for all file type
%

function files = listfile(path, ext, verbose, parent_files)
if ~exist('verbose', 'var')
    verbose = true;
end
if ~exist('ext', 'var')
    ext = false;
end
if ~exist('parent_files', 'var')
    parent_files = {};
end

names = dir(path);
current_files = cell(size(names));
isfile = false(size(names));
for n = 1:length(names)
    if strcmp(names(n).name, '..')
        continue;
    elseif strcmp(names(n).name, '.')
        continue;
    else
        f = fullfile(path, names(n).name);
    end
    if exist(f, 'dir')==7 % directory
        parent_files = listfile(f, ext, verbose, parent_files);
    else % file
        if ext
            [~, ~, f_ext] = fileparts(f);
            if strcmpi(ext, f_ext)
                isfile(n) = true;
                current_files{n} = f;
                if verbose
                    disp(['add: ' f]);
                end
            end
        else
            isfile(n) = true;
            current_files{n} = f;
            if verbose
                disp(['add: ' f]);
            end
        end
    end
end
current_files = current_files(isfile);
files = [parent_files; current_files];