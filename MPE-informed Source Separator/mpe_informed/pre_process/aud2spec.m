% Calculate the spectrogram of a audio file (see audioread)
% Chin-Chia Yeh 2013/12/17
%
% spec = aud2spec(aud_path, win, hop, dc)
%
% aud_path: path to audio file
% win: window size for fft, and the unit is samples
% hop: hop size for fft, and the unit is samples
% dc: weither to calculate dc gain (frequency = 0)
% mat: input is a mat file if not equal to 0.
% wav: directly gives the input.

function spec = aud2spec(aud_path, win, hop, dc, mat, wav)
% read wave if not given
if isempty(wav)
    if mat
        wav = importdata(aud_path);
    else
        wav = audioread(aud_path);
    end
end

% merge left/right channel
wav = mean(wav, 2);
if ~any(wav)
    spec = nan;
    return;
end

% nromalize wave with RMS
wav = wav ./ sqrt(sum(wav .^ 2) / length(wav));
wav(isnan(wav)) = 0;
wav(isinf(wav)) = 0;

% trim the wave file
if  any(wav ~= 0)
    wav_nonz = true(size(wav));
    for i = 1:length(wav)
        if wav(i) == 0
            wav_nonz(i) = false;
        else
            break;
        end
    end
    for i = length(wav):-1:1
        if wav(i) == 0
            wav_nonz(i) = false;
        else
            break;
        end
    end
    wav = wav(wav_nonz);
end

% calculate the start/end point for each frame
wav_n = length(wav);
if wav_n < win
    spec = nan;
    return;
end
st = 1:hop:wav_n;
ed = st + win - 1;
while ed(end) > wav_n
    st = st(1:end - 1);
    ed = ed(1:end - 1);
end
win_n = length(st);

% extract the spectrum for each frame
spec = cell(win_n, 1);
win_fun = 0.54 - 0.46*cos(2*pi*(0:win-1)/(win-1));
for i = 1:win_n
    spec{i} = abs(fft(wav(st(i):ed(i))'.*win_fun));
    if dc
        dc_gain = abs(mean(wav(st(i):ed(i))'.*win_fun));
    else
        dc_gain = [];
    end
    spec{i} = [dc_gain, spec{i}(:, round(win / 2) + 1:end)];
end
spec = cell2mat(spec)';

% convert to db\cb scale
spec = 20 * log10(spec + 1e-16);
spec(isnan(spec)) = 0;
spec(isinf(spec)) = 0;