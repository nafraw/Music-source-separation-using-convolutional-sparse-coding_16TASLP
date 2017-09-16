%% Main function of pre-processing
%  This function mainly handles the normalization and  downsample process.
%  The input is a set of files and a parameter for downsample and
%  normalization.
function pre_process(out_paths, input_paths, param)

fnum = length(input_paths);
parfor fid = 1:fnum
    if param.mir_shutup ~= 0
        [mirwaveform] = mir_shutup_function(input_paths{fid}, param);
%         [~] = evalc('mirwaveform = miraudio(input_paths{fid}, ''normal'', ''sampling'', param.sampling_rate);');
    else
        mirwaveform = miraudio(input_paths{fid}, 'sampling', param.sampling_rate);
    end
    feature = mirgetdata(mirwaveform);
    if param.spectrum
        feature = aud2spec([], param.spectrum_win, ...
                           param.spectrum_hop, ...
                           param.spectrum_dc, [], feature);
    end
    % clip song with specified duration
    if isfield(param, 'clip_duration')
        if ~isempty(param.clip_duration)
            feature = feature(1:param.sampling_rate*param.clip_duration);
        end
    end
%% MATLAB buil-in approach
%     %% read audio file and make it as a mono track.
%     [waveform] = read_audio(input_paths{fid});
%     %% perform rms normalization
%     %  not at this moment.
%     %  normalization stage is preferred in the seperation stage as we
%     %  intend to reconstruct time signal with a normalized dictionary and 
%     %  coefficients. This means how was the data normalized should be known
%     %  for the reconstruction stage (or multiply to the coefficient?).
%     % [norm_waveform] = rms_normalization(waveform);
%     %% down sample
%     [down_waveform] = downsample(norm_waveform);
    %% save file
    parsave(out_paths{fid}, feature, param.sampling_rate);
end

end

function [waveform] = mir_shutup_function(path, param)
%     [~] = evalc('waveform = miraudio(path, ''normal'', ''sampling'', param.sampling_rate);');
    [~] = evalc('waveform = miraudio(path, ''sampling'', param.sampling_rate);');
end
%% read audio file and make it as a mono track.
function [waveform, sampling_rate] = read_audio(path)
    [~, ~, ext] = fileparts(path);
    if strcmpi(ext, 'mp3')
        [waveform, sampling_rate] = audioread(path);
    else
        [waveform, sampling_rate] = waveread(path);
    end
end
% %% perform rms normalization
% function [norm_waveform] = rms_normalization(waveform)
%     
% end
%% down sample
%  MATLAB built-in decimate is used
function [down_waveform] = downsample(waveform, param)
    if param.fir ~= 0
        if isfield(param, 'filter_order')
            [down_waveform] = normalization(waveform, param.decimate_factor, param.filter_order, 'fir');
        else
            [down_waveform] = normalization(waveform, param.decimate_factor, 'fir');
        end
    elseif isfield(param, 'filter_order')
        [down_waveform] = normalization(waveform, param.decimate_factor, param.filter_order);
    else
        [down_waveform] = normalization(waveform, param.decimate_factor);
    end
end
%% save file
function parsave(path, feature, sampling_rate)
    [folder, fi, ~] = fileparts(path);
    if ~exist(folder, 'dir')
        mkdir(folder);
    end
    save(path, 'feature');
    path_wav = [folder, '\', fi, '_pre_process', '.wav'];
    wavwrite(feature, sampling_rate, path_wav);
end