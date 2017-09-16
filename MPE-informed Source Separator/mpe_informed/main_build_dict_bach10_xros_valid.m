%% experiment framework
%  Author:Ping-Keng Jao

function [dict, dict_subset_idx] = main_build_dict_bach10_xros_valid(param)
start_max_pool;
%% build dictionaries for each fold
%  foler-based processing

display(['Building a dictionary from the external corpus......']);
n_fold = length(param.train_fold);
n_inst = param.npart;
for fold = 1:n_fold
    fprintf(1, 'fold: %4d / %4d\r', fold, n_fold);
    for part = 1:n_inst
        fprintf(1, '    inst: %4d / %4d\r', part, n_inst);
        param.dict_train.cur_fold = fold;
        param.dict_train.cur_inst = part;
%         param.dict_train.path_txt = strcat(param.dict_train.path_txt{fold}, ext_filelist, '.txt');
%         if strcmpi(param.dict_train.target_dataset, 'MAPS')
%             param.dict_train.path_maps_partition = strcat(param.dict_train.path_maps_partition, ext_filelist, '_partition.mat');
%         end
        if ~isfield(param, 'nmf');
            train_csc = 1;
        elseif param.nmf == 0
            train_csc = 1;
        else
            train_csc = 0;
        end
        if train_csc == 1
            [dict{fold, part}, dict_subset_idx{fold, part}] = ...
                build_dictionary(param.path_dict{fold, part}, ...
                param.path_pre_process_external_corpus{fold, part}, ...
                param.dict_train);
        else
            [dict{fold, part}, dict_subset_idx{fold, part}] = ...
                build_nmf_dictionary(param.path_dict{fold, part}, ...
                param.path_pre_process_external_corpus{fold, part}, ...
                param.dict_train);
        end
    end
end


end