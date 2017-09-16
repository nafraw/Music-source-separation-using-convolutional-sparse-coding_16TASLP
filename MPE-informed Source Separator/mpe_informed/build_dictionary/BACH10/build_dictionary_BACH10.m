function [D, D_subset_idx, optinf] = build_dictionary_BACH10(path_input_files, param)
fnum = length(path_input_files);
%% read all files and make it a (vector), probably matrix, not sure which is better
parfor fid = 1:fnum
    [~,~,ext] = fileparts(path_input_files{fid});
    if strcmpi(ext, '.mat')
        temp{fid, 1} = importdata(path_input_files{fid});
    elseif strcmpi(ext, '.wav')
        wav = wavread(path_input_files{fid});
        if size(wav, 2) ~= 1
            wav = mean(wav, 2);
        end
        temp{fid, 1} = wav;
    else
        error(['Unknown file extension: ', ext, ' for dictionary learning']);
    end
end
s = cell2mat(temp);
s = reshape(s, [size(s,1), 1 size(s,2)]);
D0 = param.D0;
D0 = reshape(D0, [size(D0,1), 1 size(D0,2)]);
%% start training dictionary
tic
switch lower(param.dict_type)
    case 'all'        
        [D, X, optinf] = cbpdndliu(D0, s, param.lambda, param.opt);
    case 'supervised'
        error(['This dictionary training strategy is not yet supported.']);
end
training_time = toc;
D = reshape(D, [size(D,1), size(D,3)]);
D_subset_idx(1,1) = 1;
D_subset_idx(2,1) = size(D, 2);
display(['dictionary training takes: ', num2str(training_time), ' seconds.']);
end