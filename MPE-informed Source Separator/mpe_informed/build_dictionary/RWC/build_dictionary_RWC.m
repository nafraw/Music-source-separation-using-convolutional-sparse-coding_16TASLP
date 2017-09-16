%% build a dictionary from the RWC dataset
%  data set source:
%  https://staff.aist.go.jp/m.goto/RWC-MDB/
%
%  target wave is single wave
function [D, D_subset_idx] = build_dictionary_RWC(path_input_files, param)
fnum = length(path_input_files);
%% build a dictionary
D = [];
D_subset_idx = zeros(2, fnum);
switch lower(param.dict_type)
    %% Extract a period only for each atom for building an exemplar dictionary
    case 'all_exemplar_fundamental'
        for fid = 1:fnum
            fprintf(1, '%4d / %4d\r', fid, fnum);
            %% read file
            [~,~,ext] = fileparts(path_input_files{fid});
            if strcmpi(ext, '.wav')
                [wave, ~] = wavread(path_input_files{fid});
            elseif strcmpi(ext, '.mat')
                [wave] = importdata(path_input_files{fid});
            else
                error('unknown file type when building a dictionary from RWC');
            end
            %% extract the fundamental periodic signal
            %  no normalization was perfomed on the signal.
            [atom, mode_p] = extract_periodic_signal(wave);
            %% save to the dictionary
            D(1:length(atom),end+1) = atom; 
            % since each file only contain a single note.......
            D_subset_idx(1, fid) = fid;
            D_subset_idx(2, fid) = fid;
        end
    %% Take all the atoms for building an exemplar dictionary
    case 'all_exemplar'
        for fid = 1:fnum
            fprintf(1, '%4d / %4d\r', fid, fnum);
            %% read file
            [~,~,ext] = fileparts(path_input_files{fid});
            if strcmpi(ext, '.wav')
                [wave, ~] = wavread(path_input_files{fid});
            elseif strcmpi(ext, '.mat')
                [wave] = importdata(path_input_files{fid});
            else
                error('unknown file type when building a dictionary from RWC');
            end            
            %% save to the dictionary
            if ~isempty(param.max_length)
                if (length(wave) > round(param.max_length))
                    wave = wave(1:round(param.max_length));
                end
            end
            D(1:length(wave),end+1) = wave; 
            % since each file only contain a single note.......
            D_subset_idx(1, fid) = fid;
            D_subset_idx(2, fid) = fid;
        end
    otherwise
        error('unknown dictionary training type');
end


end