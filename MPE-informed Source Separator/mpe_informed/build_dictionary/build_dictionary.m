%% Build a dictionary
%  main function, it supports different kinds of building methods.
function [D, D_subset_idx] = build_dictionary(path_dict, path_input_files, param)
%% check save path
[p, ~, ~] = fileparts(path_dict);
if ~exist(p, 'dir')
    mkdir(p);
end
%% train dictionary
switch lower(param.target_dataset)
    case 'maps'        
        [D, D_subset_idx] = build_dictionary_MAPS(path_input_files, param);        
        save(path_dict, 'D', 'D_subset_idx');
    case 'rwc'
        [D, D_subset_idx] = build_dictionary_RWC(path_input_files, param);
        save(path_dict, 'D', 'D_subset_idx');
    case 'rwc_single_pitch'
        [D, D_subset_idx, pitch, ~] = build_dictionary_RWC_single_pitch(path_input_files, param);
        save(path_dict, 'D', 'D_subset_idx', 'pitch');
    case 'bach10'
        [D, D_subset_idx, optinf] = build_dictionary_BACH10(path_input_files, param);
        save(path_dict, 'D', 'D_subset_idx', 'optinf');
    case 'bach10_single_note' % this is single pitch, not note, but I am lazy to modify......
        [D, D_subset_idx, pitch, ~] = build_dictionary_BACH10_single_note(path_input_files, param);        
        save(path_dict, 'D', 'D_subset_idx', 'pitch');
    otherwise
        error('unknown data set for building a dictionary');
end

end