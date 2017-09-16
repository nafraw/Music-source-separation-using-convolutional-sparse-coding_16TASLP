%% add paths
addpath(genpath('../../../MATLAB gadget'));     %JPK's bitbucket project.
addpath(genpath('../../MPE'));

%% Bach 10
path_bach10 = 'Z:\MPE-informed Source Separator\dataset\Bach10\Bach-4\mixed\';
path_outBach = 'Z:\MPE-informed Source Separator\dataset\Bach10\Bach-4\MPE_result\';
all_files = listfile_query_by_format(path_bach10, '*.wav', false);
    %% Li Su's MPE
    for itF = 1:length(all_files)
        [p, f, e] = fileparts(all_files{itF});
        out_file = [path_outBach, 'LiSu\', f, '.txt'];
        check_path(out_file);
%         LiSu_MPE(all_files{itF}, out_file);
        LiSu_MPE_v2(all_files{itF}, out_file);
    end
    %% E. Vincent's MPE
%     for itF = 1:length(all_files)
%         [p, f, e] = fileparts(all_files{itF});
%         out_file = [path_outBach, 'Vincent\', f, '.txt'];
%         check_path(out_file);
%         multipitch_estimation(all_files{itF}, out_file);        
%     end


%% remove paths
rmpath(genpath('../../../MATLAB gadget'));
rmpath(genpath('../../MPE'));