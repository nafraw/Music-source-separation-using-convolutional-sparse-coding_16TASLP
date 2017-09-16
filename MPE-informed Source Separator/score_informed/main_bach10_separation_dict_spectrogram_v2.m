%% experiment framework
%  Author:Ping-Keng Jao
%  param.
function [SSperf] = main_bach10_separation_dict_spectrogram_v2(param)
% start_max_pool;
%% setting automatic path
param.path_target_separated_corpus = listfile_query_by_format(param.path_target_separated_corpus, param.target_ext, false);
all_files = listfile_query_by_format(param.path_target_corpus, param.target_ext, false);
% extract file name and extension
filelist = cell(length(all_files),1);
filelistext = cell(length(all_files),1);
for fid = 1:length(all_files)    
    %% this setting covers the filename and folder structure (w/o specified root path)
    [pa, file, ext] = fileparts(all_files{fid});
    lp = length(param.path_target_corpus);
    filelist{fid} = [pa(lp+1:end), '/', file]; % the '/' is in case someone forgot to set a '/' in the paths of param.
    filelistext{fid} = ext;
end
param.path_target_corpus = all_files;
clear all_files;
% concatenate the filelist to other paths
param.path_separation = strcat(param.path_separation, filelist, '.mat');
param.path_perf = strcat(param.path_perf, filelist, '.mat');
param.path_score = strcat(param.path_score, filelist, '.txt');
param.path_recon = strcat(param.path_recon, filelist, '.wav');
%% for each fold
for fold = 1:length(param.test_fold)
%% load main dictionary
display(['Loading the specified dictionary from']);
    %% load all sub-dictionaries
    M_length = 0; % the maximum signal length (for calculating the number of zeros to pad).
    num_codeword = 0;
    dnum = param.npart;
    for did = 1:dnum
        display([param.path_dict{fold, did}]);
        temp = importdata(param.path_dict{fold, did});
        D_{did} = temp.D;
        pitch{did} = temp.pitch;
        if M_length < size(temp.D,1)
            M_length = size(temp.D,1);
        end
        num_codeword = num_codeword + size(temp.D, 2);
    end
    %% collect all subdictionaries and pad zeroes
    D = zeros(M_length, num_codeword);
    sid = 1; % start index for current sub-dictionary
    dict_sid = [];
    for did = 1:dnum
        dict_sid(did) = sid;
        eid = sid + size(D_{did}, 2) - 1; % end index for current sub-dictionary
        D(1:size(D_{did}, 1), sid:eid) = D_{did};
        sid = eid + 1;
    end
    if param.norm_dict ~= 0
        D = normalization(D);
    end
    clear temp;
    clear sid;
    clear eid;
    clear num_codeword
%% Source separation for each file
display('Starting source separation...');
    % file number
    fnum = length(param.path_target_corpus);
    for ffid = 1 : length(param.test_fold{fold})
        fid = param.test_fold{fold}(ffid);
        param.fid = fid;
        fprintf(1, '%4d / %4d\r', fid, fnum);        
        %% partition problem
        %  output a matrix (reshape a vector into matrix form such that each
        %  vector correspond to a fixed time-length waveform.
%         [P, zero_pad, param.prob_partition.dim_q] = ...
%             partition_problem(param.path_target_corpus{fid}, param.prob_partition);
        [P, length_audio, length_pad_audio, mix_audio] = ...
            partition_problem_v2(param.path_target_corpus{fid}, param.prob_partition);
        %% normalize each partition
        norm_ratio = ones(size(P,2),1);
        if param.norm_audio ~= 0
            [P, norm_ratio] = normalization(P);
        end
        %% Calculate STFT
        [stft_music, freq, p_stft_music] = cal_stft(P, param.stft);
        
        %% Score-Informed Source Separation
        [W, H, maskD, inst_id] = score_informed_dict_NMF_wo_time(D, pitch, dict_sid, freq, p_stft_music, param, fid);        
        %% output stage
        display(['Reconstructing......']);        
        sampling_rate = param.pre_process.sampling_rate;
        if param.run_algorithm == 0
            maskD = [];
        end
        param.reconstruct.dim_q = param.prob_partition.dim_q;
%         R = reconstruct_NMF(param.path_recon{fid}, sampling_rate, stft_music, ...
%             zero_pad, param.path_separation{fid}, norm_ratio, param.reconstruct ...
%             );
        R = reconstruct_NMF_v2(param.path_recon{fid}, sampling_rate, stft_music, ...
            param.path_separation{fid}, norm_ratio, ...
            length_pad_audio, length_audio, mix_audio, param.reconstruct ...
            );
        
        [SSperf(fid)] = source_separation_evaluation(R, param.path_target_separated_corpus, fid);
        display(['SDR: ',  num2str(SSperf(fid).SDR')]);
        display(['SIR: ',  num2str(SSperf(fid).SIR')]);
        display(['SAR: ',  num2str(SSperf(fid).SAR')]);
        display(['perm: ', num2str(SSperf(fid).perm')]);
    end
end
end

function sampling_rate = read_sampling_rate(path)
    [~] = evalc('audio = miraudio(path);');
    sampling_rate = get(audio, 'Sampling'); 
    sampling_rate = sampling_rate{1}; % stupid MIR toolbox will make sampling_rate as cell...
end