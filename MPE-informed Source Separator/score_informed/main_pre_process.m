%% experiment framework
%  Author:Ping-Keng Jao
%  param.
function [param] = main_pre_process(param)
start_max_pool;
%% Mixed audio
display('Collecting files from the mixed target corpus......');
%% find all target files
[all_files] = listfile_query_by_format(param.path_target_corpus, param.target_ext, false);
% extract file name and extension
filelist = cell(length(all_files),1);
filelistext = cell(length(all_files),1);
for fid = 1:length(all_files)
    %% this setting only covers the filename
    %         [~, file, ext] = fileparts(all_files{fid});
    %         filelist{fid} = ['/', file]; % the '/' is in case someone forgot to set a '/' in the paths of param.
    %         filelistext{fid} = [ext];
    %% this setting covers the filename and folder structure (w/o specified root path)
    [pa, file, ext] = fileparts(all_files{fid});
    lp = length(param.path_target_corpus);
    filelist{fid} = [pa(lp+1:end), '/', file]; % the '/' is in case someone forgot to set a '/' in the paths of param.
    filelistext{fid} = ext;
end
param.path_target_corpus = all_files;
clear all_files;
% concatenate the filelist to other paths
param.path_pre_process_target_corpus = strcat(param.path_pre_process_target_corpus, filelist, '.mat');

%% Separated audio files
display('Collecting files from the separated target corpus......');
%% find all target files
[all_files] = listfile_query_by_format(param.path_target_separated_corpus, param.target_separated_ext, false);
% extract file name and extension
filelist = cell(length(all_files),1);
filelistext = cell(length(all_files),1);
for fid = 1:length(all_files)
    %% this setting only covers the filename
    %         [~, file, ext] = fileparts(all_files{fid});
    %         filelist{fid} = ['/', file]; % the '/' is in case someone forgot to set a '/' in the paths of param.
    %         filelistext{fid} = [ext];
    %% this setting covers the filename and folder structure (w/o specified root path)
    [pa, file, ext] = fileparts(all_files{fid});
    lp = length(param.path_target_separated_corpus);
    filelist{fid} = [pa(lp+1:end), '/', file]; % the '/' is in case someone forgot to set a '/' in the paths of param.
    filelistext{fid} = ext;
end
param.path_target_separated_corpus = all_files;
clear all_files;
param.path_pre_process_target_separated_corpus = strcat(param.path_pre_process_target_separated_corpus, filelist, '.mat');

%% Pre-processing mixed audio files
% downsample and/or filter and normalize target corpus.
display('Pre-processing target corpus......');
pre_process(param.path_pre_process_target_corpus, ...
    param.path_target_corpus, ...
    param.pre_process);

%% Pre-processing separated audio files
% downsample and/or filter and normalize target corpus.
display('Pre-processing target-separated corpus......');
pre_process(param.path_pre_process_target_separated_corpus, ...
    param.path_target_separated_corpus, ...
    param.pre_process);
end