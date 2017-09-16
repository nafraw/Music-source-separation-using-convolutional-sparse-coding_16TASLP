%% Calculate Short-time Fourier Transform
%  INPUT:
%    P: a q by p matrix. Each column is a partition of the audio.
%    param: a struct.
%       fs: a scalar, sampling_rate, by default is 44.1k.
%       wlen: a scalar, window length.
%       hop: a scalar, hop size, in usual hop <= wlen.
%  OUTPUT:
%    stft_music: an p by f by t complex tensor.
%    freq: an f-dim vector, representing the frequency of each bin.
%    p_stft_music: only maintains the positive and DC terms of stft_music.
function [stft_music, freq, p_stft_music] = cal_stft(P, param)
    % check argument and set default value
    param = chkarg(param);
%     % load data (music) as a vector
%     data = importdata(input_path);
    % calculate short time Fourier transform of each partition
    [q, p] = size(P);
    nrow = param.wlen; % number of row
    ncol = ceil(q/param.hop); % number of column
    stft_music   = zeros(p, nrow, ncol);
    p_stft_music = zeros(p, floor(nrow/2)+1, ncol);
    for i = 1:p
        % it doesn't matter for freq as it is the same for each partition.
%         [stft_music(i,:,:), freq, p_stft_music(i,:,:)] = stft_jpk(data, param);
        [stft_music(i,:,:), freq, p_stft_music(i,:,:)] = stft_jpk(P(:,i), param);
    end
end

function param = chkarg(param)
    if ~isstruct(param)
        error('param must be a struct.');
    end
    if ~isfield(param, 'fs')
        param.fs = 441000;
    elseif isempty(param.fs)
        param.fs = 441000;
    end
    if ~isfield(param, 'wlen')
        error('wlen (window length) must be specified.');
    elseif isempty(param.wlen)
        error('wlen (window length) must be specified.');
    end
    if ~isfield(param, 'hop')
        error('wlen (window length) must be specified.');
    elseif isempty(param.hop)
        error('wlen (window length) must be specified.');
    elseif param.hop > param.wlen
        warning('hop size is larger than wlen (window length)');
    end
end
