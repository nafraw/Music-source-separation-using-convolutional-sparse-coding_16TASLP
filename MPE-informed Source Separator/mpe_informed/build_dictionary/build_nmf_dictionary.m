%% Build a dictionary
%  main function, it supports different kinds of building methods.
function [D, D_subset_idx] = build_nmf_dictionary(path_dict, path_input_files, param)
%% check save path
[p, ~, ~] = fileparts(path_dict);
if ~exist(p, 'dir')
    mkdir(p);
end
%% train dictionary
switch lower(param.target_dataset)    
    case 'rwc_single_pitch'
        [D, D_subset_idx, pitch, ~] = build_NMF_template_RWC_single_pitch(path_input_files, param);
        save(path_dict, 'D', 'D_subset_idx', 'pitch');
    case 'bach10_single_note' % this is single pitch, not note, but I am lazy to modify......
        [D, D_subset_idx, pitch, ~] = build_NMF_template_BACH10_single_note(path_input_files, param);
        save(path_dict, 'D', 'D_subset_idx', 'pitch');
    otherwise
        error('unknown data set for building a dictionary');
end

end