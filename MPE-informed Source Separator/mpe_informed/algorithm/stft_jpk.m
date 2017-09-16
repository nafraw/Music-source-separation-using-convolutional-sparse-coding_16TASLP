function [stft, freq, p_stft] = stft_jpk(audio, param)
%% Calculate Short-time Fourier Transform
%  INPUT:
%    audio: a vector.
%    param: a struct.
%       fs: a scalar, sampling_rate, by default is 44.1k.
%       wlen: a scalar, window length.
%       hop: a scalar, hop size, in usual hop <= wlen.
%  OUTPUT:
%    stft: an f = param.wlen by t complex matrix.
%    freq: a vector, corresponds to the frequency of each bin.
%    p_stft: an floor(f/2)+1 by t complex matrix. Only DC term and positive
%    frequency components.
%% Initialization
% force the input being a column vector
if size(audio,2) > 1
    audio = audio';
end
nsample = length(audio); % number of audio samples before padding
audio = [audio; zeros(param.wlen, 1)]; % pad zero for boundary case
nrow = param.wlen; % number of row
ncol = ceil(nsample/param.hop); % number of column
stft = zeros(nrow, ncol);
% window function, hamming window
winf = hamming(param.wlen, 'periodic');

%% Calculates short time Fourier transform
sidx = 1; % sample index
col  = 1; % current column
while sidx <= nsample
    %% window the audio    
    win_audio = audio(sidx:sidx+param.wlen-1).*winf;
    %% calculate the Fourier transform
    stft(:, col) = fft(win_audio);
    %% update for next iteration
    sidx = sidx + param.hop;
    col  = col + 1;
end
npfreq = floor(param.wlen/2) + 1; % number of positive frequency, plus dc
freq = param.fs/2.*[0:npfreq-1]'./(npfreq-1);
if mod(param.wlen, 2) % odd point
    freq = [freq; -flipud(freq(2:end))];
else % even point
    freq = [freq; -flipud(freq(2:end-1))];
end
p_stft = stft(1:npfreq,:);

end